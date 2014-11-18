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

Usage
=========

.. code-block:: python

    import dotfiles.venv.ipython_config as venv
    env = venv.Env()
    env = build_venv_full(env)



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

log = logging.getLogger('dotfiles.venv.ipython_config')

__THISFILE = os.path.abspath(__file__)
#  __VENV_CMD = "python {~ipython_config.py}"
__VENV_CMD = "python %s" % __THISFILE


class IPYMock(object):
    """
    Provide a few mocked methods for testing
    """

    def system(self, *args, **kwargs):
        """print (instead of os.system)"""
        print(args, kwargs)

    def magic(self, *args, **kwargs):
        """print (instead of IPython magic)"""
        print(args, kwargs)


def get_pyver(pyverstr=None):
    """
    Args:
        pyver (str): "major.minor" e.g. ``2.7`` or ``3.4``
            (default: ``sys.version_info[:2]``)
    Returns:
        str: ``python2.7``, ``python.34``
    """
    if pyverstr is None:
        pyver = 'python%d.%d' % sys.version_info[:2]
    else:
        pyver = 'python%s' % pyverstr
    return pyver


def get___WRK_default(env=None):
    return os.path.expanduser('~/-wrk')


def get_WORKON_HOME_default(env=None):
    """
    Args:
        env (dict): defaults to os.environ

    Returns:
        str: path to a ``WORKON_HOME`` directory

    """
    __WORKON_HOME_DEFAULT = '-ve27'
    if env is None:
        env = os.environ
        env['__WRK'] = get___WRK_default(env=env)
    workon_home = env.get('WORKON_HOME')
    if workon_home:
        return workon_home
    python27_home = env.get('PYTHON27_HOME')
    if python27_home:
        workon_home = python27_home
        return workon_home
    else:
        python27_home = joinpath(env['__WRD'], __WORKON_HOME_DEFAULT)
        workon_home = python27_home
        return workon_home
    workon_home = os.path.expanduser('~/.virtualenvs/')
    if os.path.exists(workon_home):
        return workon_home
    workon_home = joinpath(env['__WRD'], __WORKON_HOME_DEFAULT)
    return workon_home


##############
## define aliases as IPython aliases (which support %l and %s,%s)
# which can then be transformed to:
# * ipython aliases ("echo %l; ping -t %s -n %s")
# * bash functions (TODO: with completion)
# * vim functions (TODO: venv cdb)

class CmdAlias(object):
    def __init__(self, cmdstr):
        self.cmdstr = cmdstr

    def to_shell_str(self, name,):
        return self.cmdstr

    def to_ipython_alias(self):
        return self.cmdstr

    def to_vim_function(self):
        raise NotImplemented


class IpyAlias(CmdAlias):
    def __init__(self, cmdstr, name=None):
        self.name = name
        self.cmdstr = cmdstr

    def to_shell_str(self, name=None, env=None):
        alias = self.cmdstr
        name = getattr(self, 'name') or name
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


class CdAlias(CmdAlias):
    """
    CdAlias object
    """
    def __init__(self, pathvar, name=None, aliases=None):
        """
        Args:
            pathvar (str): path variable to cd to
        Keyword Args:
            name (str): alias name (default: ``pathvar.lower.replace('_','')``)
                _WRD -> wrd
                WORKON_HOME -> workonhome
            aliases (list): list of alias names (e.g. ['cdw',])
        """
        self.pathvar = pathvar
        if name is None:
            name = pathvar.lower().replace('_','')
        self.name = name
        if aliases is None:
            aliases = list()
        self.aliases = aliases

    VIM_FUNCTION_TEMPLATE = (
    """function! {vim_func_name}\n"""
    """    " {vim_func_name}() -- cd ${pathvar}\n"""
    """    :cd ${pathvar}\n"""
    """    :pwd\n"""
    """endfunction\n"""
    )

    def to_vim_function(self):
        conf = {}
        conf['pathvar'] = self.pathvar
        conf['vim_func_name'] = "Cd_" + self.pathvar
        conf['vim_cmd_name'] = "cd"+ self.name
        conf['vim_cmd_names'] = [conf['vim_cmd_name'],] + self.aliases

        output = CdAlias.VIM_FUNCTION_TEMPLATE.format(**conf)

        for cmd_name in conf['vim_cmd_names']:
            output = output + (
    """command! -nargs=* {vim_cmd_name} call {vim_func_name}()\n"""
                .format(**conf))
        return output

    BASH_FUNCTION_TEMPLATE = (
    """{bash_func_name} () {{\n"""
    """    # {bash_func_name}()  -- cd {pathvar} /$@\n"""
    """    cd "${pathvar}"/$@\n"""
    """    echo "#$(pwd)"\n"""
    """}}\n"""
    """{bash_compl_name} () {{\n"""
    """    local cur="$2";\n"""
    """    COMPREPLY=($({bash_func_name} && compgen -d -- "${{cur}}" ))\n"""
    """}}\n"""
    )

    def to_bash_function(self, include_completions=True):
        conf = {}
        conf['pathvar'] = self.pathvar
        conf['bash_func_name'] = "cd" + self.name
        conf['bash_compl_name'] = "_cd_%s_complete" % self.pathvar
        conf['bash_func_names'] = [conf['bash_func_name'],] + self.aliases

        output = CdAlias.BASH_FUNCTION_TEMPLATE.format(**conf)

        if not include_completions:
            return output
        for cmd_name in conf['bash_func_names']:
            output = output + (
    """complete -o default -o nospace -F {bash_compl_name} {cmd_name}\n""".
                format(cmd_name=cmd_name, **conf))
        return """eval '%s';""" % output

    #def to_shell_str(self):
    #    return 'cd {}/%l'.format(shell_varquote(self.PATH_VARIABLE))
    def to_shell_str(self):
        return self.to_bash_function()

    __str__ = to_shell_str

