#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function
"""
netstatpsutil -- Print process information for all processes
on all or the specified ports;
and optionally kill each unique PID with the specified signal.

This is more safe than netstat with awk and grep because grep matches
anywhere in the line.

"""
import collections
import logging
import subprocess
import sys
import time

try:
    import psutil
except ImportError as e:
    import warnings
    warnings.warn(str(e))
    psutil = object()

log = logging

if sys.version_info.major > 2:
    unicode = str

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
        yield_pid (bool): yield the port/process PID
        yield_row (bool): yield the port/process as a list
        yield_dict (bool): yield the port/process as a dict
        yield_str (bool): yield the port/process as a tab-delimited str
        yield_process (bool): yield the psutil Process object

    Yields: whichever values are specified in the yield_ kwargs, interleaved
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

    pids_dict = collections.OrderedDict()
    for cnx in connections:
        pid_cnxs = pids_dict.setdefault(cnx.pid, [])
        pid_cnxs.append(cnx)

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
        cnxs = pids_dict[p.pid]
        for cnx in cnxs:
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


# import unittest


# class Test_(unittest.TestCase):

#     def setUp(self):
#         pass

#     def test_(self):
#         pass

#     def tearDown(self):
#         pass


def main(argv=None):
    """
    netstatpsutil main() function

    Keyword Arguments:
        argv (list): commandline arguments (e.g. sys.argv[1:])
    Returns:
        int: nonzero on error
    """
    import logging
    import optparse

    prs = optparse.OptionParser(
        usage="%prog [-p|--pid] [-k|--kill <9|SIGKILL>] <port_1> <port_n>")

    prs.add_option('-p', '--pid',
                   action='store_true',
                   dest='just_the_pid',
                   help='Print just the PIDs matching the given port(s)')

    prs.add_option('--kill',
                   action='store',
                   help=('Run `kill -[kill] each pid` '
                         '(int 1-31: see `man 7 signal`)'))
    prs.add_option('-f', '--force',
                   action='store_true',
                   help=(
                       'Specify to actually kill all PIDs on all ports'
                       'if --kill is specified '
                       'but no specific ports are'))

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
    log = logging.getLogger('main')
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
    try:
        ksig = opts.kill and int(opts.kill)
        if (ksig and 0 > ksig > 31):
            prs.error("Expected signum to be between 1-31")
    except ValueError:
        ksig = opts.kill

    if ksig:
        retval = 0

        log.info("## Before killing processes:")
        for procstr in net_connection_memory_info(ports=ports, yield_str=True):
            print(procstr)

        log.info("## Killing processes:")
        if not ports and opts.kill and not opts.force:
            prs.error("No ports were specified. You must specify -f/--force "
                      "to actually kill all PIDs on all ports")
        proc_list = net_connection_memory_info(ports=ports, yield_process=True)
        unique_procs = collections.OrderedDict.fromkeys(proc_list)
        for proc in unique_procs.values():
            try:
                if isinstance(ksig, int):
                    cmd = ('kill', '-%s' % ksig, '%d' % proc.pid)
                else:
                    cmd = ('kill', '-s', ksig, '%d' % proc.pid)
                log.info(('killcmd', cmd))  # print the comparable kill cmd
                log.info(('killstr', u' '.join(cmd)))
                if isinstance(ksig, int):
                    proc.send_signal(ksig)
                else:
                    subprocess.call(cmd)
            except Exception as e:
                log.exception(e)
                retval = 3
                pass
        time.sleep(1)

        log.info("## After killing processes:")
        for procstr in net_connection_memory_info(ports=ports, yield_str=True):
            print(procstr)
        return retval
    else:
        if opts.list:
            if opts.just_the_pid:
                kwargs['yield_pid'] = True
                kwargs['yield_str'] = False
                kwargs['yield_dict'] = False
                kwargs['yield_row'] = False
                pid_list = tuple(net_connection_memory_info(**kwargs))
                pids_unique = collections.OrderedDict.fromkeys(pid_list)
                for pid in pids_unique.keys():
                    print(pid)
            else:
                kwargs['yield_str'] = True
                for str_ in net_connection_memory_info(**kwargs):
                    print(str_)

    EX_OK = 0
    return EX_OK


if __name__ == "__main__":
    import sys
    sys.exit(main(argv=sys.argv[1:]))
