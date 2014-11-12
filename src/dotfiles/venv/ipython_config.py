#!/usr/bin/env python
# encoding: utf-8
from __future__ import print_function
"""
ipython_config.py (venv)

- set variables for standard paths in the environment dict
- define IPython aliases
- serialize variables and aliases to

  - IPython configuration (variables, aliases)
  - Bash/zsh configuration (variables, aliases, macros)
  - JSON (variables, aliases)

"""


import distutils.spawn
import logging
import os
import site
import sys

from collections import OrderedDict
from os.path import join as joinpath

if sys.version_info[0] == 2:
    STR_TYPES = basestring
else:
    STR_TYPES = str


class IPYMock(object):
    """
    Provide a few mocked methods for testing
    """

    def system(self, *args, **kwargs):
        print(args, kwargs)

    def magic(self, *args, **kwargs):
        print(args, kwargs)

pyver = 'python%d.%d' % sys.version_info[:2]
log = logging.getLogger('Venv')

__THISFILE = os.path.abspath(__file__)

#  __VENV_CMD = "python {~ipython_config.py}"
__VENV_CMD = "python %s" % __THISFILE


def get_workon_home_default():
    """
    Returns:
        str: Best path for a WORKON_HOME directory for virtualenvwrapper
    """
    workon_home = os.environ.get('WORKON_HOME')
    if workon_home:
        return workon_home
    workon_home = os.path.expanduser('~/wrk/.ve')
    if os.path.exists(workon_home):
        return workon_home
    return os.path.expanduser('~/.virtualenvs/')


