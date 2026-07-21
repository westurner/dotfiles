#!/usr/bin/env python3
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
import errno
import logging
import os
import shlex
import shutil
import subprocess
import sys
import tempfile
if sys.version_info.major > 2:
    string_types = str
    unicode = str

    import io
    StringIO = io.StringIO
    Buffer = lambda x=None: io.TextIOWrapper(io.StringIO(x))
else:  # pragma: no cover
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
        if cmdlist and cmdlist[0] == '--':
            cmdlist = cmdlist[1:]
        if not cmdlist:
            return cmdlist
        binname = cmdlist[0]
        find_executable = False
        if '/' not in binname:
            find_executable = True
        if find_executable is False:
            return cmdlist
        else:
            binpath = shutil.which(binname)
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

    if sys.version_info.major < 3:  # pragma: no cover
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
        try:
            retcode = conf.cmd.run(args, join_args=' ')
        except OSError as e:
            if e.errno == errno.E2BIG:
                print(
                    "Error: Argument list too long."
                    " Did you mean to use --each (runs the command once per line)?",
                    file=stderr)
                return RET_ERR_IN_A_SUBCOMMAND
            raise
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
    else:  # pragma: no cover
        log.info(conf.cmd)
        log.info(args)
    return retcode


import unittest
from unittest.mock import patch

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
        _ = stdin.readlines()
        stdin.seek(0)
        retcode = main(argv=cmd, stdin=stdin)
        self.assertEqual(retcode, 0)
        return retcode


class TestElFindPrint0(unittest.TestCase):
    """
    Tests for: find . -print0 | el -0 [-v] -x <cmd>

    Fixture mirrors:
        mkdir test; cd "$_"
        touch "test "$'\n'"12.txt"

    subprocess.call and shutil.which are mocked so no real
    processes are spawned and the binary-lookup path is deterministic.
    """

    def setUp(self):
        self.tmpdir = tempfile.mkdtemp()
        # filename with embedded newline: touch "test "$'\n'"12.txt"
        self.filename = 'test \n12.txt'
        filepath = os.path.join(self.tmpdir, self.filename)
        open(filepath, 'w').close()
        # Simulate `find . -print0` output for a single entry.
        # No trailing \0 so split('\0') yields exactly one non-empty path.
        self.relpath = './' + self.filename
        self.stdin_content = self.relpath

    def tearDown(self):
        shutil.rmtree(self.tmpdir, ignore_errors=True)

    def _run_case(self, argv, expected_call_args):
        stdin = StringIO(self.stdin_content)
        with patch('subprocess.call', return_value=0) as mock_call, \
             patch('shutil.which', side_effect=lambda x: x):
            retcode = main(argv=argv[:], stdin=stdin)
        self.assertEqual(retcode, 0)
        mock_call.assert_called_once()
        actual_args = mock_call.call_args[0][0]
        self.assertEqual(actual_args, expected_call_args)

    def test_find_print0_cases(self):
        p = self.relpath          # './test \n12.txt'  (\n = real newline)
        args1 = [p]               # split('\0') of stdin_content
        joined = ' '.join(args1)  # same as p for single entry

        cases = [
            # find . -print0 | el -0 -v -x echo
            (
                ['-0', '-v', '-x', 'echo'],
                ['echo', p],
            ),
            # find . -print0 | el -0 -v -x echo "{0} #"
            (
                ['-0', '-v', '-x', 'echo', '{0} #'],
                ['echo', joined + ' #'],
            ),
            # find . -print0 | el -0 -v -x echo '"{0}" #'
            (
                ['-0', '-v', '-x', 'echo', '"{0}" #'],
                ['echo', '"' + joined + '" #'],
            ),
            # find . -print0 | el -0 -x sh -x -c 'echo "{0} #"'
            (
                ['-0', '-x', 'sh', '-x', '-c', 'echo "{0} #"'],
                ['sh', '-x', '-c', 'echo "' + joined + ' #"'],
            ),
            # find . -print0 | el -0 -x -- sh -c 'set -x: echo "{0} #"'
            (
                ['-0', '-x', '--', 'sh', '-c', 'set -x: echo "{0} #"'],
                ['sh', '-c', 'set -x: echo "' + joined + ' #"'],
            ),
        ]

        for argv, expected_call_args in cases:
            label = 'el ' + ' '.join(
                repr(a) if ('\n' in a or ' ' in a) else a
                for a in argv
            )
            with self.subTest(cmd=label):
                self._run_case(argv, expected_call_args)


