#!/usr/bin/env python
from __future__ import print_function
"""
el
==

Open args from stdin with EDITOR_ or EDITOR

Usage:

.. code:: bash

    # edit files from ls
    ls | el -e

    # edit files from find -print0
    find . -depth 1 -print0 | el -0 -e

    # print lines from stdin
    printf "one\ntwo" | el --each -x echo

    printf "one\ntwo" | el

    find . -type f -print0 | el -0 --each -x echo

"""

# import __builtin__
import codecs
import distutils.spawn
import logging
import os
import shlex
import subprocess
import sys
if sys.version_info.major > 2:
    string_types = str
    unicode = str

    import io
    StringIO = io.StringIO
    Buffer = lambda x=None: io.TextIOWrapper(io.StringIO(x))
else:
    string_types = basestring
    import StringIO
    StringIO = StringIO.StringIO
    Buffer = lambda x=None: StringIO.StringIO(x)

log = logging.getLogger('el')

DEFAULT_ENCODING = 'UTF8'

RET_OK = 0
RET_ERR_EDITOR = 3
RET_ERR_ARGS_EXPECTED = 7
RET_ERR_IN_A_SUBCOMMAND = 22


def print_help(argv=sys.argv, file=sys.stdout):
    """
    Print help/usage information

    Keyword Arguments:
        file (file-like): file to ``print`` to (e.g. ``sys.stdout``)
    """
    def usage_iter():
        yield ("%s [-h] [-q] [-0] [-e] [-x <cmd>]" % argv[0])
        yield ("")
        yield (" el (Edit Lines): a line-based UNIX utility similar to xargs.")
        yield ("")
        yield ("  --each|--map  ## for arg in args; do cmd.format(arg); done")
        yield ("  -f|--force    ## continue on error")
        yield ("")
        yield ("  -x <cmd> ## Execute <cmd>")
        yield ("           ## by appending the value of {0} if '{0}' is not in <cmd>")
        yield ("  -e       ## Execute '$EDITOR_ {0}' or '$EDITOR {0}' (default)")
        yield ("")
        yield ("  -0  ## split by \\0")
        yield ("")
        yield ("  -h  ## print_help() message")
        yield ("  -v  ## verbose (logging.DEBUG)")
        yield ("")
        yield ("""Examples:

    $ ls | el -e
    $ touch '__file'$'\\n''name__'; \\
      ls __file*__ | el -x stat; echo '--'; \\
      find . -maxdepth 1 -type f -name '__file*' -print0 | el -0 -x stat;
    $ find . -maxdepth 1 -print0 | el -0 -e
    $ find . -type f  -print0 | el -0 --each -x echo
    $ printf "one\\ntwo" | el -x echo
    $ printf "one\\ntwo" | el --each -x echo
    $ printf "one\\ntwo" | el --each -x 'echo Hello, "{0}" "!"'

    $ printf "README.md\\n2.py" | EDITOR_=e el -e
    $ printf "README.md\\n2.py" | el -x e
""")

    for line in usage_iter():
        print(line)


