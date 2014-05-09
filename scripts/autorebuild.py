#!/usr/bin/env python
# encoding: utf-8
from __future__ import print_function
#
# Usage:
#   ./autocompile.py path ext1,ext2,extn cmd
#
# Blocks monitoring |path| and its subdirectories for modifications on
# files ending with suffix |extk|. Run |cmd| each time a modification
# is detected. |cmd| is optional and defaults to 'make'.
#
# Example:
#   ./autocompile.py /my-latex-document-dir .tex,.bib "make pdf"
#
# Dependencies:
#   Linux, Python 2.6, Pyinotify
#
import subprocess
import pyinotify
import logging
log = logging.getLogger('.')


class OnWriteHandler(pyinotify.ProcessEvent):
    def my_init(self, cwd, extensions, cmd):
        self.cwd = cwd
        self.extensions = extensions
        self.cmd = cmd

    def _run_cmd(self):
        log.info('')
        log.info('==> Modification detected')
        log.info('')
        subprocess.call(self.cmd.split(' '), cwd=self.cwd)

    def process_IN_MODIFY(self, event):
        # filesystem change event signal
        # log all filesystem events
        log.debug(event)
        if all(not event.pathname.endswith(ext) for ext in self.extensions):
            return
        self._run_cmd()

def auto_compile(path, extensions, cmd):
    wm = pyinotify.WatchManager()
    handler = OnWriteHandler(
                cwd=path,
                extensions=extensions,
                cmd=cmd)
    notifier = pyinotify.Notifier(wm, default_proc_fun=handler)
    wm.add_watch(path, pyinotify.ALL_EVENTS, rec=True, auto_add=True)
    log.info("PATH=%r", path)
    log.info("EXTENSIONS=%r", extensions)
    log.info("CMD=%r", cmd)
    log.info('Start monitoring %r (type C^c to exit)', path)
    notifier.loop()


DEFAULT_EXTENSIONS = ".py,.rst,.md,.html,.-restart"
DEFAULT_CMD = "make"
def main():
    import optparse
    import logging
    import sys

    prs = optparse.OptionParser(usage="./%prog : args")

    prs.add_option('-p','--path',
                    help="path to monitor [$(pwd)]",
                    dest='path')
    prs.add_option('-x','--extensions',
                    help="file extensions to include [%r]" % DEFAULT_EXTENSIONS,
                    default=DEFAULT_EXTENSIONS,
                    dest='extensions')
    prs.add_option("-c",'--cmd',
                    help="command to run [%r]" % DEFAULT_CMD,
                    default=DEFAULT_CMD,
                    dest='cmd')

    prs.add_option('-v', '--verbose',
                    dest='verbose',
                    action='store_true',)
    prs.add_option('-q', '--quiet',
                    dest='quiet',
                    action='store_true',)
    prs.add_option('-t', '--test',
                    dest='run_tests',
                    action='store_true',)

    (opts, args) = prs.parse_args()

    if not opts.quiet:
        logging.basicConfig(
            level=logging.DEBUG,
            #format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s',
            format='%(asctime)s %(name)s %(levelname)-4s : %(message)s',
            #datefmt='%Y-%m-%d %H:%M:%S',
            #filename='/temp/myapp.log',
            #filemode='w',
            )

        if opts.verbose:
            logging.getLogger().setLevel(logging.DEBUG)

    if opts.run_tests:
        sys.argv = [sys.argv[0]] + args
        import unittest
        sys.exit(unittest.main())

    if not (opts.path and opts.cmd):
        prs.print_help()

    extensions = opts.extensions.split(',')

    # Blocks monitoring
    auto_compile(opts.path, extensions, opts.cmd)


if __name__ == "__main__":
    import sys
    sys.exit(main())