##################
# build_*_env


def build_venv_full(env=None, prefix=None, pyver=None):
    """
    Build an Env dict for a new Venv

    Args:
        env (Env dict): :py:class:`dotfiles.venv.ipython_config.Env`
        prefix (str): base path prefix (default ``$VIRTUAL_ENV``)  # XXX TODO
        pyver (str):
    Returns:
        Env: an Env populated with configuration
    """
    env = build_dotfiles_env(env=env)
    env = build_usrlog_env(env=env)
    env = build_python_env(env=env)
    env = build_virtualenvwrapper_env(env=env)
    env = build_conda_env(env=env)
    env = build_conda_config(env=env, CONDA_ROOT=None, CONDA_HOME=None)

    #if prefix is None:
    #    prefix = env.get('VIRTUAL_ENV')
    env = build_standard_paths_full_env(env=env, prefix=prefix, pyver=pyver)

    return env


def build_dotfiles_env(env=None):
    """
    Configure dotfiles base environment

    Other Parameters:
        HOME (str): home path (``$HOME``, ``~``)
        __WRK (str): workspace path (``$__WRK``, ``~/-wrk``)

    Args:
        env (Env dict): :py:class:`dotfiles.venv.ipython_config.Env`

    Returns:
        env (Env dict): :py:class:`dotfiles.venv.ipython_config.Env`
    """
    if env is None:
        env = Env()
    if not env.get('HOME'):
        env['HOME'] = os.path.expanduser('~')
    if not env.get('__WRK'):
        env['__WRK'] = get___WRK_default()

    env['__SRC'] = joinpath(env['__WRK'], '-src')
    env['__DOTFILES'] = joinpath(env['HOME'], '-dotfiles')
    return env


def build_python_env(env=None):
    """
    Configure python27 (2.7) and python34 (3.4)
    with virtualenvs in ``-wrk/-ve27`` and ``-wrk/ve34``.

    Keyword Arguments:
        env (Env dict): :py:class:`dotfiles.venv.ipython_config.Env`
    Returns:
        env (Env dict): :py:class:`dotfiles.venv.ipython_config.Env`

    """
    if env is None:
        env = Env()
        env['__WRK'] = get___WRK_default()

    #env['PYTHON27_ROOT'] = joinpath(env['__WRK'], '-python27')
    env['PYTHON27_HOME'] = joinpath(env['__WRK'], '-ve27')
    #env['PYTHON34_ROOT'] = joinpath(env['__WRK'], '-python34')
    env['PYTHON34_HOME'] = joinpath(env['__WRK'], '-ve34')

    env['PYTHON_HOME'] = env['PYTHON27_HOME']    # ~/-wrk/-ve    # cdce
    return env


def build_virtualenvwrapper_env(env=None):
    """

    Other Parameters:
        __WRK (str): workspace root (``$__WRK``, ``~/-wrk``)

    Keyword Arguments:
        env (Env dict): :py:class:`dotfiles.venv.ipython_config.Env`
    Returns:
        env (Env dict): :py:class:`dotfiles.venv.ipython_config.Env`
    """

    if env is None:
        env = Env()
        env['__WRK'] = get___WRK_default()

    if not env.get('PYTHON27_HOME'):
        env['PYTHON27_HOME'] = joinpath(env['__WRK'], '-ve27')

    env['PROJECT_HOME'] = env['__WRK']          # ~/-wrk/       # cdph
    env['WORKON_HOME'] = env['PYTHON27_HOME']   # ~/-wrk/-ve27/    # cdve
    return env