class Cmd(object):
    """
    A shell command as a list that can be rendered with arguments.

    (To avoid using string concatenation for OS commands; and instead
    work with lists of arguments.)
    """

    def __init__(self, cmdlist=None):
        self.set_cmdlist(cmdlist)

    def set_cmdlist(self, cmdlist):
        """
        Set self.cmdlist (and self.cmd)

        Args:
            cmdlist (list[str]): shell command 'tokens'
        """
        if cmdlist is None:
            cmdlist = []
        self.cmdlist = cmdlist
        self.cmd = self._process_cmd(self.cmdlist)
        # log.debug('cmd.set_cmdlist: %r' % cmd)

    def __str__(self):
        return u'Cmd(%r)' % (self.cmdlist)

    @staticmethod
    def _process_cmd(cmdlist):
        """
        If cmdlist[0] is not a path
        """
        binname = cmdlist[0]
        find_executable = False
        if '/' not in binname:
            find_executable = True
        if find_executable is False:
            return cmdlist
        else:
            binpath = distutils.spawn.find_executable(binname)
            if not binpath:
                raise Exception("%r not found" % binname)
            cmd_output = cmdlist[:]
            cmd_output[0] = binpath
            return cmd_output

    @staticmethod
    def _render_cmd(cmd, args, join_args=None, always_append_args=True):
        """
        Render a command like a template; with arguments as the context.

        Insert or append args to the ``cmd`` list where ``{0}`` is found,
        or, at the end, if ``{0}`` is not found
        and ``always_append_args`` is ``True``.

        Arguments:
            cmd (list[str]): a list of commands, optionally containing ``{0}``
                if ``{0}`` occurs in the middle of a term (e.g. is not quoted),
                the arguments will be joined together with ``join_args``
            args (list[str]): zero or more arguments to insert at ``{0}``
                or append, if ``always_append_args`` is ``True.

        Keyword Arguments:
            join_args (None, str, or callable): function to join arguments by.
                If ``join_args`` is a ``str``, the callable is ``strvalue.join``.
                If ``join_args`` is ``None``, the arguments will not be joined.
            always_append_args (bool): whether to append arguments by default
                when the ``{0}`` pattern is not found

        Returns:
            list[str]: a command to execute (e.g. with ``subprocess.Popen``)
        """
        log.debug('render_cmd(cmd,args): (%r, %r)' % (cmd, args))

        def _render_cmd_iter(cmd, args, join_args=join_args):
            added = False
            if join_args:
                if isinstance(join_args, string_types):
                    join_args = join_args.join
            for token in cmd:
                # todo: support escaped '{{0}}', w/ regex (?)
                if token and '{0}' in token:
                    if token == '{0}':
                        for x in args:
                            yield x
                        added = True
                    else:
                        if join_args:
                            argstr = join_args(args)
                        else:
                            argstr = args
                        _token = token.format(argstr)  # TODO: does this mangle
                        yield _token
                        added = True
                else:
                    yield token
            if not added and always_append_args:
                for x in args:
                    yield x
        cmd = list(_render_cmd_iter(cmd, args, join_args=join_args))
        log.debug('_render_cmd: %r' % cmd)
        return cmd

    def render(self, args, join_args=None, always_append_args=True):
        """
        Call :py:method:`_render_cmd` with ``self.cmd`` and ``args
        """
        cmd = self._render_cmd(self.cmd, args,
                               join_args=join_args,
                               always_append_args=True)
        return cmd

    @staticmethod
    def _call(args, **kwargs):
        """
        Wraps subprocess.call

        Arguments:
            args (list[str]): args for subprocess.call
                (subprocess.Popen.__init__:args[0])

        Returns:
            int: OS retcode from ``subprocess.call``
        """
        log.debug('subprocess.call(args,kwargs): (%r, %r)' % (args, kwargs))
        return subprocess.call(args, **kwargs)

    def run(self, args, **kwargs):
        """
        Preprocess args, render, and run the command with the given arguments

        Arguments:
            args (list[str]): arguments with which to render self.cmdlist
                (e.g. as args for subprocess.call (subprocess.Popen)).

        Returns:
            int: OS retcode from ``subprocess.call``
        """
        join_args = kwargs.pop('join_args', None)
        if hasattr(self, 'preprocess_args'):
            args = self.preprocess_args(args)
            log.debug("cmd.preprocess_args [%s]: %r" % (
                self.__class__.__name__, args))
        cmd = self.render(args, join_args=join_args)
        log.info("cmd.run: %s" % cmd)
        return self._call(cmd, **kwargs)


class OpenEditorCmd(Cmd):

    def __init__(self, *args, **kwargs):
        self.set_cmdlist(self.get_editor_cmdlist())

    @staticmethod
    def get_editor_cmdlist():
        env = os.environ
        EDITOR = env.get('EDITOR')
        EDITOR_ = env.get('EDITOR_')
        log.debug("EDITOR=%r" % EDITOR)
        log.debug("EDITOR_=%r" % EDITOR_)
        editorstr = EDITOR_ or EDITOR
        if editorstr is None:
            log.error("Neither EDITOR_ nor EDITOR are set")
            return RET_ERR_EDITOR
        editor_cmdlist = shlex.split(editorstr)
        log.debug("editor_cmdlist: %r" % editor_cmdlist)
        return editor_cmdlist

    def preprocess_args(self, args):
        """
        If args[0] starts with +, shlex.split args[0]
        e.g. for '+123 README'
        """
        if args and len(args) == 1 and args[0][0].lstrip()[0] == '+':
            args = shlex.split(args[0])
        return args


class Conf(object):
    pass


