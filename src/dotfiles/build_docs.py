#!/usr/bin/env python
# encoding: utf-8
from __future__ import print_function


import os
import sys
import subprocess
from itertools import ifilter, imap
import logging

logging.basicConfig()
loglevel = logging.DEBUG

log = logging.getLogger('__')
log.setLevel(loglevel)

print(log.handlers)
if log.handlers:
    log.handlers[0].formatter = logging.Formatter("%(name).%(levelname): %(message)s")

def cd(path):
    log.debug("cd %s" % path)
    os.chdir(path)

def cmd(_cmd, *args, **kwargs):
    #kwargs['output'] = True
    log.debug(_cmd)
    if hasattr(_cmd, '__iter__'):
        _cmdstr = ' '.join(str(a) for a in args)
    else:
        _cmdstr = str(_cmd)
    log.debug(_cmdstr)

    process = subprocess.Popen(_cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            *args,
            **kwargs)

    stdout, stderr = process.stdout, process.stderr
    #process.communicate()
    if process.returncode:
        print(stdout)
        print(stderr)
        # TODO
        raise Exception("subprocess return code: %s" % process.returncode)

    def process_stdout(stdout):
        for l in imap(str.rstrip, stdout): #.split('\n'):
            log.debug(l)
            yield l

    # stderr --> ?
    return process_stdout(stdout) # 2tf??

def remove_whitespace(lineiterable):
    return ifilter(bool,
                imap(str.strip,
                    lineiterable))
    #(s.strip() for s in stdout)


try:
    import sphinx
except ImportError:
    print("Error importing sphinx")
    class SphinxMock(object):
        def main(*args, **kwargs):
            print(*args, **kwargs)
    sphinx = SphinxMock()
import re
#import pexpect

class SphinxMultipleBuilder(object):
    def __init__(self, output=None, fail_on_error=True):
        self.output = output or sys.sdtout
        self.fail_on_error = fail_on_error
        self.success = []
        self.fail = []
        self.no_makefile = []

    def _write(self, x):
        print(x, file=self.output)

    def build_docs(self, dest_docroot='/srv/repos/var/www/docs',
                        docindex=None):
        """
        For each conf.py file* , attempt to run
        'make html' or
        'sphinx-build'

        rsync output into /docs
        """
        fail_on_error = self.fail_on_error

        success = self.success
        toc = []
        fail = self.fail
        no_makefile = self.no_makefile

        docindex = docindex or os.path.join(dest_docroot, 'index.html')

        f = open(docindex, 'w')
        f.write('<html><head><body>')

        here = os.getcwd()
        for conf_path in cmd( ("find", ".",
                                "-type" , "f",
                                "-maxdepth", "4",
                                "-wholename", "*[d|D]oc*/conf.py")):
            if 'sphinx-contrib' in conf_path:
                continue
            conf_path = conf_path.strip()
            log.debug("-----------------------")
            log.debug("conf file: %r" % conf_path)
            conf_dir = os.path.dirname(conf_path)
            log.debug("conf dir : %s" % conf_dir)

            # CD to the conf_dir
            cd(os.path.join(here, conf_dir))

            # TODO: nested confs
            appname = conf_dir.split(os.path.sep)[1] # -2?
            if appname == ".":
                appname = os.path.dirname(os.path.abspath(appname))
                raise Exception()
            log.debug("app name: %s" % appname)

            # Path where docs will be sphinx-builded-to
            build_path = os.path.join(conf_dir, '_htmldocs')
            # Path where a manual docs build resides
            manual_build_path = os.path.join(
                    os.path.dirname(conf_dir), 'build/html')
            # Path where docs will be rsynced to after build
            dest_path = os.path.join(dest_docroot, appname)

            ret = None

            if manual_build_path:
                ret = 0
                build_path = manual_build_path
            else:
                has_makefile = os.path.exists("Makefile")
                if not has_makefile:
                    has_makefile = os.path.exists("../Makefile")
                    cd('..')
                if has_makefile:
                    self.output.write(conf_dir)
                    try:
                        #cmd( ("make", "clean") )
                        for line in cmd( ("make", "html",) ):
                            rgx = re.compile(r"Build finished. The HTML pages are in (.*)\.")
                            linematch = rgx.match(line)
                            if linematch: # success
                                build_path = linematch.groups()[0]
                                ret = 0
                                break
                            elif line.startswith("Exception ocurred"):
                                ret = 1
                                raise Exception(line)
                    except Exception, e:
                        log.error(e)
                        continue
                    except KeyboardInterrupt, e:
                        exit()
                        raise

                else:
                    no_makefile.append( (appname, conf_path) )
                    toc.append((appname, dest_path ))
                    try:
                        os.makedirs(dest_path)
                    except OSError, e:
                        pass
                    try:
                        sphinx_cmd = ("sphinx-build",
                                            #"-a", # write all new files
                                            #"-E", # dont use a saved environment
                                            "-b","html",
                                            '-D html_theme=default',
                                            '-D html_show_sourcelink=True',
                                            '-D html_show_sphinx=False',
                                            '-P', # run pdb on exception
                                            os.path.join(here, conf_dir).replace('/./','/'),
                                            os.path.join(here, build_path,).replace('/./','/'))
                        log.debug(sphinx_cmd)
                        ret = sphinx.main(sphinx_cmd)
                    except KeyboardInterrupt, e:
                        exit()
                        raise
                    except Exception, e:
                        #os.rmdir(dest_path)
                        log.error(e)
                        if fail_on_error:
                            raise
                        ret = 1

                    #p = pexpect.spawn("make html")
                    #i = p.expect(['Build finished. The HTML pages are in \(.*\)$', 'fail'])

            if ret == 0:
                success.append( (appname, dest_path) )
                self._write('<li>win: %s <a href="/docs/%s">%s</a></li>' % (has_makefile and 'makefile' or '', appname, appname))
                log.info(conf_path)

                CMD = ("rsync",
                        "-a",
                        "-v",
                        "-r",
                        "-p",
                        "%s/" % build_path,
                        dest_path)

                log.debug(u' '.join(CMD))
                for line in cmd(CMD):
                    log.debug(line,      )
            elif ret == 1:
                fail.append( (appname, dest_path) )
                self._write('<li>fail: %s <a href="/docs/%s">%s</a></li>' % (has_makefile and 'makefile' or '', appname, appname))
                log.error("# build failed: %s" % conf_path)

            cd(here)

        self._write("</ul>")


    def build_doc_index(self, output=None):
        output = output or self._write
        success = self.success
        toc = self.toc
        fail = self.fail
        for p in cmd("find . -type d -name html | grep -v '.hg' | grep doc"):
            output(p)
            #cmd("cp -Rv %r" % os.path.join(p))
            output("<h2>Summary</h2>")
            output("<ul>")
            output("<h1>Success</h1>")
            for item in success:
                output('<li><a href="/docs/{0}">{0}</a></li>'.format(*item))
            output("</ul>")

            output("<ul>")
            output("<h1>TOC</h1>")
            for item in toc:
                output('<li><a href="/docs/{0}">{0}</a></li>'.format(*item))
            output("</ul>")

            output("<ul>")
            output("<h1>Failed</h1>")
            for item in fail:
                output('<li><a href="/docs/{0}">{0}</a></li>'.format(*item))
            output("</ul>")

