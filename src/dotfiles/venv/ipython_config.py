#!/usr/bin/env python
# encoding: utf-8
from __future__ import print_function
"""

dotfiles.venv.ipython_config
==============================
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
        str: Best path for a virtualenvwrapper ``$WORKON_HOME``
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
    OrderedDict of variables for/from ``os.environ``.

    """
    osenviron_keys = (

        '__DOCSWWW',
        '__DOTFILES',
        'PAGER',
        'PROJECTS',
        'USRLOG',
        'VIMBIN',
        'GVIMBIN',
        'MVIMBIN',
        'GUIVIMBIN',
        'VIMCONF',
        'EDITOR_',
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
        """
        Build an ``Env`` from a dict (e.g. ``os.environ``)

        Args:
            environ (dict): a dict with variable name keys and values
        Returns:
            Env: an Env environment built from the given environ dict
        """
        return cls((k, environ.get(k, '')) for k in cls.osenviron_keys)

    def set_standard_paths(env, prefix):
        """
        Set variables for standard paths in the environment

        Args:
            prefix (str): a path prefix (e.g. ``$VIRTUAL_ENV`` or ``$PREFIX``)

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

    def paths_to_variables(self, path_):
        """
        Replace components of a path string with variables configured
        in this Env.

        Args:
            path_ (str): a path string
        Returns:
            str: path string containing ``${VARNAME}`` variables
        """
        compress = sorted(
            ((k, v) for (k, v) in self.items()
             if isinstance(v, STR_TYPES) and v.startswith('/')),
            key=lambda v: (len(v[1]), v[0]),
            reverse=True)
        for varname, value in compress:
            _path = path_.replace(value, '${%s}' % varname)
        return _path


def shell_quote(var):
    """
    Escape single quotes and add double quotes around a given variable.

    Args:
        _str (str): string to add quotes to
    Returns:
        str: string wrapped in quotes

    .. warning:: This is not safe for untrusted input and only valid
       in this context (``os.environ``).

    """
    _repr = repr(var)
    if _repr.startswith('\''):
        return "\"%s\"" % _repr[1:-1]


def shell_varquote(str_):
    """
    Add doublequotes and shell variable brackets to a string

    Args:
        str_ (str): string to varquote (e.g. ``VIRTUAL_ENV``)
    Returns:
        str: "${VIRTUAL_ENV}"
    """
    return shell_quote('${%s}' % str_)


def _get_shell_version():
    """
    Returns:
        tuple: (shell_namestr, versionstr) of the current ``$SHELL``
    """
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
    """
    Returns:
        bool: True only if the ``$SHELL`` is known to support ``declare -g``
    """
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
    A virtual environment configuration generator
    """
    @staticmethod
    def get_virtualenv_path(virtualenv=None, from_environ=False):
        """
        Get the path to a virtualenv

        Args:
            virtualenv (str): a path to a virtualenv containing ``/``
                OR just the name of a virtualenv in ``$WORKON_HOME``
            from_environ (bool): whether to try and read from
                ``os.environ["VIRTUAL_ENV"]``
        Returns:
            str: a path to a virtualenv (for ``$VIRTUAL_ENV``)
        """
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
        """
        Initialize a new Venv

        Args:
            virtualenv (str): None, a path to a virtualenv, or the basename
                of a virtualenv in ``$WORKON_HOME``
            appname (str): path component under ``$VIRTUAL_ENV/src/<appname>``.

                ``$_APP`` (and thus ``$_WRD``) are set from this variable.

                if not specified, ``$_APP`` will default to the basename of
                ``$VIRTUAL_ENV``.
            env (Env): an already-configured Env object

                if ``env`` is None (the default), a new Env will be created
            from_environ (bool): True if ``os.environ`` should be read from
                (default: False)
            open_editors (bool): Whether to open an editor of the Venv
                (default: False)
            open_terminals (bool): Whether to open terminals of the Venv
                (default: False)
            dont_reflect (bool): Whether to always create aliases and functions
                referencing ``$_WRD`` even if ``$_WRD`` doesn't exist.
                (default: True)
        Raises:
            Exception: if virtualenv is not specified or incalculable
                from the given combination of
                ``virtualenv`` and ``from_environ`` arguments
            Exception: if both ``env`` and ``from_environ=True`` are specified

        """
        self.log = logging.getLogger('venv.%s' % appname)
        _virtualenv = self.get_virtualenv_path(virtualenv,
                                              from_environ=from_environ)
        if _virtualenv is None:
            errmsg = '''
            You specified virtualenv=%r
            virtualenv must be:

            A. a relative or absolute path to a virtualenv
            B. a virtualenv name (a path in $WORKON_HOME)

            Did you mean to specify -E (--from-shell-environ)?
            ''' % virtualenv
            raise Exception(errmsg)
        else:
            self.virtualenv = _virtualenv
        self.name = os.path.basename(self.virtualenv)
        if appname is None:
            appname = self.name
            apppath = joinpath(self.virtualenv, 'src', appname)  #
            if not os.path.exists(apppath):
                logging.debug("apppath %r does not exist" % apppath)
                # TODO

        if appname is None:
            appname = os.path.basename(self.virtualenv)

        self.appname = appname
        self.log = logging.getLogger('venv.%s' % appname)

        if env and from_environ:
            raise Exception("both 'env' and 'from_environ=True' were specified")

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
        # env['HISTTIMEFORMAT']   = "%F %T " # see etc/bash/usrlog.sh
        env['PAGER']   = '/usr/bin/less -R'

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
        """
        Configure sys.path with the given env, or from from_environ

        Args:
            env (Env): Env to configure sys.path according to
                (default: None)
            from_environ (bool): whether to read Env from ``os.environ``
                (default: False)

        .. note:: This method adds
           ``/usr/local/python.ver.ver/dist-packages/IPython/extensions``
            to ``sys.path``

            Why? When working in a virtualenv which does not have
            an additional local copy of IPython installed,
            the lack of an extensions path was causing errors
            in regards to missing extensions.

        """
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
        """
        Returns:
            list: ``sys.path`` list from ``_configure_sys``.
        """
        return Venv._configure_sys(self.env)

    def get_user_aliases_base(self):
        """
        Returns:
            OrderedDict: dict of ``cd`` command aliases

        .. note:: These do not work in IPython as they run in a subshell.
           See: ``dotfiles.venv.magic``.
        """
        aliases = OrderedDict()
        env = self.env

        def cdalias(varname):
            return 'cd {}/%l'.format(shell_varquote(varname))

        aliases['cdb']      = cdalias('_BIN')
        aliases['cde']      = cdalias('_ETC')
        aliases['cdh']      = cdalias('HOME')
        aliases['cdl']      = cdalias('_LIB')
        aliases['cdlog']    = cdalias('_LOG')
        aliases['cdp']      = cdalias('PROJECT_HOME')
        aliases['cdph']     = cdalias('PROJECT_HOME')
        aliases['cdpylib']  = cdalias('_PYLIB')
        aliases['cdpysite'] = cdalias('_PYSITE')
        aliases['cds']      = cdalias('_SRC')
        aliases['cdv']      = cdalias('VIRTUAL_ENV')
        aliases['cdve']     = cdalias('VIRTUAL_ENV')
        aliases['cdvar']    = cdalias('_VAR')
        aliases['cdwh']     = cdalias('WORKON_HOME')
        aliases['cdwrk']    = cdalias('WORKON_HOME')
        aliases['cdw']      = cdalias('_WRD')
        aliases['cd-']      = cdalias('_WRD')
        aliases['cdww']     = cdalias('_WWW')
        aliases['cdwww']    = cdalias('_WWW')

        aliases['cdhelp']   =  """set | grep "^cd.*()" | cut -f1 -d" " #%l"""
        return aliases

    def get_user_aliases(self, dont_reflect=False):
        """
        Configure env variables and return an OrderedDict of aliases

        Args:
            dont_reflect (bool): Whether to always create aliases and functions
                referencing ``$_WRD`` even if ``$_WRD`` doesn't exist.
                (default: False)
        Returns:
            OrderedDict: dict of aliases
        """
        aliases = OrderedDict()
        env = self.env
        env['VIMBIN']       = distutils.spawn.find_executable('vim')
        env['GVIMBIN']      = distutils.spawn.find_executable('gvim')
        env['MVIMBIN']      = distutils.spawn.find_executable('mvim')
        env['GUIVIMBIN']    = env.get('MVIMBIN', env.get('GVIMBIN'))

        env['VIMCONF']      = "--servername %s" % (
                                shell_quote(self.appname).strip('"'))

        if not env.get('GUIVIMBIN'):
            env['_EDIT_']   = "%s -f" % env.get('VIMBIN')
        else:
            env['_EDIT_']   = '%s %s --remote-tab-silent' % (
                                env.get('GUIVIMBIN'),
                                env.get('VIMCONF'))
        env['EDITOR_']      = env['_EDIT_']

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
                                    _IPSESSKEY=shell_varquote('_IPSESSKEY'))
        aliases['ipnb']     = ('ipython notebook'
                                ' --secure'
                                ' --Session.keyfile={_IPSESSKEY}'
                                ' --notebook-dir={_NOTEBOOKS}'
                                ' --deep-reload'
                                ' %l').format(
                                    _IPSESSKEY=shell_varquote('_IPSESSKEY'),
                                    _NOTEBOOKS=shell_varquote('_NOTEBOOKS'))

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
                                    _IPSESSKEY=shell_varquote('_IPSESSKEY'),
                                    _APP=shell_varquote('_APP'),
                                    _IPQTLOG=shell_varquote('_IPQTLOG'))

        aliases['grinv']    = 'grin --follow %%l %s' % shell_varquote('VIRTUAL_ENV')
        aliases['grindv']   = 'grind --follow %%l --dirs %s' % shell_varquote('VIRTUAL_ENV')

        aliases['grins']    = 'grin --follow %%l %s' % shell_varquote('_SRC')
        aliases['grinds']   = 'grind --follow %%l --dirs %s' % shell_varquote('_SRC')

        _WRD = env['_WRD']
        if os.path.exists(_WRD) or dont_reflect:
            env['_WRD']         = _WRD
            env['_WRD_SETUPY']  = joinpath(_WRD, 'setup.py')
            env['_TEST_']       = "(cd {_WRD} && python {_WRD_SETUPY} test)".format(
                                        _WRD=shell_varquote('_WRD'),
                                        _WRD_SETUPY=shell_varquote('_WRD_SETUPY')
                                    )
            aliases['test-']    = env['_TEST_']
            aliases['testr-']   = 'reset && %s' % env['_TEST_']
            aliases['nose-']    = '(cd {_WRD} && nosetests)'.format(
                                        _WRD=shell_varquote('_WRD'))

            aliases['grinw']    = 'grin --follow %l {_WRD}'.format(
                                        _WRD=shell_varquote('_WRD'))
            aliases['grin-']    = aliases['grinw']
            aliases['grindw']   = 'grind --follow %l --dirs {_WRD}'.format(
                                        _WRD=shell_varquote('_WRD'))
            aliases['grind-']   = aliases['grindw']

            aliases['hgv-']     = "hg view -R {_WRD}".format(
                                        _WRD=shell_varquote('_WRD'))
            aliases['hgl-']     = "hg -R {_WRD} log".format(
                                        _WRD=shell_varquote('_WRD'))
        else:
            self.log.error('app working directory %r not found' % _WRD)

        _CFG = joinpath(env['_ETC'], 'development.ini')
        if os.path.exists(_CFG) or dont_reflect:
            env['_CFG']         = _CFG
            env['_EDITCFG_']    = "{_EDIT_} {_CFG}".format(
                                    _EDIT_=env['_EDIT_'],
                                    _CFG=env['_CFG'])
            aliases['editcfg']  = "{_EDITCFG} %l".format(
                                    _EDITCFG=shell_varquote('_EDITCFG_'))
            # Pyramid pshell & pserve (#TODO: test -f manage.py (django))
            env['_SHELL_']      = "(cd {_WRD} && {_BIN}/pshell {_CFG})".format(
                                    _BIN=shell_varquote('_BIN'),
                                    _CFG=shell_varquote('_CFG'),
                                    _WRD=shell_varquote('_WRD'))
            env['_SERVE_']      =("(cd {_WRD} && {_BIN}/pserve"
                                    " --app-name=main"
                                    " --reload"
                                    " --monitor-restart {_CFG})").format(
                                            _BIN=shell_varquote('_BIN'),
                                            _WRD=shell_varquote('_WRD'),
                                            _CFG=shell_varquote('_CFG'))
            aliases['serve-']   = env['_SERVE_']
            aliases['shell-']   = env['_SHELL_']
        else:
            self.log.error('app configuration %r not found' % _CFG)
            env['_CFG']         = ""

        aliases['edit-']    = "${_EDIT_} %l"
        aliases['e']        = aliases['edit-']
        env['PROJECT_FILES']= " ".join(
                                str(x) for x in self._project_files)
        aliases['editp']    = "$GUIVIMBIN $VIMCONF $PROJECT_FILES %l"
        aliases['makewrd']  = "(cd {_WRD} && make %l)".format(
                                    _WRD=shell_varquote('_WRD'))
        aliases['make-']    = aliases['makewrd']
        aliases['mw']       = aliases['makewrd']

        _SVCFG = env.get('_SVCFG', joinpath(env['_ETC'], 'supervisord.conf'))
        if os.path.exists(_SVCFG) or dont_reflect:
            env['_SVCFG']   = _SVCFG
            env['_SVCFG_']  = ' -c %s' % shell_quote(env['_SVCFG'])
        else:
            self.log.error('supervisord configuration %r not found' % _SVCFG)
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
        """
        Args:
            virtualenv (str): a path to a virtualenv containing ``/``
                OR just the name of a virtualenv in ``$WORKON_HOME``
            kwargs (dict): kwargs to pass to Venv (see ``Venv.__init__``)
        Returns:
            Venv: an intialized ``Venv``
        """
        return cls(virtualenv=virtualenv, **kwargs)

    @staticmethod
    def _configure_ipython(c=None, setup_func=None, platform=None):
        """
        Configure IPython with ``autoreload=True``, ``deep_reload=True``,
        the **storemagic** extension, the **parallelmagic**
        extension if ``import zmq`` succeeds,
        and ``DEFAULT_ALIASES`` (``cd`` aliases are not currently working).

        Args:
            c (object): An IPython configuration object (e.g. ``get_ipython()``)
            setup_func (function): a function to call (default: None)
        """
        if c is None:
            if not in_ipython_config():
                # skip IPython configuration
                log.error("not in_ipython_config")
                return
            else:
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

        additional = get_DEFAULT_ALIASES(platform=platform).items()
        c.AliasManager.default_aliases.extend(additional)

        if setup_func:
            setup_func(c)

    def configure_ipython(self, *args, **kwargs):
        """
        Configure IPython with ``Venv._configure_ipython`` and
        ``user_aliases`` from ``self.aliases.items()``.

        Args:
            args (list): args for ``Venv._configure_ipython``
            kwargs (dict): kwargs for ``Venv._configure_ipython``.
        """
        def setup_func(c):
            c.AliasManager.user_aliases = [
                (k,v) for (k,v) in self.aliases.items()
                    if not k.startswith('cd')]
        return Venv._configure_ipython(*args, setup_func=setup_func, **kwargs)

    def _ipython_alias_to_bash_alias(self, name, alias):
        """
        Convert an IPython alias declaration to an ``alias`` command
        or a ``function()`` with ``%l`` replaced with ``$@``.

        Args:
            name (str): alias name
            alias (str): command string (possibly containing an ``%l``)
        Returns:
            str: either an ``alias name='command'`` string or a function
        """
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
        """
        Generate a ``source``-able script for the environment variables,
        aliases, and functions defined by the current ``Venv``.

        Args:
            output (file-like): object to ``print`` to
                (``print`` calls ``.write()`` and then ``.flush()``)
        """

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
        """
        Default list of project files for ``_EDITCMD_``.

        Returns:
            list: list of paths relative to ``$_WRD``.
        """
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
        """
        Command to edit ``self._project_files``

        Returns:
            str: ``$_EDIT_`` ``self._project_files``
        """
        return "%s %s" % (
            self.env['_EDIT_'],
            ' '.join(
                shell_quote(joinpath(self.env['_WRD'], p))
                for p in (self._project_files))
        )

    @property
    def _terminal_cmd(self):
        """
        Command to open a terminal

        Returns:
            str: env.get('TERMINAL') or ``/usr/bin/gnome-terminal``
        """
        # TODO: add Terminal.app
        return self.env.get('TERMINAL', '/usr/bin/gnome-terminal')

    @property
    def _open_terminals_cmd(self):
        """
        Command to open ``self._terminal_cmd`` with a list of initial
        named terminals.
        """
        # TODO: add Terminal.app (man Terminal.app?)
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
        """
        Call ``os.system`` with the given command string

        Args:
            cmd (string): command string to call ``os.system`` with
        Raises:
            Exception: if ``cmd`` is None
            NotImplementedError: if ``cmd`` is a tuple
        """
        if cmd is None:
            raise Exception()
        if isinstance(cmd, (tuple, list)):
            _cmd = ' '.join(cmd)
            # TODO: (subprocess.Popen)
            raise NotImplementedError()
        elif isinstance(cmd, (str,)):
            _cmd = cmd

            os.system(_cmd)

    def open_editors(self):
        """
        Run ``self._edit_project_cmd``
        """
        cmd = self._edit_project_cmd
        self.system(cmd=cmd)

    def open_terminals(self):
        """
        Run ``self._open_terminals_cmd``
        """
        cmd = self._open_terminals_cmd
        self.system(cmd=cmd)

    def asdict(self):
        """
        Returns:
            OrderedDict: OrderedDict(env=self.env, aliases=self.aliases)
        """
        return OrderedDict(
            env=self.env,
            aliases=self.aliases,
        )

    def to_json(self, indent=None):
        """
        Args:
            indent (int): number of spaces with which to indent JSON output
        Returns:
            str: json.dumps(self.asdict())
        """
        import json
        return json.dumps(self.asdict(), indent=indent)


