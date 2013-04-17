#!/usr/bin/env python
# encoding: utf-8
from __future__ import print_function
"""
venv

- set variables for standard paths in the environment dict
- define IPython aliases
- serialize variables and aliases to

  - IPython configuration (variables, aliases)
  - Bash/zsh configuration (variables, aliases, macros)
  - JSON (variables, aliases)

"""

from collections import OrderedDict
from os.path import join as joinpath
from sys import version_info
import logging
import os
import site
import sys

class IPYMock(object):
    """ TODO:
    #from IPython.core import ipapi """
    def system(self, *args, **kwargs):
        print(args, kwargs)

    def magic(self, *args, **kwargs):
        print(args, kwargs)

pyver = 'python%d.%d' % version_info[:2]
log = logging.getLogger('Venv')

class Env(OrderedDict):
    osenviron_keys = (
    'DOCSHTML',
    'DOTFILES',
    'PAGER',
    'PROJECTS',
    'USRLOG',
    'VIMBIN',
    'VIRTUAL_ENV',
    'VIRTUAL_ENV_NAME',
    'WORKON_HOME',
    'WORKSPACE',
    '_APP',
    '_BIN',
    '_CFG',
    '_ETC',
    '_LIB',
    '_LOG',
    '_MNT',
    '_OPT',
    '_PYLIB',
    '_PYSITE',
    '_SRC',
    '_SRV',
    '_VAR',
    '_WRD',
    '_WRD_SETUPY',
    '_WWW',
    '__SRC',
    '_src'
    )
    def __getattribute__(self, attr):
        return dict.__getattribute__(self, attr)

    @classmethod
    def from_environ(cls, environ):
        return cls((k,environ.get(k,'')) for k in cls.osenviron_keys)

    def set_standard_paths(env, prefix):
        """set variables for standard paths in the environment

        see:

        - https://en.wikipedia.org/wiki/Unix_directory_structure
        - https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard
        """
        #
        env['_BIN']         = joinpath(prefix,  "bin")       # ./bin
        env['_ETC']         = joinpath(prefix,  "etc")       # ./etc
        env['_ETCOPT']      = joinpath(prefix,  "etc/opt")   # ./etc/opt
        env['_HOME']        = joinpath(prefix,  "home")      # ./home
        env['_ROOT']        = joinpath(prefix,  "root")      # ./root
        env['_LIB']         = joinpath(prefix,  "lib")       # ./lib
        env['_PYLIB']       = joinpath(prefix,  "lib", pyver)# ./lib/pythonN.N
        env['_PYSITE']      = joinpath(prefix,  "lib", pyver, 'site-packages')
        env['_MNT']         = joinpath(prefix,  "mnt")       # ./mnt
        env['_MEDIA']       = joinpath(prefix,  "media")     # ./media
        env['_OPT']         = joinpath(prefix,  "opt")       # ./opt
        env['_SBIN']        = joinpath(prefix,  "sbin")      # ./sbin
        env['_SRC']         = joinpath(prefix,  "src")       # ./src
        env['_SRV']         = joinpath(prefix,  "srv")       # ./srv
        env['_TMP']         = joinpath(prefix,  "tmp")       # ./tmp
        env['_USR']         = joinpath(prefix,  "usr")       # ./usr
        env['_USRBIN']      = joinpath(prefix,  "usr/bin")   # ./usr/bin
        env['_USRINCLUDE']  = joinpath(prefix,  "usr/include") # ./usr/include
        env['_USRLIB']      = joinpath(prefix,  "usr/lib")   # ./usr/lib
        env['_USRLOCAL']    = joinpath(prefix,  "usr/local") # ./usr/local
        env['_USRSBIN']     = joinpath(prefix,  "usr/sbin")  # ./usr/sbin
        env['_USRSHARE']    = joinpath(prefix,  "usr/share") # ./usr/share
        env['_USRSRC']      = joinpath(prefix,  "usr/src")   # ./usr/src
        env['_VAR']         = joinpath(prefix,  "var")       # ./var
        env['_VARCACHE']    = joinpath(prefix,  "var/cache") # ./var/cache
        env['_VARLIB']      = joinpath(prefix,  "var/lib")   # ./var/lib
        env['_VARLOCK']     = joinpath(prefix,  "var/lock")  # ./var/lock
        env['_LOG']         = joinpath(prefix,  "var/log")   # ./var/log
        env['_VARMAIL']     = joinpath(prefix,  "var/mail")  # ./var/mail
        env['_VAROPT']      = joinpath(prefix,  "var/opt")   # ./var/opt
        env['_VARRUN']      = joinpath(prefix,  "var/run")   # ./var/run
        env['_VARSPOOL']    = joinpath(prefix,  "var/spool") # ./var/spool
        env['_VARTMP']      = joinpath(prefix,  "var/tmp")   # ./var/tmp
        env['_WWW']         = joinpath(prefix, "var/www")      # ./var/www
        # TODO: /srv/www | /var/www | /var/ww | /var/www/html

    def paths_to_variables(self, _path):
        compress = sorted( ((k,v) for (k,v) in self.iteritems()
                                            if isinstance(v,basestring)
                                            and v.startswith('/')),
                            key=lambda v: (len(v[1]), v[0]),
                            reverse=True)
        for varname, value in compress:
            _path = _path.replace(value, '${%s}' % varname)
        return _path

