#!/usr/bin/env python3
# PYTHON_ARGCOMPLETE_OK
# -*- coding: utf-8 -*-
"""
lsofport
"""
# pylint: disable=missing-module-docstring
# pylint: disable=missing-class-docstring
# pylint: disable=missing-function-docstring
# pylint: disable=use-dict-literal
# pylint: disable=no-else-return

import glob
import logging
import os
import os.path
import re
import subprocess
import sys
import types
from collections import namedtuple
from functools import wraps

try:
    import pytest
except ImportError:
    class pytest:
        class mark:
            def parametrize(self, *args, **kwargs):
                def decorator_parametrize(func):
                    def wrapper(*args, **kwargs):
                        return func(*args, **kwargs)
                    return wrapper
                return decorator_parametrize


__version__ = "0.0.1"

logging.basicConfig()
log = logging.getLogger()
log.setLevel(logging.INFO)


def trace(f):
    @wraps(f)
    def trace_(*args, **kwargs):
        if kwargs.pop("verbosity", None):
            log.info(
                f"# {f.__qualname__} : %r",
                dict(args=args, kwargs=kwargs),
            )
        return f(*args, **kwargs)

    return trace_


_check_output = trace(subprocess.check_output)
_call = trace(subprocess.call)


def int2hex(port: int):
    return hex(int(port))[2:].upper().rjust(4, "0")


def parse_proc_ipaddr(addr: str):
    return ".".join(
        str(int(addr[n: (n + 2 or None)], 16)) for n in range(-2, -10, -2)
    )


def read_proc_net_tcp(path="/proc/self/net/tcp"):
    output = _check_output(["cat", path])
    row_iter = iter(line.split() for line in output.decode().splitlines())

    row_header = next(row_iter)
    field_names__ = [x.replace("->", "__") for x in (row_header)] + [
        f"x_{chr(97+n)}" for n in range(5)
    ]

    global NetTCPRow  # TODO

    class NetTCPRow(
        namedtuple(
            "NetTcpRow", field_names__, defaults=(None,) * len(field_names__)
        )
    ):
        # def __new__(cls, *args, **kwargs):
        #     print('Row.__new__',
        #       dict(args=args, args_len=len(args), kwargs=kwargs))
        #     return super().__new__(cls, *args, **kwargs)

        def local_address_port(self):
            return self.local_address.split(":", 1)[1]

        def local_address_port__matches(self, port=None, port_hex=None):
            return self.matches_port(
                address=self.local_address, port=port, port_hex=port_hex
            )

        @staticmethod
        def matches_port(*, address: str = None, port=None, port_hex=None):
            if port_hex is None:
                if port is None:
                    raise ValueError("port_hex or port must be specified")
                port_hex = int2hex(port)
            return address.endswith(f":{port_hex}")

    try:
        rows = []
        for row in row_iter:
            try:
                rows.append(NetTCPRow(*row))
            except TypeError:
                print("ERROR", dict(row=row))
        return rows
    except Exception:
        _call(["cat", path])
        raise


def read_proc_fd_paths():
    return [
        path
        for path in glob.glob("/proc/*/fd/*")
        if re.match(r"/proc/(\d+)/fd/(\d+)", path)
    ]


def proc_fd_path_to_pid(path):
    return int(os.path.basename(os.path.dirname(os.path.dirname(path))))


def parse_proc_fd_socket_path(path):
    return int(path.split(":", -1)[1].strip("[]"))


def find_processes_with_sockets(
    inode_id=None,
) -> list[int] | list[tuple[int, int]]:
    """
    Returns:
        list: [(pid, socket_inode),]
        list: [pid,]
    """
    proc_fd_paths = read_proc_fd_paths()

    if inode_id:
        return [
            (proc_fd_path_to_pid(x))
            for x in proc_fd_paths
            if f"socket:[{inode_id}]" == os.path.basename(os.path.realpath(x))
        ]
    else:
        return [
            (proc_fd_path_to_pid(x), parse_proc_fd_socket_path(realpath))
            for x in proc_fd_paths
            if "socket:" in (realpath := os.path.realpath(x))
        ]


def find_processes_on_port(*, port, verbosity=False):
    rows = read_proc_net_tcp()
    matches = []
    for row in rows:
        if row.local_address_port__matches(port):
            if verbosity:
                print("INFO: local_address_port__match:", dict(row=row, inode=row.inode, uid=row.uid), file=sys.stderr)
            matches.append(row.inode)
    for inode_id in matches:
        yield from find_processes_with_sockets(inode_id=inode_id)