def get_DEFAULT_ALIASES(platform=None):
    if platform is None:
        platform = sys.platform

    IS_DARWIN = platform == 'darwin'

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
        ('ll', 'ls {} -al'.format(LS_COLOR_AUTO)),
        ('ls', 'ls {}'.format(LS_COLOR_AUTO)),
        ('lt', 'ls {} -altr'.format(LS_COLOR_AUTO)),
        ('lz', 'ls {} -alZ'.format(LS_COLOR_AUTO)),
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
    return DEFAULT_ALIASES


def in_ipython_config():
    """
    Returns:
        bool: True if ``get_ipython`` is in ``globals()``
    """
    return 'get_config' in globals()


def ipython_main():
    """
    Function to call if running within IPython,
    as determined by ``in_ipython_config``.
    """
    venv = None
    if 'VIRTUAL_ENV' in os.environ:
        venv = Venv(from_environ=True)
        venv.configure_ipython()
    else:
        Venv._configure_ipython()


if in_ipython_config():
    print("### ipython_config.py: configuring IPython")
    ipython_main()


def ipython_imports():
    """
    Default imports for IPython (currently unused)
    """
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


class Test_Env(unittest.TestCase):

    def test_Env(self):
        e = Env()
        assert 'WORKON_HOME' not in e

    def test_Env_from_environ(self):
        import os
        e = Env.from_environ(os.environ)
        assert 'WORKON_HOME' in e