def shell_quote(_str):
    # TODO
    _repr = repr(_str)
    if _repr.startswith('\''):
        return "\"%s\"" % _repr[1:-1]
    #return repr(_str).replace("\'", "\"")


class Venv(object):
    """Virtual environment
    """

    @staticmethod
    def get_virtualenv_path(virtualenv=None, from_environ=False):
        _virtualenv = None
        if virtualenv is None:
            if from_environ:
                _virtualenv = os.environ.get('VIRTUAL_ENV')
            else:
                log.error("Virtualenv not specified")
        else:
            if '/' not in virtualenv:
                _virtualenv = joinpath(
                                os.environ['WORKON_HOME'],
                                virtualenv)
            else:
                _virtualenv = virtualenv

        if _virtualenv and not os.path.exists(_virtualenv):
            log.debug("virtualenv %r does not exist" % _virtualenv)

        return _virtualenv


    def __init__(self, virtualenv=None, appname=None,
                    env=None,
                    from_environ=False,
                    open_editors=False,
                    open_terminals=False,
                    dont_reflect=True):
        self.log = logging.getLogger('venv.%s' % appname)

        virtualenv = self.get_virtualenv_path(virtualenv,
                                            from_environ=from_environ)
        if virtualenv is None:
            raise Exception("must specify a VIRTUAL_ENV")
        else:
            self.virtualenv = virtualenv

        self.name = os.path.basename(virtualenv)

        if appname is None:
            appname = self.name
            apppath = joinpath(virtualenv, 'src', appname) #
            if not os.path.exists(apppath):
                logging.debug("apppath %r does not exist" % apppath)
                # TODO

        if appname is None:
            appname = os.path.basename(virtualenv)

        self.appname = appname
        self.log = logging.getLogger('venv.%s' % appname)

        if env and from_environ:
            raise Exception()

        if from_environ:
            self.env = Env.from_environ(os.environ)
        else:
            if env is None:
                self.env = Env()
            else:
                self.env = env

        env = self.env
        env['VIRTUAL_ENV']      = self.virtualenv
        env['VIRTUAL_ENV_NAME'] = self.name

        env.set_standard_paths(self.virtualenv)

        env['_USRLOG']  = joinpath(self.virtualenv, ".usrlog")
        env['HISTFILE'] = joinpath(self.virtualenv, ".bash_history")
        env['HISTSIZE']         = 1000000
        env['HISTFILESIZE']     = 1000000
        # env['HISTTIMEFORMAT']   = "%F %T " # see .usrlog
        env['PAGER']            = '/usr/bin/less -r'

        env['_APP']     = self.appname
        env['_WRD']     = joinpath(env['_SRC'], self.appname)    # working directory

        self.aliases = self.get_user_aliases_base()
        self.aliases.update(self.get_user_aliases(dont_reflect=dont_reflect))

        if open_editors:
            self.open_editors()

        if open_terminals:
            self.open_terminals()

    @staticmethod
    def _configure_sys(env=None, from_environ=False):
        if from_environ:
            env = Env.from_environ(os.environ)
        env['_PYLIB']  = joinpath(env['_LIB'], pyver)
        env['_PYSITE'] = joinpath(env['_PYLIB'], 'site-packages')
        if not os.path.exists(
                         joinpath(env['_PYLIB'],
                             'no-global-site-packages.txt')):
            sys_libdir = joinpath("/usr/lib", pyver)
            sys.path = [joinpath(sys_libdir, p) for p in (
                        "", "plat-linux2", "lib-tk", "lib-dynload")]
            #sys.path.extend(
            #    (p for p in sys.path if p.startswith(env['VIRTUAL_ENV']) ) )

            # TODO
            ipython_extensions = (
                '/usr/local/lib/%s/dist-packages/IPython/extensions'
                                % pyver)
            if not os.path.exists(ipython_extensions):
                log.info("IPython extensions not found: %r"
                                                    % ipython_extensions)
            if ipython_extensions not in sys.path:
                sys.path.append(ipython_extensions)

        #optimize_python_path(sys.path)

        site.addsitedir(env['_PYSITE'])
        return sys.path

    def configure_sys(self):
        return Venv._configure_sys(self.env)

    def get_user_aliases_base(self):
        aliases = OrderedDict()
        env = self.env

        aliases['gvim']     = env.get('_EDIT_', 'gvim') # TODO: render-time
        aliases['_edit']    = env.get('_EDIT_', 'gvim')

        aliases['cdb']      = 'cd {_BIN}/%l'.format(
                                    _BIN=shell_quote(env['_BIN']))
        aliases['cde']      = 'cd {_ETC}/%l'.format(
                                    _ETC=shell_quote(env['_ETC']))
        aliases['cdv']      = 'cd {VIRTUAL_ENV}/%l'.format(
                                    VIRTUAL_ENV=shell_quote(env['VIRTUAL_ENV']))
        aliases['cdvar']    = 'cd {_VAR}/%l'.format(
                                    _VAR=shell_quote(env['_VAR']))
        aliases['cdlog']    = 'cd {_LOG}/%l'.format(
                                    _LOG=shell_quote(env['_LOG']))
        aliases['cdww']     = 'cd {_WWW}/%l'.format(
                                    _WWW=shell_quote(env['_WWW']))
        aliases['cdl']      = 'cd {_LIB}/%l'.format(
                                    _LIB=shell_quote(env['_LIB']))
        aliases['cdpylib']  = 'cd {_PYLIB}/%l'.format(
                                    _PYLIB=shell_quote(env['_PYLIB']))
        aliases['cdpysite'] = 'cd {_PYSITE}/%l'.format(
                                    _PYSITE=shell_quote(env['_PYSITE']))
        aliases['cds']      = 'cd {_SRC}/%l'.format(
                                    _SRC=shell_quote(env['_SRC']))

        aliases['cdhelp']   =  "set | grep '^cd.*()' | cut -f1 -d' ' #%l"
        return aliases

    def get_user_aliases(self, dont_reflect=False):
        aliases = OrderedDict()
        env = self.env

        env['_EDIT_']       = 'gvim --servername %s --remote-tab-silent' % (
                                                    shell_quote(self.appname))
        aliases['_edit']    = env['_EDIT_']
        aliases['_gvim']    = env['_EDIT_']

        env['_IPSESSKEY']   = joinpath(env['_SRC'], '.sessionkey')
        env['_NOTEBOOKS']   = joinpath(env['_SRC'], 'notebooks')

        aliases['ip_session'] = ('(python -v -c \"'
                                'import os;'
                                'print os.urandom(128).encode(\'base64\')\"'
                                ' > {_IPSESSKEY} )'
                                ' && chmod 0600 {_IPSESSKEY};'
                                ' # %l'
                                ).format(
                                    _IPSESSKEY=shell_quote(env['_IPSESSKEY']))
        aliases['ipnb']     = ('ipython notebook'
                                ' --secure'
                                ' --Session.keyfile={_IPSESSKEY}'
                                ' --notebook-dir={_NOTEBOOKS}'
                                ' --deep-reload'
                                ' --pylab=inline'
                                ' %l').format(
                                    _IPSESSKEY=shell_quote(env['_IPSESSKEY']),
                                    _NOTEBOOKS=shell_quote(env['_NOTEBOOKS']))

        env['_IPQTLOG']     = joinpath(env['VIRTUAL_ENV'], '.ipqt.log')
        aliases['ipqt']     = ('ipython qtconsole'
                                ' --secure'
                                ' --Session.keyfile={_IPSESSKEY}'
                                ' --pylab=inline'
                                ' --logappend={_IPQTLOG}'
                                ' --deep-reload'
                                #' --gui-completion'
                                #' --existing=${_APP}'
                                ' --pprint'
                                #' --pdb'
                                ' --colors=linux'
                                ' --ConsoleWidget.font_family="Monaco"'
                                ' --ConsoleWidget.font_size=11'
                                ' %l').format(
                                    _IPSESSKEY=shell_quote(env['_IPSESSKEY']),
                                    _APP=shell_quote(env['_APP']),
                                    _IPQTLOG=shell_quote(env['_IPQTLOG']))

        aliases['grinv']    = 'grin --follow %%l %s' % shell_quote(self.virtualenv)
        aliases['grindv']   = 'grind --follow %%l --dirs %s' % shell_quote(self.virtualenv)

        aliases['grins']    = 'grin --follow %%l %s' % shell_quote(env['_SRC'])
        aliases['grinds']   = 'grind --follow %%l --dirs %s' % shell_quote(env['_SRC'])

        appsrc = env['_WRD']
        if os.path.exists(appsrc) or dont_reflect:
            env['_WRD']         = appsrc
            env['_WRD_SETUPY']      = joinpath(appsrc, 'setup.py')
            env['_TEST_']       = "python {_WRD_SETUPY} test".format(
                                    _WRD_SETUPY=shell_quote(env['_WRD_SETUPY'])
                                    )
            aliases['cdw']      = 'cd {_WRD}/%l'.format(
                                        _WRD=shell_quote(env['_WRD'])) # TODO
            aliases['_test']    = env['_TEST_']
            aliases['_tr']      = 'reset && %s' % env['_TEST_']
            aliases['_nose']    = 'nosetests {_WRD}'.format(
                                        _WRD=shell_quote(env['_WRD']))

            aliases['grinw']    = 'grin --follow %l {_WRD}'.format(
                                        _WRD=shell_quote(env['_WRD']))
            aliases['grindw']   = 'grind --follow %l --dirs {_WRD}'.format(
                                        _WRD=shell_quote(env['_WRD']))

            aliases['_glog']    = "hgtk -R {_WRD} log".format(
                                        _WRD=shell_quote(env['_WRD']))
            aliases['_log']     = "hg -R {_WRD} log".format(
                                        _WRD=shell_quote(env['_WRD']))
        else:
            self.log.error('app working directory %r not found' % appsrc)

        appcfg = joinpath(env['_ETC'], 'development.ini')
        if os.path.exists(appcfg) or dont_reflect:
            env['_CFG']         = appcfg
            env['_EDITCFG_']    = "{_EDIT_} {_CFG}".format(
                                    _EDIT_=env['_EDIT_'],
                                    _CFG=shell_quote(env['_CFG']))
            env['_SHELL_']      = "{_BIN}/pshell {_CFG}".format(
                                    _BIN=env['_BIN'],
                                    _CFG=shell_quote(env['_CFG']))
            env['_SERVE_']      =("{_BIN}/pserve"
                                    " --app-name=main"
                                    " --reload"
                                    " --monitor-restart {_CFG}").format(
                                            _BIN=env['_BIN'],
                                            _CFG=shell_quote(env['_CFG']))
            aliases['_serve']   = env['_SERVE_']
            aliases['_shell']   = env['_SHELL_']
            aliases['_editcfg'] = env['_EDITCFG_']
        else:
            self.log.error('app configuration %r not found' % appcfg)

        env['EDITOR']       = env['_EDIT_']
        aliases['_edit']    = env['_EDIT_']
        aliases['_editp']   = "%s %%l" % self._edit_project_cmd # TODO
        aliases['_Make']    = "cd {_WRD} && make".format(
                                    _WRD=shell_quote(env['_WRD'])) # TODO

        svcfg = env.get('_SVCFG', joinpath(env['_ETC'], 'supervisord.conf'))
        if os.path.exists(svcfg) or dont_reflect:
            env['_SVCFG']   = svcfg
            env['_SVCFG_']  = ' -c %s' % shell_quote(svcfg)
        else:
            self.log.error('supervisord configuration %r not found' % svcfg)
            env['_SVCFG_']  = ''
        aliases['ssv']      =    'supervisord{_SVCFG_}'.format(**env)
        aliases['sv']       =    'supervisorctl{_SVCFG_}'.format(**env)
        aliases['svd']      = (( 'supervisorctl{_SVCFG_} restart dev'
                                ' && supervisorctl{_SVCFG_} tail -f dev')
                                .format(**env))
        aliases['svt']      =    'sv tail -f'

        return aliases

    @classmethod
    def workon_project(cls, virtualenv, **kwargs):
        return cls(virtualenv=virtualenv, **kwargs)

    @staticmethod
    def _configure_ipython(c=None, setup_func=None, cd_to_WRD=False):
        if c is None and not in_ipython_config():
            # skip IPython configuration
            log.error("not in_ipython_config")
            return
        c = get_config()
        c.InteractiveShellApp.ignore_old_config=True
        c.InteractiveShellApp.log_level = 20

        c.InteractiveShellApp.extensions = [
            'autoreload',
            'storemagic',
        ]
        try:
            import sympy
            c.InteractiveShellApp.extensions.append('sympyprinting')
        except ImportError, e:
            pass

        try:
            import zmq
            c.InteractiveShellApp.extensions.append('parallelmagic')
        except ImportError, e:
            pass

        c.InteractiveShell.autoreload = True
        c.InteractiveShell.deep_reload = True

        # %store [name]
        c.StoreMagic.autorestore = True

        c.AliasManager.default_aliases = DEFAULT_ALIASES.items()

        if setup_func:
            setup_func(c)

    def configure_ipython(self, *args, **kwargs):
        def setup_func(c):
            c.AliasManager.user_aliases = self.aliases.items()
            c.IPythonWidget.editor = self.env['_EDIT_']
            if 'cd_to_WRD' in kwargs:
                ip = IPYMock()
                ip.magic('cd %r' % self.env['_WRD'])
        return Venv._configure_ipython(*args, setup_func=setup_func, **kwargs)


    def _ipython_alias_to_bash_alias(self, name, alias):
        alias = self.env.paths_to_variables(alias)
        if '%s' in alias or '%l' in alias:
            #alias = '# %s' % alias
            chunks = alias.split('%s')
            _alias = alias[:]
            count = 0
            while '%s' in _alias:
                count += 1
                _alias = _alias.replace('%s', '${%d}' % count, 1)
            _aliasmacro = 'eval \'{cmdname} () {{\n    {aliasfunc}\n}}\';'.format(
                    cmdname=name,
                    aliasfunc=_alias)
            return _aliasmacro.replace('%l', '$@')

        return 'alias %s=%r' % (name, alias)

    def bash_env(self, output=sys.stdout):
        for k,v in self.env.iteritems():
            #print("declare -grx %s=%r" % (k,v), file=output)
            print("declare -gx %s=%r" % (k,v), file=output)

        for k,v in self.aliases.iteritems():
            bash_alias = self._ipython_alias_to_bash_alias(k,v)
            print(bash_alias, file=output)

    @property
    def _project_files(self):
        default_project_files=(
            'README.rst',
            'CHANGES.rst',
            'TODO.rst',
            'Makefile',
            'setup.py',
            'requirements.txt',
            '.hgignore',
            '.gitignore',
            '.hg/hgrc',
            '',
            self.appname,
            'docs',
        )
        return default_project_files

    @property
    def _edit_project_cmd(self):
        return "%s %s" % (
                self.env['_EDIT_'],
                ' '.join(
                        shell_quote(joinpath(self.env['_WRD'], p))
                        for p in (self._project_files))
        )

    @property
    def _terminal_cmd(self):
        return self.env.get('TERMINAL', 'gnome-terminal')

    @property
    def _open_terminals_cmd(self):
        # TODO
        cmd=(
            self._terminal_cmd,
            '--working-directory', self.env['_WRD'],

            '--tab','--title','%s: bash' % self.appname,
                '--command','bash',
            '--tab','--title','%s: serve' % self.appname,
                '--command',
                "bash -c 'we %s %s'; bash" % (self.virtualenv, self.appname), #
            '--tab','--title','%s: shell' % self.appname,
                '--command',
                "bash -c %r; bash" % self.env['_SHELL_']
        )
        return cmd

    def system(self, cmd=None):
        if cmd is None:
            raise Exception()
        if isinstance(cmd, (tuple, list)):
            _cmd = ' '.join(cmd) # TODO
        elif isinstance(cmd, (str,)):
            _cmd = cmd

            os.system(_cmd)

    def open_editors(self):
        cmd = self._edit_project_cmd
        self.system(cmd=cmd)

    def open_terminals(self):
        cmd = self._open_terminals_cmd
        self.system(cmd=cmd)

    def asdict(self):
        return OrderedDict(
            env=self.env,
            aliases=self.aliases)