def lsofport(opts):
    """find processes listening on a port without netstat, ss, or lsof

    Arguments:
        port (str): ...

    Keyword Arguments:
        port (str): ...

    Returns:
        str: ...

    Yields:
        str: ...

    Raises:
        Exception: ...
    """

    print(f"# opts={opts.__dict__}", file=sys.stderr)
    rows = read_proc_net_tcp(opts.proc_net_tcp)

    if opts.verbosity > 1:
        for row in rows:
            print(row, file=sys.stderr)

    pids = []
    for pid in find_processes_on_port(port=opts.port):
        print(pid)
        pids.append(pid)
        _call(
            ["ps", *opts.ps_args, "-p", str(pid)],
            verbosity=opts.verbosity,
            stdout=sys.stderr,
        )
    return pids


def test_int2hex():
    assert int2hex(0) == "0000"
    assert int2hex(1) == "0001"
    assert int2hex(631) == "0277"
    assert int2hex(0xFFFF) == "FFFF"


def test_parse_proc_ipaddr():
    assert parse_proc_ipaddr("00000000") == "0.0.0.0"
    assert parse_proc_ipaddr("80FF000A") == "10.0.255.128"


def test_read_proc_fd_paths():
    paths = read_proc_fd_paths()
    assert isinstance(paths, list)
    assert len(paths)


def test_find_processes_with_sockets():
    output = find_processes_with_sockets()
    assert isinstance(output, list)
    assert output, output
    assert isinstance(output[0][0], int)
    assert isinstance(output[0][1], int)
    # assert False, output


TEST_INODE_ID = "1405823"
TEST_PORT_NUMBER = "18088"


def test_find_processes_with_sockets_match_inode_id(
    inode_id=TEST_INODE_ID,  # TODO: fixture for this somehow:
):
    output = find_processes_with_sockets(inode_id=inode_id)
    assert isinstance(output, list)
    assert output, output
    assert isinstance(output[0], int)
    # assert False, output


def test_read_proc_net_tcp():
    output = read_proc_net_tcp()
    assert isinstance(output, list)
    assert hasattr(output[0], "_fields")
    assert hasattr(output[0], "local_address")


def test_row_port_matches():
    assert NetTCPRow.matches_port(address="00000000:0001", port=1)
    assert NetTCPRow.matches_port(address="00000000:0010", port=16)
    assert NetTCPRow.matches_port(address="00000000:0100", port=16**2)
    assert NetTCPRow.matches_port(
        address="00000000:1001", port=1 * (16**3) + 1 * (16**0)
    )
    assert NetTCPRow.matches_port(address="00000000:46A8", port=18088)
    assert not NetTCPRow.matches_port(address="00000000:0001", port=18088)


def test_row_local_address_port__matches(port=TEST_PORT_NUMBER):
    rows = read_proc_net_tcp()
    matches = []
    for row in rows:
        if row.local_address_port__matches(port):
            matches.append(row)
    if not matches:
        raise AssertionError("There should be a row with a matching port")


def test_find_processes_on_port(port=TEST_PORT_NUMBER):
    output = find_processes_on_port(port=port, verbosity=True)
    assert isinstance(output, types.GeneratorType)
    output = list(output)
    assert output
    assert False, output


# def test_lsofport():
@pytest.mark.parametrize(
    "port",
    [
        TEST_PORT_NUMBER,
    ],
)
def test_lsofport(port):
    class Opts:
        pass

    opts = Opts()
    opts.port = port
    opts.proc_net_tcp = "/proc/self/net/tcp"
    opts.verbosity = 2
    output = lsofport(opts)
    assert output
    assert isinstance(output, list)
    assert False, output


@pytest.mark.parametrize(
    "argv",
    [
        None,
        [],
    ],
)
def test_main(argv):
    """test the main(sys.argv) CLI function"""
    with pytest.raises(SystemExit):
        _ = main(argv)


@pytest.mark.parametrize(
    "argv, inode_id",
    [
        [["-p", TEST_PORT_NUMBER, "-v", "-v"], TEST_INODE_ID],
    ],
)
def test_main_0(capsys, argv, inode_id):
    retcode = main([__file__, *argv])
    assert retcode == 0
    captured = capsys.readouterr()
    assert "/proc/self/net/tcp" in captured.err
    assert any(line.startswith("NetTCPRow(") for line in captured.err)
    # assert f'## sockets matching: {inode_id}' in captured.err
    # assert False, captured


