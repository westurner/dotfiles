#!/usr/bin/env python
from __future__ import print_function
"""
Print psutil.Process.memory_info for processes with sockets open to
the specified ports.
"""
import psutil
import logging

def net_connection_memory_info(ports=[80, 443]):
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
    pids = [cnx.pid for cnx in connections
            if cnx.raddr and cnx.raddr[-1] in ports]
    print(pids)
    pids_dict = dict.fromkeys(pids)
    processes = [x for x in psutil.process_iter() if x.pid in pids_dict]
    for p in processes:
        print(p, p.memory_info())


def main():
    net_connection_memory_info()
    return 0


if __name__ == "__main__":
    import sys
    sys.exit(main())
