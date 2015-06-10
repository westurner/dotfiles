#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function
"""
netstatpsutil -- Print process information for all connections,
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

log = logging


AccessDenied = None
if hasattr(psutil, 'AccessDenied'):
    AccessDenied = psutil.AccessDenied
else:
    AccessDenied = Exception


def net_connection_memory_info(ports=[80, 443],
                               yield_pid=False,
                               yield_row=False,
                               yield_dict=False,
                               yield_str=False,
                               yield_process=False):
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
    except AccessDenied as e:
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
                # if cnx.raddr:
                #    if port in ports:
                #        port_matches = True
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
        return '\t'.join(((unicode(s) if s is not None else nonestr)
                          for s in cols))

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
        row = [lport,
               lhost,
               rport,
               rhost,
               p.username(),
               p.pid,
               ' '.join(p.cmdline())]
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
        if yield_process:
            yield p


import unittest


class Test_(unittest.TestCase):

    def setUp(self):
        pass

    def test_(self):
        pass

    def tearDown(self):
        pass


def main(argv=None):
    """
    Main function

    Keyword Arguments:
        argv (list): commandline arguments (e.g. sys.argv[1:])
    Returns:
        int:
    """
    import logging
    import optparse

    prs = optparse.OptionParser(
        usage="%prog [-p|--pid] [-k|--kill <29>] <port_1> <port_n>")

    prs.add_option('-p', '--pid',
                   action='store_true',
                   dest='just_the_pid',
                   help='Print just the PIDs matching the given port(s)')

    prs.add_option('--kill',
                   action='store',
                   help=('Run `kill -[kill] pid_1 pid_n` '
                         '(int 1-31: see `man signal`)'))

    prs.add_option('-l', '--list',
                   action='store_true',
                   default=True,
                   help=('List programs running on the given ports'
                         ' (Default: True)'))

    prs.add_option('-v', '--verbose',
                   dest='verbose',
                   action='store_true',)
    prs.add_option('-q', '--quiet',
                   dest='quiet',
                   action='store_true',)
    prs.add_option('-t', '--test',
                   dest='run_tests',
                   action='store_true',)

    loglevel = logging.INFO
    argv = list(argv) if argv else []
    (opts, args) = prs.parse_args(args=argv)
    if opts.verbose:
        loglevel = logging.DEBUG
    elif opts.quiet:
        loglevel = logging.ERROR
    logging.basicConfig(level=loglevel)
    log.debug('argv: %r', argv)
    log.debug('opts: %r', opts)
    log.debug('args: %r', args)

    if opts.run_tests:
        import sys
        sys.argv = [sys.argv[0]] + args
        import unittest
        return unittest.main()

    ports = [int(x) for x in args]
    kwargs = {
        'ports': ports,
    }
    ksig = opts.kill and int(opts.kill)
    if (ksig and 0 > ksig > 31):
        prs.error("Expected signum to be between 1-31")

    just_the_pid = opts.just_the_pid
    if ksig:
        retval = 0

        print("#Before")
        for p in net_connection_memory_info(ports=ports, yield_str=True):
            print(p)
        print("#...")
        for p in net_connection_memory_info(ports=ports, yield_process=True):
            try:
                cmd = ('kill', '-%s' % ksig, '%r' % p.pid)
                print(cmd)  # print the comparable kill cmd
                print(u' '.join(cmd))
                p.send_signal(ksig)
            except Exception as e:
                log.exception(e)
                retval = 3
                pass
        print("#After")
        for p in net_connection_memory_info(ports=ports, yield_str=True):
            print(p)
        return retval
    else:
        if opts.list:
            if kwargs.get('just_the_pid'):
                kwargs['yield_pid'] = True
                kwargs['yield_str'] = False
                kwargs['yield_dict'] = False
                kwargs['yield_row'] = False
            else:
                kwargs['yield_str'] = True

            for str_ in net_connection_memory_info(**kwargs):
                print(str_)

    EX_OK = 0
    return EX_OK


if __name__ == "__main__":
    import sys
    sys.exit(main(argv=sys.argv[1:]))