DEFAULT_ALIASES = OrderedDict((
    ('cdw', 'cd $$WORKON_HOME'),
    ('cdh', 'cd $$HOME'),
    ('bash', 'bash'),
    ('chmodr', 'chmod -R'),
    ('chownr', 'chown -R'),
    ('egrep', 'egrep --color=auto'),
    ('fgrep', 'fgrep --color=auto'),
    ('git', 'git'),
    ('grep', 'grep --color=auto'),
    ('grin', 'grin'),
    ('grind', 'grind'),
    ('grinpath', 'grin --sys-path'),
    ('grindpath', 'grind --sys-path'),
    ('gvim', 'gvim'),
    ('hg', 'hg'),
    ('hgl', 'hg log -l10'),
    ('hgs', 'hg status'),
    ('htop', 'htop'),
    ('ifconfig', 'ifconfig'),
    ('ip','ip'),
    ('la', 'ls --color=auto -A'),
    ('lx', 'ls --color=auto -alZ'),
    ('ll', 'ls --color=auto -aL'),
    ('ls', 'ls --color=auto'),
    ('lt', 'ls --color=auto -altr'),
    ('lxc','lxc'),
    ('ps', 'ps'),
    ('pyline', 'pyline'),
    ('sqlite3', 'sqlite3'),
    ('ssv', 'supervisord'),
    ('stat', 'stat'),
    ('sv', 'supervisorctl'),
    ('t', 'tail -f'),
    ('thg', 'thg'),
    ('top', 'top'),
    ('which', 'which'),
    ('zsh', 'zsh'),
))