build_errors = """

failed to import: setup.py install w/ build script?

no such config value: numpydoc_use_plots

    ... , pastedeploy,

no such config value: pngmath_use_previe

matplotlib:
     module object has no attribute __version__numpy__

milk:
    ImportError: cannot import name __version__ (from milk import __version__)

gunicorn:
    IOError: [Errno 2] No such file or directory: '/src/gunicorn.git/doc/_htmldocs/.doctrees/contents.doctree'

pandas:
    ImportError: C extensions not built: if you installed already verify that you are not importing from the source directory

virtualenvwrapper:
    version = subprocess.check_output(['sh', '-c', 'cd ../..; python setup.py --version'])


formencode:
    importerror: formencode (autodoc)

virtuoso:
    distribution not found

zeromq:
    importerror: greenlet

eventlet:
    importerror:

rdflib:
    importerror

rdfextras:
    importerror

SOLUTIONS:
    resolve_doc_build_importerror

    check for _htmldocs_manualbuild

"""

def resolve_doc_build_importerror(sourcepath):
    try:
        pass
    except ImportError:
        # add module to path?

        try:
            pass
        except ImportError:
            try:
                # mkvirtualenv ; setup.py develop/install;
                pass
            except Exception: #SetupError:
                raise


import unittest
class Test_build_docs(unittest.TestCase):
    def test_build_docs(self):
        pass


def main():
    import optparse

    prs = optparse.OptionParser(usage="./%prog : args")

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
        logging.basicConfig()

        if opts.verbose:
            logging.getLogger().setLevel(logging.DEBUG)

        import copy
        class LogLevelColorConsoleHandler( logging.StreamHandler ):
            def emit( self, record ):
                # Need to make a actual copy of the record
                # to prevent altering the message for other loggers
                myrecord = copy.copy( record )
                levelno = myrecord.levelno
                if( levelno >= 50 ): # CRITICAL / FATAL
                    color = '\x1b[31m' # red
                elif( levelno >= 40 ): # ERROR
                    color = '\x1b[31m' # red
                elif( levelno >= 30 ): # WARNING
                    color = '\x1b[33m' # yellow
                elif( levelno >= 20 ): # INFO
                    color = '\x1b[32m' # green
                elif( levelno >= 10 ): # DEBUG
                    color = '\x1b[35m' # pink
                else: # NOTSET and anything else
                    color = '\x1b[0m' # normal
                myrecord.msg = ''.join((color, str (myrecord.msg ), '\x1b[0m'))  # normal
                logging.StreamHandler.emit( self, myrecord )

        #LogLevelColorConsoleHandler.level = loglevel
        #LogLevelColorConsoleHandler.formatter = logging.Formatter("%(name).%(levelname): %(message)s")
        #log.addHandler(LogLevelColorConsoleHandler())

        class FileLogHandler:
            def __init__(self, level, log=None):
                self.log = logging.getLogger(log)
                self.log.setLevel(level)
                self.log.addHandler(LogLevelColorConsoleHandler())
                self.level = level

            def write(self, line):
                self.log.log(self.level, line.rstrip('\r\n'))

            def flush(self):
                pass
                #self.log.debug("<flush>")

        sys.stdout = FileLogHandler(logging.DEBUG, '>>')
        #sys.stderr = FileLogHandler(logging.ERROR, '!!')

    if opts.run_tests:
        sys.argv = [sys.argv[0]] + args
        exit(unittest.main())

    builder = SphinxMultipleBuilder(
                output=file('/srv/repos/docs/index.html','w')
                )
    builder.build_docs()

if __name__ == "__main__":
    main()