class Test_venv(unittest.TestCase):

    def setUp(self):
        self.TEST_VIRTUALENV = 'dotfiles'
        self.TEST_APPNAME = 'dotfiles'
        self.TEST_VIRTUAL_ENV = joinpath(get_workon_home_default(), 'dotfiles')

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
    """
    Returns:
        optparse.OptionParser: options for the commandline interface
    """
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

    prs.add_option('--platform',
                   dest='platform',
                   action='store',
                   default=None,
                   help='Platform to generate configuration for')

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
    """
    Commandline main function called if ``__name__=="__main__"``

    Returns:
        int: nonzero on error
    """
    import logging

    prs = get_venv_parser()
    (opts, args) = prs.parse_args()

    if not opts.quiet:
        logging.basicConfig()

        if opts.verbose:
            logging.getLogger().setLevel(logging.DEBUG)

    if opts.run_tests:
        sys.argv = [sys.argv[0]] + args
        sys.exit(unittest.main())

    if opts.load_environ:
        import os
        if 'VIRTUAL_ENV' in os.environ:
            args.insert(0, os.environ['VIRTUAL_ENV'])

    venv = Venv(*args,
                open_editors=opts.open_editors,
                open_terminals=opts.open_terminals)

    if opts.print_env:
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
    return 0


if __name__ == "__main__":
    main()