class Env(OrderedDict):
    """
    Extended OrderedDict of NAMED and _ALIASED Filesystem Hierarchy paths.

    Helpful for working with virtualenvs, bootstraps, chroots, containers.
    """
    osenviron_keys = (

        '__DOCSWWW',
        '__DOTFILES',
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
        '_src',
    )

    def __getattribute__(self, attr):
        return dict.__getattribute__(self, attr)

    @classmethod
    def from_environ(cls, environ):
        return cls((k, environ.get(k, '')) for k in cls.osenviron_keys)

    def set_standard_paths(env, prefix):
        """set variables for standard paths in the environment

        see:

        - https://en.wikipedia.org/wiki/Unix_directory_structure
        - https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard
        """
        #
        env['_BIN']         = joinpath(prefix, "bin")       # ./bin
        env['_ETC']         = joinpath(prefix, "etc")       # ./etc
        env['_ETCOPT']      = joinpath(prefix, "etc/opt")   # ./etc/opt
        env['_HOME']        = joinpath(prefix, "home")      # ./home
        env['_ROOT']        = joinpath(prefix, "root")      # ./root
        env['_LIB']         = joinpath(prefix, "lib")       # ./lib
        env['_PYLIB']       = joinpath(prefix, "lib", pyver)  # ./lib/pythonN.N
        env['_PYSITE']      = joinpath(prefix, "lib", pyver, 'site-packages')
        env['_MNT']         = joinpath(prefix, "mnt")       # ./mnt
        env['_MEDIA']       = joinpath(prefix, "media")     # ./media
        env['_OPT']         = joinpath(prefix, "opt")       # ./opt
        env['_SBIN']        = joinpath(prefix, "sbin")      # ./sbin
        env['_SRC']         = joinpath(prefix, "src")       # ./src
        env['_SRV']         = joinpath(prefix, "srv")       # ./srv
        env['_TMP']         = joinpath(prefix, "tmp")       # ./tmp
        env['_USR']         = joinpath(prefix, "usr")       # ./usr
        env['_USRBIN']      = joinpath(prefix, "usr/bin")   # ./usr/bin
        env['_USRINCLUDE']  = joinpath(prefix, "usr/include") # ./usr/include
        env['_USRLIB']      = joinpath(prefix, "usr/lib")   # ./usr/lib
        env['_USRLOCAL']    = joinpath(prefix, "usr/local") # ./usr/local
        env['_USRSBIN']     = joinpath(prefix, "usr/sbin")  # ./usr/sbin
        env['_USRSHARE']    = joinpath(prefix, "usr/share") # ./usr/share
        env['_USRSRC']      = joinpath(prefix, "usr/src")   # ./usr/src
        env['_VAR']         = joinpath(prefix, "var")       # ./var
        env['_VARCACHE']    = joinpath(prefix, "var/cache") # ./var/cache
        env['_VARLIB']      = joinpath(prefix, "var/lib")   # ./var/lib
        env['_VARLOCK']     = joinpath(prefix, "var/lock")  # ./var/lock
        env['_LOG']         = joinpath(prefix, "var/log")   # ./var/log
        env['_VARMAIL']     = joinpath(prefix, "var/mail")  # ./var/mail
        env['_VAROPT']      = joinpath(prefix, "var/opt")   # ./var/opt
        env['_VARRUN']      = joinpath(prefix, "var/run")   # ./var/run
        env['_VARSPOOL']    = joinpath(prefix, "var/spool") # ./var/spool
        env['_VARTMP']      = joinpath(prefix, "var/tmp")   # ./var/tmp
        env['_WWW']         = joinpath(prefix, "var/www")      # ./var/www
        # TODO: /srv/www | /var/www | /var/ww | /var/www/html

    def paths_to_variables(self, _path):
        compress = sorted(
            ((k, v) for (k, v) in self.items()
             if isinstance(v, STR_TYPES) and v.startswith('/')),
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
    # return repr(_str).replace("\'", "\"")


def _get_shell_version():
    import os
    import subprocess
    shell = os.environ.get('SHELL')
    if not shell:
        raise Exception('SHELL is not set')
    output = subprocess.check_output(
        (shell, '--version')).split('\n', 1)[0]
    if output.startswith('GNU bash, version '):
        verstr = output.lstrip('GNU bash, version ')
        return ('bash', verstr)
    if output.startswith('zsh '):
        return output.split(' ', 1)


def _shell_supports_declare_g():
    # NOTE: OSX still has bash 3.2, which does not support '-g'
    shell, verstr = _get_shell_version()
    if shell == 'zsh':
        return True
    if shell == 'bash':
        if verstr.startswith('4'):
            return True
    return False


class Venv(object):
    """
    Venv -- a virtual environment configuration generator for bash, ipython
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
                    get_workon_home_default(),
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
            apppath = joinpath(virtualenv, 'src', appname)  #
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
        env['PAGER']   = '/usr/bin/less -r'

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
        no_global_site_packages = joinpath(
            env('_PYLIB'), 'no-global-site-packages.txt')
        if not os.path.exists(no_global_site_packages):
            sys_libdir = joinpath("/usr/lib", pyver)
            sys.path = [joinpath(sys_libdir, p) for p in (
                        "", "plat-linux2", "lib-tk", "lib-dynload")]

            # TODO
            ipython_extensions = (
                '/usr/local/lib/%s/dist-packages/IPython/extensions'
                                % pyver)
            if not os.path.exists(ipython_extensions):
                log.info("IPython extensions not found: %r",
                         ipython_extensions)
            if ipython_extensions not in sys.path:
                sys.path.append(ipython_extensions)

        # optimize_python_path(sys.path)

        site.addsitedir(env['_PYSITE'])

        return sys.path

    def configure_sys(self):
        return Venv._configure_sys(self.env)

    def get_user_aliases_base(self):
        aliases = OrderedDict()
        env = self.env

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

        aliases['cdhelp']   =  """set | grep "^cd.*()" | cut -f1 -d" " #%l"""
        return aliases

    def get_user_aliases(self, dont_reflect=False):
        aliases = OrderedDict()
        env = self.env
        env['VIMBIN']       = distutils.spawn.find_executable('vim')
        env['GVIMBIN']      = distutils.spawn.find_executable('gvim')
        env['MVIMBIN']      = distutils.spawn.find_executable('mvim')
        env['GUIVIM']       = env.get('MVIMBIN', env.get('GVIMBIN'))

        if not env.get('GUIVIM'):
            env['_EDIT_']   = 'vim -p'
        else:
            env['_EDIT_']   = '%s --servername %s --remote-tab-silent' % (
                env.get('GUIVIM'),
                shell_quote(self.appname).strip('"'))

        aliases['edit-']    = env['_EDIT_']
        aliases['gvim-']    = env['_EDIT_']

        env['_IPSESSKEY']   = joinpath(env['_SRC'], '.sessionkey')
        env['_NOTEBOOKS']   = joinpath(env['_SRC'], 'notebooks')

        if sys.version_info.major == 2:
            _new_ipnbkey="print os.urandom(128).encode(\\\"base64\\\")"
        elif sys.version_info.major == 3:
            _new_ipnbkey="print(os.urandom(128).encode(\\\"base64\\\"))"
        else:
            raise KeyError(sys.version_info.major)

        aliases['ipskey']   = ('(python -c \"'
                                'import os;'
                                ' {_new_ipnbkey}\"'
                                ' > {_IPSESSKEY} )'
                                ' && chmod 0600 {_IPSESSKEY};'
                                ' # %l'
                                ).format(
                                    _new_ipnbkey=_new_ipnbkey,
                                    _IPSESSKEY=shell_quote(env['_IPSESSKEY']))
        aliases['ipnb']     = ('ipython notebook'
                                ' --secure'
                                ' --Session.keyfile={_IPSESSKEY}'
                                ' --notebook-dir={_NOTEBOOKS}'
                                ' --deep-reload'
                                ' %l').format(
                                    _IPSESSKEY=shell_quote(env['_IPSESSKEY']),
                                    _NOTEBOOKS=shell_quote(env['_NOTEBOOKS']))

        env['_IPQTLOG']     = joinpath(env['VIRTUAL_ENV'], '.ipqt.log')
        aliases['ipqt']     = ('ipython qtconsole'
                                ' --secure'
                                ' --Session.keyfile={_IPSESSKEY}'
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
            env['_WRD_SETUPY']  = joinpath(appsrc, 'setup.py')
            env['_TEST_']       = "(cd {_WRD} && python {_WRD_SETUPY} test)".format(
                                        _WRD=shell_quote(env['_WRD']),
                                        _WRD_SETUPY=shell_quote(env['_WRD_SETUPY'])
                                    )
            aliases['cdw']      = 'cd {_WRD}/%l'.format(
                                        _WRD=shell_quote(env['_WRD']))
            aliases['cd-']      = aliases['cdw']
            aliases['test-']    = env['_TEST_']
            aliases['testr-']   = 'reset && %s' % env['_TEST_']
            aliases['nose-']    = '(cd {_WRD} && nosetests)'.format(
                                        _WRD=shell_quote(env['_WRD']))

            aliases['grinw']    = 'grin --follow %l {_WRD}'.format(
                                        _WRD=shell_quote(env['_WRD']))
            aliases['grin-']    = aliases['grinw']
            aliases['grindw']   = 'grind --follow %l --dirs {_WRD}'.format(
                                        _WRD=shell_quote(env['_WRD']))
            aliases['grind-']   = aliases['grindw']

            aliases['hgv-']     = "hg view -R {_WRD}".format(
                                        _WRD=shell_quote(env['_WRD']))
            aliases['hgl-']     = "hg -R {_WRD} log".format(
                                        _WRD=shell_quote(env['_WRD']))
        else:
            self.log.error('app working directory %r not found' % appsrc)

        appcfg = joinpath(env['_ETC'], 'development.ini')
        if os.path.exists(appcfg) or dont_reflect:
            env['_CFG']         = appcfg
            env['_EDITCFG_']    = "{_EDIT_} {_CFG}".format(
                                    _EDIT_=env['_EDIT_'],
                                    _CFG=env['_CFG'])
            aliases['editcfg']  = "{_EDITCFG} %l".format(
                                    _EDITCFG=env['_EDITCFG_'])
            # Pyramid pshell & pserve (#TODO: test -f manage.py (django))
            env['_SHELL_']      = "(cd {_WRD} && {_BIN}/pshell {_CFG})".format(
                                    _BIN=env['_BIN'],
                                    _CFG=shell_quote(env['_CFG']),
                                    _WRD=shell_quote(env['_WRD']))
            env['_SERVE_']      =("(cd {_WRD} && {_BIN}/pserve"
                                    " --app-name=main"
                                    " --reload"
                                    " --monitor-restart {_CFG})").format(
                                            _BIN=env['_BIN'],
                                            _WRD=shell_quote(env['_WRD']),
                                            _CFG=shell_quote(env['_CFG']))
            aliases['serve-']   = env['_SERVE_']
            aliases['shell-']   = env['_SHELL_']
        else:
            self.log.error('app configuration %r not found' % appcfg)

        aliases['edit-']    = "{_EDIT_} %l".format(
                                _EDIT_=env['_EDIT_'])
        aliases['e']        = aliases['edit-']
        aliases['editp']    = "%s %%l" % self._edit_project_cmd
        aliases['makewrd']  = "(cd {_WRD} && make %l)".format(
                                    _WRD=shell_quote(env['_WRD']))
        aliases['make-']    = aliases['makewrd']
        aliases['mw']       = aliases['makewrd']

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
    def _configure_ipython(c=None, setup_func=None):
        if c is None and not in_ipython_config():
            # skip IPython configuration
            log.error("not in_ipython_config")
            return
        c = get_config()
        c.InteractiveShellApp.ignore_old_config = True
        c.InteractiveShellApp.log_level = 20

        c.InteractiveShellApp.extensions = [
            # 'autoreload',
            'storemagic',
        ]
        #try:
        #    import sympy
        #    c.InteractiveShellApp.extensions.append('sympyprinting')
        #except ImportError, e:
        #    pass

        try:
            import zmq
            zmq
            c.InteractiveShellApp.extensions.append('parallelmagic')
        except ImportError:
            pass

        c.InteractiveShell.autoreload = True
        c.InteractiveShell.deep_reload = True

        # %store [name]
        c.StoreMagic.autorestore = True

        c.AliasManager.default_aliases = list(DEFAULT_ALIASES.items())

        if setup_func:
            setup_func(c)

    def configure_ipython(self, *args, **kwargs):
        def setup_func(c):
            c.AliasManager.user_aliases = self.aliases.items()
        return Venv._configure_ipython(*args, setup_func=setup_func, **kwargs)

    def _ipython_alias_to_bash_alias(self, name, alias):
        alias = self.env.paths_to_variables(alias)
        if '%s' in alias or '%l' in alias:
            # alias = '# %s' % alias
            # chunks = alias.split('%s')
            _alias = alias[:]
            count = 0
            while '%s' in _alias:
                count += 1
                _alias = _alias.replace('%s', '${%d}' % count, 1)
            _aliasmacro = (
                'eval \'{cmdname} () {{\n    {aliasfunc}\n}}\';'.format(
                    cmdname=name,
                    aliasfunc=_alias))
            return _aliasmacro.replace('%l', '$@')

        return 'alias %s=%r' % (name, alias)

    def bash_env(self, output=sys.stdout):

        for k, v in self.env.items():
            print("export %s=%r" % (k, v), file=output)
            # if _shell_supports_declare_g():
            #    print("declare -grx %s=%r" % (k, v), file=output)
            # else:
            #     print("export %s=%r" % (k, v), file=output)
            #     print("declare -r %k" % k, file=output)

        for k, v in self.aliases.items():
            bash_alias = self._ipython_alias_to_bash_alias(k, v)
            print(bash_alias, file=output)

    @property
    def _project_files(self):
        default_project_files = (
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
        return self.env.get('TERMINAL', '/usr/bin/gnome-terminal')

    @property
    def _open_terminals_cmd(self):
        # TODO
        cmd = (
            self._terminal_cmd,
            '--working-directory', self.env['_WRD'],

            '--tab', '--title', '%s: bash' % self.appname,
            '--command', 'bash',
            '--tab', '--title', '%s: serve' % self.appname,
            '--command', "bash -c 'we %s %s'; bash" % (
                self.virtualenv, self.appname),  #
            '--tab', '--title', '%s: shell' % self.appname,
            '--command', "bash -c %r; bash" % self.env['_SHELL_']
        )
        return cmd

    def system(self, cmd=None):
        if cmd is None:
            raise Exception()
        if isinstance(cmd, (tuple, list)):
            _cmd = ' '.join(cmd)
            # TODO: sarge
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
            aliases=self.aliases,
        )

    def to_json(self, indent=None):
        import json
        return json.dumps(self.asdict(), indent=indent)

IS_DARWIN = sys.platform == 'darwin'

import sys
LS_COLOR_AUTO = "--color=auto"
if IS_DARWIN:
    LS_COLOR_AUTO = "-G"


PSX_COMMAND = 'ps uxaw'
PSF_COMMAND = 'ps uxawf'
PS_SORT_CPU = '--sort=-pcpu'
PS_SORT_MEM = '--sort=-pmem'
if IS_DARWIN:
    PSX_COMMAND = 'ps uxaw'
    PSF_COMMAND = 'ps uxaw'
    PS_SORT_CPU = '-c'
    PS_SORT_MEM = '-m'

DEFAULT_ALIASES = OrderedDict((
    ('cdw', 'cd $$WORKON_HOME'),
    ('cdh', 'cd $$HOME'),
    ('cp', 'cp'),
    ('bash', 'bash'),
    ('cat', 'cat'),
    ('chmodr', 'chmod -R'),
    ('chownr', 'chown -R'),
    ('egrep', 'egrep --color=auto'),
    ('fgrep', 'fgrep --color=auto'),
    ('git', 'git'),
    ('ga', 'git add'),
    ('gd', 'git diff'),
    ('gdc', 'git diff --cached'),
    ('gs', 'git status'),
    ('gl', 'git log'),
    ('grep', 'grep --color=auto'),
    ('grin', 'grin'),
    ('grind', 'grind'),
    ('grinpath', 'grin --sys-path'),
    ('grindpath', 'grind --sys-path'),
    ('grunt', 'grunt'),
    ('gvim', 'gvim'),
    ('head', 'head'),
    ('hg', 'hg'),
    ('hgl', 'hg log -l10'),
    ('hgs', 'hg status'),
    ('htop', 'htop'),
    ('ifconfig', 'ifconfig'),
    ('ip', 'ip'),
    ('last', 'last'),
    ('la', 'ls {} -A'.format(LS_COLOR_AUTO)),
    ('ll', 'ls {} -aL'.format(LS_COLOR_AUTO)),
    ('ls', 'ls {}'.format(LS_COLOR_AUTO)),
    ('lt', 'ls {} -altr'.format(LS_COLOR_AUTO)),
    ('lx', 'ls {} -alZ'.format(LS_COLOR_AUTO)),
    ('lxc', 'lxc'),
    ('make', 'make'),
    ('mkdir', 'mkdir'),
    ('netstat', 'netstat'),
    ('nslookup', 'nslookup'),
    ('ping', 'ping'),
    ('mv', 'mv'),
    ('ps', 'ps'),
    ('psf', PSF_COMMAND),
    ('psx', PSX_COMMAND),
    ('psh', '{} | head'.format(PSX_COMMAND)),
    ('psc', '{} {}'.format(PSX_COMMAND, PS_SORT_CPU)),
    ('psch', '{} {} | head'.format(PSX_COMMAND, PS_SORT_CPU)),
    ('psm', '{} {}'.format(PSX_COMMAND, PS_SORT_MEM)),
    ('psmh', '{} {} | head'.format(PSX_COMMAND, PS_SORT_MEM)),
    ('psfx', PSF_COMMAND),
    ('pydoc', 'pydoc'),
    ('pyline', 'pyline'),
    ('pyrpo', 'pyrpo'),
    ('route', 'route'),
    ('rm', 'rm'),
    ('rsync', 'rsync'),
    ('sqlite3', 'sqlite3'),
    ('ss', 'ss'),
    ('ssv', 'supervisord'),
    ('stat', 'stat'),
    ('sudo', 'sudo'),
    ('sv', 'supervisorctl'),
    ('t', 'tail -f'),
    ('tail', 'tail'),
    ('thg', 'thg'),
    ('top', 'top'),
    ('tracepath', 'tracepath'),
    ('tracepath6', 'tracepath6'),
    ('vim', 'vim'),
    ('uptime', 'uptime'),
    ('which', 'which'),
    ('who_', 'who'),
    ('whoami', 'whoami'),
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
    path
    from pprint import pprint as pp
    pp
    from pprint import pformat as pf
    pf

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
    TEST_VIRTUAL_ENV = joinpath(get_workon_home_default(), 'dotfiles')

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
        venv


def get_venv_parser():
    import optparse

    prs = optparse.OptionParser(
        usage=("%prog [-b|--print-bash] [-t] [-e] [-E<virtualenv>] [appname]"))

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

    return prs


def main():
    import logging

    prs = get_venv_parser()
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
        import sys
        output = sys.stdout
        print(venv.to_json(indent=2), file=output)

    if opts.print_bash:
        venv.bash_env()

    if opts.run_command:
        import os
        import subprocess

        os.environ.update((k, str(v)) for (k, v) in venv.env.items())
        subprocess.call(opts.run_command,
                        shell=True,
                        env=os.environ,
                        cwd=venv.virtualenv)

if __name__ == "__main__":
    main()
