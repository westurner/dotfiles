#!/usr/bin/env python
from __future__ import print_function
"""
Print process information for all connections,
or for connections on the specified ports.

"""
import collections
try:
    import psutil
except ImportError as e:
    import warnings
    warnings.warn(str(e))
    psutil = object()
import logging


def net_connection_memory_info(ports=[80, 443],
                               yield_pid=False,
                               yield_row=False,
                               yield_dict=False,
                               yield_str=True):
    """
    Print psutil.Process.memory_info for processes with sockets open to
    the specified ports.

    Keyword Arguments:
        ports (list): list of port numbers to match

    Returns:
        None
    """
    try:
        connections = psutil.net_connections()
    except psutil.AccessDenied as e:
        logging.error("Must have permissions")
        logging.exception(e)
        raise

    def filter_cnxs(connections, ports=None):
        for cnx in connections:
            port_matches = False
            if ports:
                if cnx.laddr:
                    port = cnx.laddr[-1]
                    if port in ports:
                        port_matches = True
                if cnx.raddr:
                    if port in ports:
                        port_matches = True
            if (not ports) or (port_matches):
                yield cnx

    connections = filter_cnxs(connections, ports=ports)

    pids_dict = collections.OrderedDict(
        ((cnx.pid, cnx) for cnx in connections))
    processes = [x for x in psutil.process_iter() if x.pid in pids_dict]
    cols = [
        'lport', 'lhost', 'rport', 'rhost', 'username', 'pid', 'cmdline'
    ]

    def joinrow(cols, nonestr=None):
        return '\t'.join(((unicode(s) if s is not None else nonestr) for s in cols))

    if yield_str:
        yield joinrow(cols)
    for p in processes:
        cnx = pids_dict[p.pid]
        if yield_pid:
            yield p.pid
        lhost, lport, rhost, rport = None, None, None, None
        if cnx.laddr:
            lhost, lport = cnx.laddr
        if cnx.raddr:
            rhost, rport = cnx.raddr
        row = [lport, lhost, rport, rhost, p.username(), p.pid, ' '.join(p.cmdline())]
        if yield_row:
            yield row
        if yield_dict or yield_str:
            attrs = collections.OrderedDict()
            for attrkey, attrvalue in zip(cols, row):
                attrs[attrkey] = attrvalue
            if yield_dict:
                yield attrs
        if yield_str:
            yield joinrow(row, nonestr='-')


def main():
    import sys
    args = []
    ports = []
    just_the_pid = False
    if '--pid' in sys.argv:
        sys.argv.remove('--pid')
        just_the_pid = True
    if len(sys.argv) > 1:
        args = sys.argv[1:]
        ports = [int(x) for x in args]
    kwargs = {
        'ports': ports,
    }
    if just_the_pid:
        kwargs['yield_pid'] = True
        kwargs['yield_str'] = False
        kwargs['yield_dict'] = False
        kwargs['yield_row'] = False
    else:
        kwargs['yield_str'] = True

    for str_ in net_connection_memory_info(**kwargs):
        print(str_)
    return 0


if __name__ == "__main__":
    import sys
    sys.exit(main())