def main(argv=None, stdin=sys.stdin,
                    stdout=sys.stdout,
                    stderr=sys.stderr,
                    encoding=DEFAULT_ENCODING):

    if argv is None:
        _argv = argv = []
    else:
        _argv = argv
        argv = _argv[:]

    if sys.version_info.major < 3:
        stdin = codecs.getreader(encoding)(stdin)
        stdout = codecs.getwriter(encoding)(stdout)

    conf = Conf()
    conf.cmd = None

    cmdlist = None
    if '-x' in argv:
        xpos = argv.index('-x')
        cmdlist = argv[xpos + 1:]
        if len(cmdlist) == 1:
            #quotechars = '"\''
            cmdstr = cmdlist[0] # XXX: .strip(quotechars)
            try:
                cmdlist = shlex.split(cmdstr)
            except ValueError as e:
                log.debug(cmdstr)
                log.exception(e)
                raise
        conf.cmd = Cmd(cmdlist)
        argv = argv[0:xpos]

    if '-h' in argv or '--help' in argv:
        print_help(file=stdout)
        return 0

    if '-v' in argv:
        count = argv.count('-v')
        if count == 1:
            logging.basicConfig(
                level=logging.INFO)
            argv.remove('-v')
        if count == 2:
            logging.basicConfig(
                level=logging.DEBUG)
            argv.remove('-v')
            argv.remove('-v')

    if '-t' in argv:
        argv.remove('-t')
        return unittest.main()

    conf.open_in_editor = False
    if '-e' in argv:
        conf.open_in_editor = True
        conf.cmd = OpenEditorCmd()

    if not (cmdlist or conf.open_in_editor):
        errmsg = '''Error: Must specify '-e' or '-x <cmd>' or '-x "cmd"'''
        print(errmsg, file=stderr)
        print("", file=stderr)
        print_help(file=stderr)
        # prs.error()
        return RET_ERR_ARGS_EXPECTED

    conf.all_at_once = True
    conf.one_at_a_time = False
    for x in ['--each', '--map']:
        if x in argv:
            conf.one_at_a_time = True
            conf.all_at_once = False
            argv.remove(x)
            break

    conf.stop_on_error = True
    if '-f' in argv or '--force' in argv:
        conf.stop_on_error = False
    if '--stop-on-error' in argv:
        conf.stop_on_error = True


    if '-0' in argv:
        text = stdin.read()
        lines = args = text.split('\0')  # TODO: itersplit
    else:
        def iter_stdin(stdin):
            for line in stdin:
                log.info("stdin>>> %r" % line)
                l = line.strip()
                if l:
                    yield l
        lines = iter_stdin(iter(stdin))
        if conf.all_at_once:
            args = list(lines)
        else:
            args = iter(lines)

    log.info('cmd: %s' % conf.cmd)
    log.debug("args: %r" % args)
    retcode = RET_OK
    if conf.all_at_once:
        retcode = conf.cmd.run(args, join_args=' ')
    elif conf.one_at_a_time:
        retcode = RET_OK
        error_count = 0
        for arg in args:
            _args = [arg]
            _retcode = conf.cmd.run(_args, join_args=' ')
            log.debug("cmd.retcode: %d" % _retcode)
            if _retcode != RET_OK:
                retcode = RET_ERR_IN_A_SUBCOMMAND
                error_count += 1
                if conf.stop_on_error:
                    print(
                        "ERROR: Stopping early (use -f to continue on errors)",
                        file=stderr)
                    break
    else:
        log.info(conf.cmd)
        log.info(args)
    return retcode


import unittest

class TestEl(unittest.TestCase):

    def test_main_help(self):
        cmd = ['-h']
        retcode = main(argv=cmd)
        self.assertEqual(retcode, 0)

    def test_main_must_specify_x_or_e(self):
        cmd = ['-v']
        retcode = main(argv=cmd)
        self.assertEqual(retcode, 7)

    def test_main_ls_l(self):
        cmd = ['-x', 'echo']
        self._test_cmd(cmd)

    def test_main_ls_l_x_echo_(self):
        cmd = ['-x', 'echo', '#', ]
        self._test_cmd(cmd)

    def test_main_ls_l_x_echo__0(self):
        cmd = ['-x', 'echo', '#', '{0}']
        self._test_cmd(cmd)

    def test_main_ls_l_echo_0(self):
        cmd = ['-x', "echo '{0}'"]
        self._test_cmd(cmd)

    def _test_cmd(self, cmd):
        stdin_text = []
        for n in range(3):
            stdin_text.append(unicode(__file__) + unicode('\n'))
        stdin = StringIO("".join(stdin_text))
        lines = stdin.readlines()
        stdin.seek(0)
        retcode = main(argv=cmd, stdin=stdin)
        self.assertEqual(retcode, 0)
        return retcode


if __name__ == "__main__":
    if '--TEST' in sys.argv:
        sys.argv.remove('--TEST')
        sys.exit(unittest.main())
    sys.exit(main(argv=sys.argv))