def build_conda_env(env=None):
    """
    Configure conda27 (2.7) and conda (3.4)
    with condaenvs in ``-wrk/-ce27`` and ``-wrk/ce34``.

    Other Parameters:
        __WRK (str): workspace root (``$__WRK``, ``~/-wrk``)

    Keyword Arguments:
        env (Env dict): :py:class:`dotfiles.venv.ipython_config.Env`
    Returns:
        env (Env dict): :py:class:`dotfiles.venv.ipython_config.Env`
    """
    if env is None:
        env = Env()
        env['__WRK'] = get___WRK_default()

    env['CONDA27_ROOT'] = joinpath(env['__WRK'], '-conda27')
    env['CONDA27_HOME'] = joinpath(env['__WRK'], '-ce27')
    env['CONDA34_ROOT'] = joinpath(env['__WRK'], '-conda34')
    env['CONDA34_HOME'] = joinpath(env['__WRK'], '-ce34')
    return env


def build_conda_config(env=None, CONDA_ROOT=None, CONDA_HOME=None):
    """
    Configure conda for a specific environment
    TODO build_venv_config

    Args:
        env (Env dict): :py:class:`dotfiles.venv.ipython_config.Env`
    Returns:
        env (Env dict): :py:class:`dotfiles.venv.ipython_config.Env`
    """
    if env is None:
        env = Env()
        env['__WRK'] = get___WRK_default()
        if CONDA_ROOT is None:
            env['CONDA27_ROOT'] = joinpath(env['__WRK'], '-conda27')
        if CONDA_HOME is None:
            env['CONDA27_HOME'] = joinpath(env['__WRK'], '-ce27')

    if CONDA_ROOT is None:
        CONDA_ROOT = env['CONDA27_ROOT']  # ~/-wrk/-conda27/
    if CONDA_HOME is None:
        CONDA_HOME = env['CONDA27_HOME']  # ~/-wrk/-ce27/

    env['CONDA_ROOT'] = CONDA_ROOT
    env['CONDA_HOME'] = CONDA_HOME
    return env


def build_standard_paths_full_env(env=None, prefix='/', pyver=None):
    """
    Set variables for standard paths in the environment

    Keyword Args:
        env (Env dict): :py:class:`dotfiles.venv.ipython_config.Env`
        prefix (str): a path prefix (e.g. ``$VIRTUAL_ENV`` or ``$PREFIX``)
    Returns:
        env (Env dict): :py:class:`dotfiles.venv.ipython_config.Env`

    References:
        - https://en.wikipedia.org/wiki/Unix_directory_structure
        - https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard
    """
    if env is None:
        env = Env()
    if pyver is None:
        pyver = get_pyver(pyver)
    if prefix is None:
        raise Exception("prefix must be specified")

    env['_BIN']         = joinpath(prefix, "bin")            # ./bin
    env['_ETC']         = joinpath(prefix, "etc")            # ./etc
    env['_ETCOPT']      = joinpath(prefix, "etc", "opt")     # ./etc/opt
    env['_HOME']        = joinpath(prefix, "home")           # ./home
    env['_ROOT']        = joinpath(prefix, "root")           # ./root
    env['_LIB']         = joinpath(prefix, "lib")            # ./lib
    env['_PYLIB']       = joinpath(prefix, "lib",       # ./lib/pythonN.N
                                    pyver)
    env['_PYSITE']      = joinpath(prefix,  # ./lib/pythonN.N/site-packages
                                    "lib",
                                    pyver, 'site-packages')
    env['_MNT']         = joinpath(prefix, "mnt")            # ./mnt
    env['_MEDIA']       = joinpath(prefix, "media")          # ./media
    env['_OPT']         = joinpath(prefix, "opt")            # ./opt
    env['_SBIN']        = joinpath(prefix, "sbin")           # ./sbin
    env['_SRC']         = joinpath(prefix, "src")            # ./src
    env['_SRV']         = joinpath(prefix, "srv")            # ./srv
    env['_TMP']         = joinpath(prefix, "tmp")            # ./tmp
    env['_USR']         = joinpath(prefix, "usr")            # ./usr
    env['_USRBIN']      = joinpath(prefix, "usr","bin")      # ./usr/bin
    env['_USRINCLUDE']  = joinpath(prefix, "usr","include")  # ./usr/include
    env['_USRLIB']      = joinpath(prefix, "usr","lib")      # ./usr/lib
    env['_USRLOCAL']    = joinpath(prefix, "usr","local")    # ./usr/local
    env['_USRSBIN']     = joinpath(prefix, "usr","sbin")     # ./usr/sbin
    env['_USRSHARE']    = joinpath(prefix, "usr","share")    # ./usr/share
    env['_USRSRC']      = joinpath(prefix, "usr","src")      # ./usr/src
    env['_VAR']         = joinpath(prefix, "var")            # ./var
    env['_VARCACHE']    = joinpath(prefix, "var","cache")    # ./var/cache
    env['_VARLIB']      = joinpath(prefix, "var","lib")      # ./var/lib
    env['_VARLOCK']     = joinpath(prefix, "var","lock")     # ./var/lock
    env['_LOG']         = joinpath(prefix, "var","log")      # ./var/log
    env['_VARMAIL']     = joinpath(prefix, "var","mail")     # ./var/mail
    env['_VAROPT']      = joinpath(prefix, "var","opt")      # ./var/opt
    env['_VARRUN']      = joinpath(prefix, "var","run")      # ./var/run
    env['_VARSPOOL']    = joinpath(prefix, "var","spool")    # ./var/spool
    env['_VARTMP']      = joinpath(prefix, "var","tmp")      # ./var/tmp
    env['_WWW']         = joinpath(prefix, "var","www")      # ./var/www
    return env