class TestElCoverage(unittest.TestCase):
    """Tests targeting previously uncovered lines."""

    def test_cmd_none_cmdlist(self):
        # set_cmdlist: cmdlist is None → [] (line 124)
        c = Cmd(None)
        self.assertEqual(c.cmdlist, [])

    def test_cmd_str(self):
        # Cmd.__str__ (line 130)
        c = Cmd(['echo'])
        self.assertIn('echo', str(c))

    def test_cmd_process_cmd_empty_after_dashdash(self):
        # _process_cmd: empty list after stripping -- (line 140)
        c = Cmd(['--'])
        self.assertEqual(c.cmd, [])

    def test_cmd_process_cmd_absolute_path(self):
        # _process_cmd: '/' in binname → return cmdlist unchanged (line 146)
        c = Cmd(['/usr/bin/echo'])
        self.assertEqual(c.cmd, ['/usr/bin/echo'])

    def test_cmd_process_cmd_not_found(self):
        # _process_cmd: raise when shutil.which returns None (line 150)
        with patch('shutil.which', return_value=None):
            with self.assertRaises(Exception):
                Cmd(['nonexistent_xyz_binary'])

    def test_render_cmd_no_join_args_embedded_token(self):
        # _render_cmd_iter: argstr = args when join_args is None
        # and token embeds {0} but is not exactly {0} (line 199)
        result = Cmd._render_cmd(['cmd', 'pre_{0}_suf'], ['val'], join_args=None)
        self.assertEqual(result, ['cmd', "pre_['val']_suf"])

    def test_main_argv_none(self):
        # main: argv is None → _argv = argv = [] (line 297)
        retcode = main(argv=None, stdin=StringIO(''), stderr=StringIO())
        self.assertEqual(retcode, RET_ERR_ARGS_EXPECTED)

    def test_main_x_shlex_error(self):
        # main: shlex.split raises ValueError (lines 318-321)
        with self.assertRaises(ValueError):
            main(argv=['-x', "'unclosed"], stdin=StringIO(''))

    def test_main_double_verbose(self):
        # main: -v -v sets DEBUG logging (lines 336-339)
        with patch('subprocess.call', return_value=0), \
             patch('shutil.which', side_effect=lambda x: x):
            retcode = main(argv=['-v', '-v', '-x', 'echo'],
                           stdin=StringIO('file\n'))
        self.assertEqual(retcode, 0)

    def test_main_t_flag(self):
        # main: -t flag invokes unittest.main (lines 342-343)
        with patch('unittest.main', return_value=0) as m:
            retcode = main(argv=['-t'])
        m.assert_called_once()
        self.assertEqual(retcode, 0)

    def test_main_editor_flag(self):
        # main: -e → OpenEditorCmd.__init__ (260), preprocess_args no-+ path
        # (249-250, 282, 284), -e branch (347-348)
        stdin = StringIO('README.md\n')
        with patch('subprocess.call', return_value=0), \
             patch.object(OpenEditorCmd, 'get_editor_cmdlist',
                          return_value=['echo']):
            retcode = main(argv=['-e'], stdin=stdin)
        self.assertEqual(retcode, 0)

    def test_open_editor_get_cmdlist_with_editor_(self):
        # OpenEditorCmd.get_editor_cmdlist: EDITOR_ set (lines 264-275)
        with patch.dict(os.environ, {'EDITOR_': 'code -w'}):
            result = OpenEditorCmd.get_editor_cmdlist()
        self.assertEqual(result, ['code', '-w'])

    def test_open_editor_get_cmdlist_no_editor(self):
        # OpenEditorCmd.get_editor_cmdlist: no editor → RET_ERR_EDITOR (271-272)
        with patch.object(os, 'environ', {}):
            result = OpenEditorCmd.get_editor_cmdlist()
        self.assertEqual(result, RET_ERR_EDITOR)

    def test_open_editor_cmd_preprocess_plus_arg(self):
        # OpenEditorCmd.preprocess_args: args[0] starts with + (lines 282-284)
        with patch.object(os, 'environ', {'EDITOR': 'vi'}):
            cmd = OpenEditorCmd()
        result = cmd.preprocess_args(['+123 README.md'])
        self.assertEqual(result, ['+123', 'README.md'])

    def test_main_each_flag(self):
        # main: --each → one_at_a_time, iter(lines) (lines 362-365, 388, 404-410)
        with patch('subprocess.call', return_value=0), \
             patch('shutil.which', side_effect=lambda x: x):
            retcode = main(argv=['--each', '-x', 'echo'],
                           stdin=StringIO('file1\nfile2\n'))
        self.assertEqual(retcode, 0)

    def test_main_map_flag(self):
        # main: --map (second loop iteration in --each/--map check, lines 362-365)
        with patch('subprocess.call', return_value=0), \
             patch('shutil.which', side_effect=lambda x: x):
            retcode = main(argv=['--map', '-x', 'echo'],
                           stdin=StringIO('file1\n'))
        self.assertEqual(retcode, 0)

    def test_main_force_flag(self):
        # main: -f → stop_on_error = False (line 369)
        with patch('subprocess.call', return_value=0), \
             patch('shutil.which', side_effect=lambda x: x):
            retcode = main(argv=['-f', '--each', '-x', 'echo'],
                           stdin=StringIO('file\n'))
        self.assertEqual(retcode, 0)

    def test_main_stop_on_error_flag(self):
        # main: --stop-on-error → stop_on_error = True (line 371)
        with patch('subprocess.call', return_value=0), \
             patch('shutil.which', side_effect=lambda x: x):
            retcode = main(argv=['--stop-on-error', '--each', '-x', 'echo'],
                           stdin=StringIO('file\n'))
        self.assertEqual(retcode, 0)

    def test_main_e2big(self):
        # main: OSError(E2BIG) in all_at_once → helpful message + RET_ERR (396-402)
        err = OSError(errno.E2BIG, 'Argument list too long')
        with patch('subprocess.call', side_effect=err), \
             patch('shutil.which', side_effect=lambda x: x):
            retcode = main(argv=['-x', 'echo'],
                           stdin=StringIO('file\n'),
                           stderr=StringIO())
        self.assertEqual(retcode, RET_ERR_IN_A_SUBCOMMAND)

    def test_main_oserror_non_e2big_reraises(self):
        # main: non-E2BIG OSError is re-raised (line 403)
        err = OSError(errno.ENOENT, 'No such file')
        with patch('subprocess.call', side_effect=err), \
             patch('shutil.which', side_effect=lambda x: x):
            with self.assertRaises(OSError):
                main(argv=['-x', 'echo'], stdin=StringIO('file\n'))

    def test_main_each_command_fails_stop(self):
        # main: one_at_a_time, failure stops on first error (lines 404-418)
        with patch('subprocess.call', return_value=1), \
             patch('shutil.which', side_effect=lambda x: x):
            retcode = main(argv=['--each', '-x', 'false'],
                           stdin=StringIO('file1\nfile2\n'),
                           stderr=StringIO())
        self.assertEqual(retcode, RET_ERR_IN_A_SUBCOMMAND)

    def test_main_each_command_fails_force_continues(self):
        # main: one_at_a_time with -f, processes all files despite errors (411-413)
        with patch('subprocess.call', return_value=1), \
             patch('shutil.which', side_effect=lambda x: x):
            retcode = main(argv=['--each', '-f', '-x', 'false'],
                           stdin=StringIO('file1\nfile2\n'),
                           stderr=StringIO())
        self.assertEqual(retcode, RET_ERR_IN_A_SUBCOMMAND)


if __name__ == "__main__":  # pragma: no cover
    if '--TEST' in sys.argv:
        sys.argv.remove('--TEST')
        sys.exit(unittest.main())
    sys.exit(main(argv=sys.argv))