def get_parser():
    import argparse

    prs = argparse.ArgumentParser(
        usage="%(prog)s [-h][-v] -p <port>",
        description="find processes listening on a port without netstat, ss, or lsof",
    )

    prs.add_argument("-p", "--port", dest="port", action="store", help="The port number to search for")

    prs.add_argument("--find-sockets", dest="find_sockets_all", action="store_true", help="Find all processes with sockets")
    prs.add_argument(
        "--find-sockets-on-port", dest="find_sockets_on_port", action="store_true", help="Find sockets on the specified port"
    )
    prs.add_argument(
        "--find-sockets-on-inode", dest="find_sockets_inode", action="store", help="Find sockets by inode id"
    )

    prs.add_argument(
        "--find-processes",
        dest="find_processes",
        action="store_true",
        help="Find processes on the specified port (default behavior when a port is given)",
    )

    DEFAULT_PS_ARGS = ["-fwZ"]  # TODO: if selinux else no -Z
    prs.add_argument(
        "--ps-args", dest="ps_args", action="store", default=DEFAULT_PS_ARGS, help="Arguments to pass to the ps command (default: %(default)s)"
    )

    prs.add_argument(
        "--proc-net-tcp",
        dest="proc_net_tcp",
        action="store",
        default="/proc/self/net/tcp",
        help="Path to the proc net tcp file (default: %(default)s)",
    )

    prs.add_argument(
        "-v", "--verbose", dest="verbosity", action="count", default=0, help="Increase verbosity level"
    )
    prs.add_argument(
        "-q",
        "--quiet",
        dest="quiet",
        action="store_true",
        help="Run quietly",
    )
    prs.add_argument(
        "-t",
        "--test",
        dest="run_tests",
        action="store_true",
        help="Run tests",
    )
    prs.add_argument(
        "--ipdb",
        "--test-ipdb",
        dest="ipdb",
        action="store_true",
        help="Run tests with ipdb",
    )

    prs.add_argument("--version", dest="version", action="store_true", help="Show version information")

    return prs


def main(argv=None):
    """
    lsofport main() function

    Keyword Arguments:
        argv (list): commandline arguments (e.g. sys.argv[1:])
    Returns:
        int:
    """
    prs = get_parser()

    try:
        import argcomplete
        argcomplete.autocomplete(prs)
    except ImportError:
        pass

    if argv is None:
        argv = sys.argv[1:]
    argv = list(argv) if argv else []
    if not argv:
        prs.print_help()
        # return 0
        raise SystemExit(0)

    (opts, args) = prs.parse_known_args(args=argv)
    loglevel = logging.INFO
    if opts.verbosity:
        loglevel = logging.DEBUG
    elif opts.quiet:
        loglevel = logging.ERROR
    logging.basicConfig(level=loglevel)
    log = logging.getLogger("main")
    log.debug("argv: %r", argv)
    log.debug("opts: %r", opts)
    log.debug("args: %r", args)
    if opts.version:
        print(__version__)

    if opts.run_tests:
        try:
            arg_i_index = args.index("-i")
            args[arg_i_index] = "--pdb"
            if opts.ipdb:
                args.insert(
                    arg_i_index + 1,
                    "--pdbcls=IPython.terminal.debugger:TerminalPdb",
                )
        except ValueError:
            pass

        _call(["pytest", "-v", "-l"] + args + [__file__])

    if opts.find_sockets_all:
        for x in find_processes_with_sockets():
            print(x[0], x[1])

    if opts.find_sockets_on_port:
        for x in find_processes_with_sockets():
            print(x[0], x[1])

    if opts.find_sockets_inode:
        for x in find_processes_with_sockets(opts.find_sockets_inode):
            print(x[0], x[1])

    if opts.find_processes or not any((
        opts.find_sockets_all,
        opts.find_sockets_on_port,
        opts.find_sockets_inode,
    )):
        if not opts.port:
            prs.error("-p <port> must be specified")
        output = lsofport(opts)
        print(output)

    return 0


if __name__ == "__main__":
    sys.exit(main(argv=sys.argv[1:]))