def in_ipython_config():
    return 'get_config' in globals()


def ipythonmain():
    venv = None
    if 'VIRTUAL_ENV' in os.environ:
        venv = Venv(from_environ=True)
        venv.configure_ipython()
    else:
        Venv._configure_ipython()

if in_ipython_config():
    ipythonmain()

def ipython_imports():
    from IPython.external.path import path
    from pprint import pprint as pp
    from pprint import pformat as pf
    def ppd(self, *args, **kwargs):
        import json
        print(type(self))
        print(
            json.dumps(*args, indent=2))


import unittest
class Test_env(unittest.TestCase):
    def test_env(self):
        e = Env()
        assert 'WORKON_HOME' not in e

    def test_from_environ(self):
        import os
        e = Env.from_environ(os.environ)
        assert 'WORKON_HOME' in e


class Test_venv(unittest.TestCase):
    TEST_VIRTUALENV = 'dotfiles'
    TEST_APPNAME = 'dotfiles'
    TEST_VIRTUAL_ENV = joinpath(os.environ['WORKON_HOME'], 'dotfiles')

    def test_venv(self):
        venv = Venv(self.TEST_VIRTUALENV)
        assert 'VIRTUAL_ENV' in venv.env
        self.assertEqual(venv.virtualenv, self.TEST_VIRTUAL_ENV)

    def test_venv_appname(self):
        venv = Venv(self.TEST_VIRTUALENV, self.TEST_APPNAME)
        self.assertEqual(venv.appname, self.TEST_APPNAME)

    def test_venv_from_null_environ(self):
        self.failUnlessRaises(Exception, Venv)

    def test_venv_without_environ(self):
        os.environ['VIRTUAL_ENV'] = self.TEST_VIRTUAL_ENV
        self.failUnlessRaises(Exception, Venv)

    def test_venv_with_environ(self):
        os.environ['VIRTUAL_ENV'] = self.TEST_VIRTUAL_ENV
        venv = Venv(from_environ=True)