def build_usrlog_env(env=None,
                     _TERM_ID=None,
                     shell='bash',
                     prefix=None,
                     USER=None,
                     HOSTNAME=None,
                     lookup_hostname=False):
    """
    Build environment variables and configuration like usrlog.sh

    Keyword Args:
        env (Env dict): :py:class:`dotfiles.venv.ipython_config.Env`
        _TERM_ID (str): terminal identifier string
        shell (str): shell name ("bash", "zsh")
        prefix (str): a path prefix (e.g. ``$VIRTUAL_ENV`` or ``$PREFIX``)
        USER (str): system username (``$USER``) for ``HISTTIMEFORMAT``
        HOSTNAME (str): system hostname (``HOSTNAME``) for ``HISTTIMEFORMAT``
        lookup_hostname (bool): if True, ``HOSTNAME`` is None,
            and not env.get('HOSTNAME'), try to read ``HOSTNAME``
            from ``os.environ`` and then ``socket.gethostname()``.
    Returns:
        env (Env dict): :py:class:`dotfiles.venv.ipython_config.Env`

    .. note:: Like ``usrlog.sh``, when ``HISTTIMEFORMAT`` is set,
        ``USER`` and ``HOSTNAME`` must be evaluated.

        (When ``USER`` and ``HOSTNAME`` change, ``HISTTIMEFORMAT``
        is not updated, and the .history file will contain only
        the most recent USER and HOSTNAME settings,
        which are not necessarily the actual USER and HOSTNAME.)

        TODO: could/should instead (also) write USER and HOSTNAME
        to -usrlog.log.

    """
    if env is None:
        env = Env()
        env['HOME'] = os.path.expanduser('~')
        env['__WRK'] = env.get('__WRK',
                               joinpath(env['HOME'], '-wrk'))
        env['HOSTNAME'] = HOSTNAME
        env['USER'] = USER

    # user default usrlog
    env['__USRLOG']     = joinpath(env['HOME'], '-usrlog.log')

    HOSTNAME = env.get('HOSTNAME')
    if HOSTNAME is None:
        if lookup_hostname:
            HOSTNAME = os.environ.get('HOSTNAME')
            if HOSTNAME is None:
                HOSTNAME = __import__('socket').gethostname()
        env['HOSTNAME'] = HOSTNAME

    env['HISTTIMEFORMAT']   = '%F %T%z  {USER}  {HOSTNAME}  '.format(
        USER=env.get('USER','-'),
        HOSTNAME=env.get('HOSTNAME','-'))

    env['HISTSIZE']         = 1000000
    env['HISTFILESIZE']     = 1000000

    # current usrlog
    if prefix is None:
        prefix = env.get('VIRTUAL_ENV', env.get('HOME'))

    env['_USRLOG']      = joinpath(prefix, "-usrlog.log")
    env['_TERM_ID']     = _TERM_ID or ""
    #env['_TERM_URI']    = _TERM_ID  # TODO

    # shell HISTFILE
    if shell == 'bash':
        env['HISTFILE'] = joinpath(prefix, ".bash_history")
    elif shell == 'zsh':
        env['HISTFILE'] = joinpath(prefix, ".zsh_history")
    else:
        env['HISTFILE'] = joinpath(prefix, '.history')

    return env


def build_VIRTUAL_ENV_env(env=None,
                        VIRTUAL_ENV=None,
                        VIRTUAL_ENV_NAME=None,
                        _APP=None,
                        _SRC=None,
                        _WRD=None):
    if env is None:
        env = Env()

    if VIRTUAL_ENV is not None:
        env['VIRTUAL_ENV'] = VIRTUAL_ENV
    if VIRTUAL_ENV_NAME is not None:
        env['VIRTUAL_ENV_NAME'] = VIRTUAL_ENV_NAME
    if _APP is not None:
        env['_APP'] = _APP
    if _SRC is not None:
        env['_SRC'] = _SRC
    if _WRD is not None:
        env['_WRD'] = _WRD

    VIRTUAL_ENV = env.get('VIRTUAL_ENV')
    if VIRTUAL_ENV is None:
        raise Exception('VIRTUAL_ENV="" and VIRTUAL_ENV=None')

    VIRTUAL_ENV_NAME = env.get('VIRTUAL_ENV_NAME')
    _APP = env.get('_APP')
    if VIRTUAL_ENV_NAME is None:
        if _APP:
            VIRTUAL_ENV_NAME = os.path.basename(_APP)
        else:
            VIRTUAL_ENV_NAME = os.path.basename(VIRTUAL_ENV)
        env['VIRTUAL_ENV_NAME'] = VIRTUAL_ENV_NAME
    if _APP is None:
        if VIRTUAL_ENV_NAME:
            _APP = VIRTUAL_ENV_NAME
        else:
            _APP = os.path.basename(_APP)
        env['_APP'] = _APP

    _SRC = env.get('_SRC')
    if _SRC is None:
        _SRC = joinpath(env['VIRTUAL_ENV'], 'src')
        env['_SRC'] = _SRC

    _ERD = env.get('_WRD')
    if _WRD is None:
        _WRD = joinpath(env['_SRC'], env['VIRTUAL_ENV_NAME'])
        env['_WRD'] = _WRD
    return env

class Env(OrderedDict):
    """
    OrderedDict of variables for/from ``os.environ``.

    """
    osenviron_keys = (
        # editors
        'VIMBIN',
        'GVIMBIN',
        'MVIMBIN',
        'GUIVIMBIN',
        'VIMCONF',
        'EDITOR',
        'EDITOR_',
        'PAGER',
        # virtualenv
        'VIRTUAL_ENV',
        # virtualenvwrapper
        'PROJECT_HOME',
        'WORKON_HOME',      # -wrk/-ve
        # venv
        'VIRTUAL_ENV_NAME',
        '__WRK',
        '__SRC',
        '__DOTFILES',
        '__DOCSWWW',
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
        # usrlog
        '_USRLOG',
        '__USRLOG',
        '_TERM_ID',
        '_TERM_URI',
    )

    def __getattribute__(self, attr):
        return dict.__getattribute__(self, attr)

    @property
    def aliases(self):
        return self.aliases

    @aliases.setter
    def set_aliases(self):
        self.aliases = aliases

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

    def __str__(self):
        return '\n' + u'\n'.join(
            "{name}={value}".format(
                name=name,
                value=shell_quote(value))
            for name, value in self.items())


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
    def get_virtualenv_path(virtual_env=None, from_environ=False):
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
        _virtual_env = None
        if virtual_env is None:
            if from_environ:
                _virtual_env = os.environ.get('VIRTUAL_ENV')
            else:
                log.error("Virtualenv not specified")
        else:
            if '/' not in virtual_env:
                _virtual_env = joinpath(
                    get_WORKON_HOME_default(),
                    virtual_env)
            else:
                _virtual_env = virtual_env
        if _virtual_env and not os.path.exists(_virtual_env):
            log.debug("virtual_env %r does not exist" % _virtual_env)
        return _virtual_env

    def __init__(self,
                 VIRTUAL_ENV=None,
                 _APP=None,
                 env=None,
                 from_environ=False,
                 open_editors=False,
                 open_terminals=False,
                 dont_reflect=True):
        """
        Initialize a new Venv

        Args:
            VIRTUAL_ENV (str): None, a path to a virtualenv, or the basename
                of a virtualenv in ``$WORKON_HOME``
            _APP (str): path component under ``$VIRTUAL_ENV/src/<appname>``.

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
            Exception: if VIRTUAL_ENV is not specified or incalculable
                from the given combination of
                ``virtualenv`` and ``from_environ`` arguments
            Exception: if both ``env`` and ``from_environ=True`` are specified

        """

        if env and from_environ:
            raise Exception("both 'env' and 'from_environ=True' were specified")

        if env is None:
            env = Env()
        self.env = env

        _virtualenv = Venv.get_virtualenv_path(VIRTUAL_ENV,
                                              from_environ=from_environ)
        if _virtualenv is None:
            errmsg = (#'''  # self.__init__.__doc__ + '''
            '''
            You specified virtualenv=%r
            virtualenv must be:

            A. a relative or absolute path to a virtualenv
            B. a virtualenv name (a path in $WORKON_HOME)

            Did you mean to specify -E (--from-shell-environ)?
            ''' % VIRTUAL_ENV)
            raise Exception(errmsg)
        self.VIRTUAL_ENV = _virtualenv

        self._APP = _APP

        # TODO: test case when _APP is not a subdir of VIRTUAL_ENV
        if self._APP is None:
            _APP = os.path.basename(self.VIRTUAL_ENV)
            _WRD = joinpath(self.VIRTUAL_ENV, 'src', _APP)  #
            self._APP = _APP
            env['_APP'] = _APP
            if not os.path.exists(_WRD):
                logging.debug("apppath %r does not exist" % _APP)
                # TODO

        self.log = logging.getLogger('venv.%s' % _APP)


        if from_environ:
            _environ = Env.from_environ(os.environ)
            import itertools
            keys = OrderedDict.fromkeys(
                itertools.chain(
                    iter(env),
                    iter(_environ)))
            for key in keys:
                env_value = env.get(key)
                _environ_value = _environ.get(key)
                if env_value and env_value != _environ_value:
                    print(
                        "from os.environ: {key}={current} #{key}__={prev}".
                        format(
                            key=key,
                            current=shell_quote(_environ_value),
                            prev=shell_quote(env_value)))
                    env[key] = _environ_value


        env = self.env
        env = build_venv_full(env=env, prefix=self.VIRTUAL_ENV)

        env = build_VIRTUAL_ENV_env(env=env,
                                VIRTUAL_ENV=self.VIRTUAL_ENV,
                                _APP=_APP)


        self.aliases = self.get_user_aliases_base()
        self.aliases.update(self.get_user_aliases(dont_reflect=dont_reflect))

        if open_editors:
            self.open_editors()

        if open_terminals:
            self.open_terminals()

    @staticmethod
    def _configure_sys(env=None, from_environ=False, pyver=None):
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
        if pyver is None:
            pyver = get_pyver()

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
           See: :py:mod:`dotfiles.venv.ipython_magics`.
        """
        aliases = OrderedDict()
        env = self.env


        aliases['cdhome']   = CdAlias('HOME', aliases=['cdh'])
        aliases['cdwrk']    = CdAlias('__WRK')
        aliases['cdddotfiles'] = CdAlias('__DOTFILES', aliases=['cdd'])
        aliases['cdprojecthome'] = CdAlias('PROJECT_HOME', aliases=['cdp', 'cdph'])
        #aliases['cdp']     = CdAlias('PROJECT_HOME')
        #aliases['cdph']    = CdAlias('PROJECT_HOME')
        aliases['cdworkonhome'] = CdAlias('WORKON_HOME', aliases=['cdwh', 'cdve'])
        #aliases['cdwh']    = CdAlias('WORKON_HOME')
        #aliases['cdve']    = CdAlias('WORKON_HOME')
        aliases['cdcondahome'] = CdAlias('CONDA_HOME', aliases=['cda', 'cdce'])
        #aliases['cda']     = CdAlias('CONDA_HOME')
        #aliases['cdce']    = CdAlias('CONDA_HOME')

        aliases['cdvirtualenv'] = CdAlias('VIRTUAL_ENV', aliases=['cdv'])
        aliases['cdsrc']    = CdAlias('_SRC', aliases=['cds'])
        aliases['cdwrd']    = CdAlias('_WRD', aliases=['cdw', 'cd-'])
        #aliases['cdw']     = CdAlias('_WRD')
        #aliases['cd-']     = CdAlias('_WRD')

        aliases['cdbin']    = CdAlias('_BIN', aliases=['cdb'])
        aliases['cdetc']    = CdAlias('_ETC', aliases=['cde'])
        aliases['cdlib']    = CdAlias('_LIB', aliases=['cdl'])
        aliases['cdlog']    = CdAlias('_LOG')
        aliases['cdpylib']  = CdAlias('_PYLIB')
        aliases['cdpysite'] = CdAlias('_PYSITE', aliases=['cdsitepackages'])
        aliases['cdvar']    = CdAlias('_VAR')
        aliases['cdwww']    = CdAlias('_WWW', aliases=['cdww'])
        #aliases['cdww']    = CdAlias('_WWW')

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
                                shell_quote(self._APP).strip('"'))

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
                                str(x) for x in self.project_files)
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
        aliases['ssv']      = 'supervisord -c "${_SVCFG}"'
        aliases['sv']       = 'supervisorctl -c "${_SVCFG}"'
        aliases['svt']      = 'sv tail -f'
        aliases['svd']      = ('supervisorctl -c "${_SVCFG}" restart dev'
                           ' && supervisorctl -c "${_SVCFG}" tail -f dev')

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
    def _configure_ipython(c=None, platform=None, setup_func=None):
        """
        Configure IPython with ``autoreload=True``, ``deep_reload=True``,
        the **storemagic** extension, the **parallelmagic**
        extension if ``import zmq`` succeeds,
        and ``DEFAULT_ALIASES`` (``cd`` aliases are not currently working).

        Args:
            c (object): An IPython configuration object (e.g. ``get_ipython()``)
            platform (str): platform string (as ``uname``)
            setup_func (function): a function to call after (default: None)

        Docs:

        * http://ipython.org/ipython-doc/dev/config/
        * http://ipython.org/ipython-doc/dev/config/options/terminal.html

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

        ipython_overload = get_IPYTHON_ALIAS_OVERLAY()
        c.AliasManager.default_aliases.extend(ipython_overload)

        if setup_func:
            output = setup_func(c)

        return c

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
            bash_alias = None
            if hasattr(v, 'to_shell_str'):
                bash_alias = v.to_shell_str()
            else:
                _alias = IpyAlias(v, k)
                bash_alias = _alias.to_shell_str()
            print(bash_alias, file=output)

    @property
    def project_files(self):
        return self._project_files()

    def _project_files(self, extension='.rst'):
        """
        Default list of project files for ``_EDITCMD_``.

        Returns:
            list: list of paths relative to ``$_WRD``.
        """
        default_project_files = (
            'README{}'.format(extension),
            'CHANGELOG{}'.format(extension),
            'Makefile',
            'setup.py',
            'requirements.txt',
            '.git/config',
            '.gitignore',
            '.hg/hgrc',
            '.hgignore',
            '',
            '.',
            self._APP,
            'docs',
        )
        return default_project_files

    @property
    def _edit_project_cmd(self):
        """
        Command to edit ``self.project_files``

        Returns:
            str: ``$_EDIT_`` ``self.project_files``
        """
        return "%s %s" % (
            self.env['_EDIT_'],
            ' '.join(
                shell_quote(joinpath(self.env['_WRD'], p))
                for p in (self.project_files))
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

            '--tab', '--title', '%s: bash' % self._APP,
            '--command', 'bash',
            '--tab', '--title', '%s: serve' % self._APP,
            '--command', "bash -c 'we %s %s'; bash" % (
                self.VIRTUAL_ENV, self._APP),  #
            '--tab', '--title', '%s: shell' % self._APP,
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


    @staticmethod
    def update_os_environ(venv, environ=None):
        """
        Update os.environ for the given venv

        Args:
            environ (dict): if None, defaults to os.environ
        Returns:
            dict: updated environ dict
        """
        environ = environ or os.environ
        environ.update((k, str(v)) for (k, v) in venv.env.items())
        return environ


    def call(self, command):
        """
        Args:
            command (int): command to run
        Returns:
            subprocess.call
        """
        import subprocess
        env = self.update_os_environ(self, os.environ)
        return subprocess.call(
            command,
                shell=True,
                env=env,
                cwd=self.VIRTUAL_ENV)


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


def get_IPYTHON_ALIAS_OVERLAY():
    IPYTHON_ALIAS_OVERLAY = (
        ('pydoc', 'pydoc %l | cat'),
        ('pip', 'pip'),
        ('dotf', 'dotf'),
        ('venv', 'venv'),
        ('ut', 'tail $$_USRLOG'),
    )
    return IPYTHON_ALIAS_OVERLAY


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

class Test_venv_build(unittest.TestCase):

    def test_100_build_dotfiles_env(self):
        env = build_dotfiles_env()
        print(env)
        self.assertTrue(env)

    def test_200_build_usrlog_env(self):
        env = build_usrlog_env()
        print(env)
        self.assertTrue(env)

    def test_300_build_python_env(self):
        env = None
        env = build_python_env()
        print(env)
        self.assertTrue(env)

    def test_400_build_virtualenvwrapper_env(self):
        env = build_virtualenvwrapper_env()
        print(env)
        self.assertTrue(env)

    def test_500_build_conda_env(self):
        env = build_conda_env()
        print(env)
        self.assertTrue(env)

    def test_600_build_conda_config(self):
        env = build_conda_config()
        #env = build_conda_config(env=env, conda_root=None, conda_home=None)
        print(env)
        self.assertTrue(env)

    def test_600_build_standard_paths_full_env(self):
        env = build_standard_paths_full_env()
        print(env)
        self.assertTrue(env)

    def test_610_build_standard_paths_full_env__prefix_None(self):
        with self.assertRaises(Exception):
            env = build_standard_paths_full_env(prefix=None)

    def test_700_build_venv_full(self):
        env = build_venv_full(prefix='/')
        print(env)
        self.assertTrue(env)

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
        self.TEST_VIRTUAL_ENV = joinpath(get_WORKON_HOME_default(), 'dotfiles')

    def test_venv(self):
        venv = Venv(self.TEST_VIRTUALENV)
        assert 'VIRTUAL_ENV' in venv.env
        self.assertEqual(venv.VIRTUAL_ENV, self.TEST_VIRTUAL_ENV)

    def test_venv__APP(self):
        venv = Venv(self.TEST_VIRTUALENV, self.TEST_APPNAME)
        self.assertEqual(venv._APP, self.TEST_APPNAME)

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
        argparse.ArgumentParser: options for the commandline interface
    """
    import argparse

    prs = argparse.ArgumentParser(
        #usage=("%prog [-b|--print-bash] [-t] [-e] [-E<virtualenv>] [appname]"),
        description="dotfiles.venv.ipython_config.py",
        epilog="Copyright 2014 Wes Turner. New BSD License\n")

    prs.add_argument('-E','-e','--from-shell-environ',
                   dest='load_environ',
                   action='store_true')
    prs.add_argument('--ve', '--virtual-env',
                     dest='VIRTUAL_ENV',
                     action='store',
                     help="Path to a VIRTUAL_ENV (or a name in $WORKON_HOME)")
    prs.add_argument('--app',
                     dest='_APP',
                     action='store',
                     help="Path under VIRTUAL_ENV/src/{_APP}")


    prs.add_argument('-p', '--print', '--print-json', '--json',
                   dest='print_env',
                   action='store_true',
                   help="Print venv configuration as JSON")
    prs.add_argument('--print-bash', '--print-zsh',
                   dest='print_bash',
                   action='store_true',
                   help="Print venv configuration for Bash, ZSH"
                   )

    prs.add_argument('-x', '--cmd', '--command',
                   dest='run_command',
                   action='store',
                   help="Run a command in a venv-configured shell")
    prs.add_argument('-t', '--terminals', '--open-terminals',
                   dest='open_terminals',
                   action='store_true',
                   default=False,
                   help="Open terminals within the venv [gnome-terminal]"
                   )
    prs.add_argument('--editors', '--open-editors',
                   dest='open_editors',
                   action='store_true',
                   default=False,
                   help=("Open an editor with venv.project_files"
                         " [$PROJECT_FILES]")
                   )

    prs.add_argument('--platform',
                   dest='platform',
                   action='store',
                   default=None,
                   help='Platform to generate configuration for')


    prs.add_argument('-b', '--bash',
                   dest='run_bash',
                   action='store_true',
                   help="Run bash in the specified venv")


    prs.add_argument('args', metavar='args', nargs=argparse.REMAINDER)

    prs.add_argument('-a', '--all-paths',
        help="Print all paths (-p -r -d)",
        action='store_true',
        )
    prs.add_argument('--path', '--resource-path',
        help="Print $_WRD/${@}",
        dest='resource_path',
        action='store_true',
        )
    prs.add_argument('-r', '--relative-path',
        help="Print ${@}",
        dest='relative_path',
        action='store_true',
        )
    prs.add_argument('-d', '--dotfiles-path',
        help="Print ${__DOTFILES}/${path}",
        dest='dotfiles_path',
        action='store_true',
        )
    #prs.add_argument('--version',
    #               dest='version',
    #               action='store_true',
    #               help="Print dotfiles.version")

    prs.add_argument( '--verbose',
                   dest='verbose',
                   action='store_true',)
    prs.add_argument('-q', '--quiet',
                   dest='quiet',
                   action='store_true',)
    prs.add_argument('-T', '--test',
                   dest='run_tests',
                   action='store_true',)

    return prs


def main(*args):
    """
    Commandline main function called if ``__name__=="__main__"``

    Returns:
        int: nonzero on error
    """
    import logging

    prs = get_venv_parser()
    args = args and list(args) or sys.argv[1:]
    opts = prs.parse_args(args=args)

    if not opts.quiet:
        logging.basicConfig()

        if opts.verbose:
            logging.getLogger().setLevel(logging.DEBUG)

    if opts.run_tests:
        sys.argv = [sys.argv[0]] + opts.args
        sys.exit(unittest.main())

    virtual_env = None
    _app = None
    if opts.args:
        print("ARGS: %r", opts.args)
        if len(opts.args) == 1:
            virtual_env = opts.args
        if len(opts.args) == 2:
            virtual_env, _app = opts.args
        if len(opts.args) >= 3:
            return prs.error("<virtual_env> [<_app>] (%r)" % opts.args)

    if opts.load_environ:
        virtual_env = os.environ.get('VIRTUAL_ENV')
        _app = os.environ.get('_APP')

    if opts.VIRTUAL_ENV:
        virtual_env = opts.VIRTUAL_ENV

    if opts._APP:
        _app = opts._APP

    # virtualenv [, appname]
    venv = Venv(VIRTUAL_ENV=virtual_env,
                _APP=_app,
                open_editors=opts.open_editors,
                open_terminals=opts.open_terminals)

    if opts.print_env:
        output = sys.stdout
        print(venv.to_json(indent=2), file=output)

    if opts.print_bash:
        venv.bash_env()

    if opts.run_command:
        venv.call(opts.run_command)

    if opts.run_bash:
        venv.call('bash')


    if any((opts.all_paths,
            opts.resource_path,
            opts.dotfiles_path,
            opts.relative_path)):
        paths = opts.args or ['/']
        basepath = get_pkg_resource_filename('/')
        for pth in paths:
            resource_path = get_pkg_resource_filename(pth)
            if opts.all_paths or opts.relative_path:
                relpath = os.path.relpath(resource_path, basepath)
                print(relpath)
            if opts.all_paths or opts.resource_path:
                print(resource_path)
            if opts.all_paths or opts.dotfiles_path:
                dotfiles_path = os.path.join('~', '-dotfiles', relpath)
                print(dotfiles_path)


    return 0


if __name__ == "__main__":
    sys.exit(main())