def main():
    import optparse
    import logging

    prs = optparse.OptionParser(
        usage="./%prog [-b] [-t] [-e] [-E|<virtualenv>] [appname]")

    prs.add_option('-E', '--from-shell-environ',
                    dest='load_environ',
                    action='store_true')

    prs.add_option('-p', '--print', '--print-environment',
                    dest='print_env',
                    action='store_true')
    prs.add_option('-b', '--bash', '--print-bash-config',
                    dest='print_bash',
                    action='store_true')

    prs.add_option('-x', '--cmd', '--command',
                    dest='run_command',
                    action='store')
    prs.add_option('-t', '--terminals', '--open-terminals',
                    dest='open_terminals',
                    action='store_true',
                    default=False)
    prs.add_option('-e', '--editors', '--open-editors',
                    dest='open_editors',
                    action='store_true',
                    default=False)

    prs.add_option('-v', '--verbose',
                    dest='verbose',
                    action='store_true',)
    prs.add_option('-q', '--quiet',
                    dest='quiet',
                    action='store_true',)
    prs.add_option('-T', '--test',
                    dest='run_tests',
                    action='store_true',)

    (opts, args) = prs.parse_args()

    if not opts.quiet:
        logging.basicConfig()

        if opts.verbose:
            logging.getLogger().setLevel(logging.DEBUG)

    if opts.run_tests:
        import sys
        sys.argv = [sys.argv[0]] + args
        import unittest
        exit(unittest.main())

    if opts.load_environ:
        import os
        if 'VIRTUAL_ENV' in os.environ:
            args.insert(0, os.environ['VIRTUAL_ENV'])

    venv = Venv(*args,
                open_editors=opts.open_editors,
                open_terminals=opts.open_terminals)

    if opts.print_env:
        import json
        print( json.dumps(venv.asdict(), indent=2) )

    if opts.print_bash:
        venv.bash_env()

    if opts.run_command:
        import os
        import subprocess

        os.environ.update((k, str(v)) for (k,v) in venv.env.iteritems())
        subprocess.call(opts.run_command,
                shell=True,
                env=os.environ,
                cwd=venv.virtualenv)

if __name__ == "__main__":
    main()
