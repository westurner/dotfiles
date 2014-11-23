#!/usr/bin/env python
# encoding: utf-8
from __future__ import print_function
"""

dotfiles.venv.ipython_config
==============================
ipython_config.py (venv)


Objective: one file to configure a shell, IPython, and vim
with no need to adjust $PATH, or prepend to ``sys.path``.

Functional comparisons:

    * T-Square
    * Compass
    * Table Sled
    * Stencil
    * Template
    * Floorplan


Implementation
================

- define ``__WRK`` workspace root
- define ``VIRTUAL_ENV``, ``_SRC``, ``_ETC``, ``_WRD``
- create an :py:mod:`Env` (``env = Env()``)
- create a :py:mod:`StepBuilder` (``builder = StepBuilder()``)
- create and add :py:mod:`Steps` (``builder.add_step(func, **conf)``)
- define variables like ``env['__WRK']`` (``Venv.env.environ['PATH']``)
- define IPython shell command aliases (``e``, ``ps``, ``git``, ``gitw``)
- and ``WORKON_HOME``
- build a new env from steps: ``new_env = builder.build(env)``
- print an :py:mod:`Env` to:

  - IPython configuration (variables, aliases)
  - Bash/zsh configuration (variables, aliases, macros)
  - JSON (variables, aliases)


Venv cd aliases
------------------

- define CdAliases that expand and complete where possible
  (``cdwrk``, ``cdwrd``, ``cdw``)
  - define venv.sh
  - define venv.vim
  - define venv.py (``dotfiles_status``, ``ds``)
  - define venv_cdmagic.py (``cdwrk``, ``cdv``, ``cdsrc``, ``cdetc``, ``cdwrd``)
  - #TODO: -> ipython_magic.py



Usage
=========

.. code-block:: bash


    git clone -R "
    __WRK="~/-wrk"                              # cdwrk # workspace
    __DOTFILES="~/-dotfiles"                    # cdd   # current dotfiles

    ## Configure venv for the shell
    __VENV=$(which venv);
    __VENV="${__DOTFILES}/etc/ipython/ipython_config.py";
    (cd $__DOTFILES; \
        ln -s "${__DOTFILES}/src/dotfiles/venv/ipython_config.py" \
              "${__VENV}"
    )
    # __VENV shell variable  -- echo ${__VENV}  # etc/bash/10-bashrc.venv.sh
    # venv() shell function  -- ($__VENV $@)    # etc/bash/10-bashrc.venv.sh
    # venv-() shell function -- ($__VENV -E $@) # etc/bash/10-bashrc.venv.sh

    ## Manually define a venv VIRTUAL_ENV

    WORKON_HOME="${__WRK}/-ve27"                # cdwh  # working set of venvs
    VIRTUAL_ENV_NAME="dotfiles"                 # "dotfiles"
    _APP=$VIRTUAL_ENV_NAME                      # "dotfiles" [ + "/etc/bash"]
    VIRTUAL_ENV="${WORKON_HOME}/${VIRTUAL_ENV_NAME}"  # cdv   # current venv
    _ETC=${VIRTUAL_ENV}/etc                     # cdetc # venv configuration
    _SRC=${VIRTUAL_ENV}/src                     # cdsrc # venv source repos
    _WRD=${_SRC}/{_APP}                         # cdwrd # working directory

    (set -x; test "$_WRD" == "~/-wrk/-ve27/dotfiles/src/dotfiles"; \
        || echo "Exception: $_WRD; )

Command Aliases
-----------------

.. code:: bash

    # Bash
    cdwrk
    cdwrd
    cdwrd#<tab>
    cdw#<tab>

    # IPython
    cdhelp
    %cdwrk
    %cdwrd
    cdwrd
    cdw

    # Vim
    :Cdwrk
    :Cdwrd
    :Cdw



Python API (see Test_Env, Test_venv_main):

.. code-block:: python

    # venv console_script   -- ./setup.py:setup.entry_points['console_scripts']
    # ./scripts/venv.py     -- PATH=./scripts:$PATH
    import dotfiles.venv.ipython_config as venv

    #
    venvstr="dotfiles"
    _virtual_env_expected = os.path.expanduser('~/-wrk/-ve27/' + venvstr)
    _virtual_env = Venv.get_venv_path(venvstr)
    assert _virtual_env == _virtual_env_expected

    env = venv.Env()
    env['VIRTUAL_ENV'] = _virtual_env
    print(env['VIRTUAL_ENV']
    print(env)

    env = build_venv_full(env)
    print(env)

    env2 = Env()
    venv = Venv(env=env2, venvstr="dotfiles")
    assert venv.env['VIRTUAL_ENV']


.. note:: Python >= 2.7 standard library only

   This module may only import from the Python standard library,
   so that it always works as ``~/.ipython/profile_default/ipython_config.py``

"""
import copy
import difflib
import distutils.spawn
import itertools
import json
import logging
import os
import pprint
import site
import subprocess
import sys
import unittest

from collections import OrderedDict
from os.path import join as joinpath

## try/except imports for IPython
# import IPython
# import zmq
## import sympy

if sys.version_info[0] == 2:
    STR_TYPES = basestring
else:
    STR_TYPES = str

log = logging.getLogger('dotfiles.venv.ipython_config')

__THISFILE = os.path.abspath(__file__)
#  __VENV_CMD = "python {~ipython_config.py}"
__VENV_CMD = "python %s" % __THISFILE


def prepend_comment_char(strblock, commentchar="##"):
    """
    Args:
        strblock (str): string to split by newlines and prepend
        prefix (str): comment string prefix (one space will be added)
    Yields:
        str: lines prefixed with prefix
    """
    for line in strblock.splitlines():
        yield " ".join((commentchar, line))


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

# CdAlias
# * bash functions (cdwrd, cdw) with tab completion
# * ipython magics (%cdwrd, cdwrd, cdw)
# * vim functions  (:Cdwrd)

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

    x = CdAlias('HOME', aliases=['cd',])
    assert x.name 'home'
    print
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

    IPYTHON_MAGICS_FILE_HEADER = (
'''
#!/usr/bin/env ipython
# dotfiles.venv.ipython_cdmagic
from __future__ import print_function
"""
IPython ``%cd`` ``%magic?`` commands
"""
import os
try:
    from IPython.core.magic import (Magics, magics_class, line_magic)
except ImportError:
    print("ImportError: IPython")
    # Mock IPython for building docs
    Magics = object
    magics_class = lambda cls, *args, **kwargs: cls
    line_magic = lambda func, *args, **kwargs: func
@magics_class
class VenvMagics(Magics):
    def cd(self, envvar, line):
        """
        Change directory

        Args:
            envvar (str): os.environ variable name
            line (str): path to append to envvar
        """
        prefix = os.environ.get(envvar, "")
        path = os.path.join(prefix, line)
        return self.shell.magic('cd %s' % path)
''')

    IPYTHON_METHOD_TEMPLATE = (
'''
    @line_magic
    def {ipy_func_name}(self, line):
        """ipy_func_name()    -- cd ${pathvar}/${@}"""
        return self.cd('{pathvar}', line)
''')

    VIM_FUNCTION_TEMPLATE = (
    '''function! {vim_func_name}()\n'''
    '''    " {vim_func_name}() -- cd ${pathvar}\n'''
    '''    :cd ${pathvar}\n'''
    '''    :pwd\n'''
    '''endfunction\n'''
    )
    VIM_COMMAND_TEMPLATE = (
    '''"   :{cmd_name} -- {vim_func_name}()\n'''
    """command! -nargs=* {cmd_name} call {vim_func_name}()\n"""
    )

    @property
    def vim_cmd_name(self):
        return "Cd{}".format(self.name)

    @property
    def vim_cmd_names(self):
        return ([self.vim_cmd_name,] +
            [alias.title() for alias in self.aliases
             if not alias.endswith('-')])

    def to_vim_function(self):
        conf = {}
        conf['pathvar'] = self.pathvar
        conf['vim_func_name'] = "Cd_" + self.pathvar
        conf['vim_cmd_name'] = self.vim_cmd_name
        conf['vim_cmd_names'] = self.vim_cmd_names
        output = CdAlias.VIM_FUNCTION_TEMPLATE.format(**conf)
        for cmd_name in conf['vim_cmd_names']:
            output = output + (VIM_COMMAND_TEMPLATE
                .format(cmd_name=cmd_name,
                        pathvar=conf['pathvar'],
                        vim_func_name=conf['vim_func_name']))
        return output

    BASH_FUNCTION_TEMPLATE = (
    """{bash_func_name} () {{\n"""
    """    # {bash_func_name}()  -- cd {pathvar} /$@\n"""
    """    echo "#{pathvar}='${pathvar}'"\n"""
    """    cd "${pathvar}"/$@\n"""
    """    echo "#PWD=$(pwd)"\n"""
    """}}\n"""
    """{bash_compl_name} () {{\n"""
    """    local cur="$2";\n"""
    """    COMPREPLY=($(echo "#${pathvar}"; {bash_func_name} && compgen -d -- "${{cur}}" ))\n"""
    """}}\n"""
    )
    BASH_ALIAS_TEMPLATE = (
    """{cmd_name} () {{\n"""
    """    # {cmd_name}() -- cd ${pathvar}\n"""
    """    {bash_func_name} $@\n"""
    """}}\n"""
    )
    BASH_COMPLETION_TEMPLATE = (
    """complete -o default -o nospace -F {bash_compl_name} {cmd_name}\n"""
    )

    @property
    def bash_func_name(self):
        return "cd{}".format(self.name)

    @property
    def bash_func_names(self):
        return [self.bash_func_name,] + self.aliases

    def to_bash_function(self, include_completions=True):
        conf = {}
        conf['pathvar'] = self.pathvar
        conf['bash_func_name'] = self.bash_func_name
        conf['bash_func_names'] = self.bash_func_names
        conf['bash_compl_name'] = "_cd_%s_complete" % self.pathvar
        def _iter_bash_function(conf):
            yield (CdAlias.BASH_FUNCTION_TEMPLATE.format(**conf))
            for cmd_name in conf['bash_func_names']:
                yield (CdAlias.BASH_ALIAS_TEMPLATE
                    .format(cmd_name=cmd_name,
                            pathvar=conf['pathvar'],
                            bash_func_name=conf['bash_func_name']))
            if include_completions:
                for cmd_name in conf['bash_func_names']:
                    yield (CdAlias.BASH_COMPLETION_TEMPLATE
                        .format(cmd_name=cmd_name,
                                bash_compl_name=conf['bash_compl_name']))

        return ''.join(_iter_bash_function(conf))

    #def to_shell_str(self):
    #    return 'cd {}/%l'.format(shell_varquote(self.PATH_VARIABLE))
    def to_shell_str(self):
        """
        Returns:
            str: eval \'{_to_bash_function()}\'
        """
        return """eval \'\n{cmdstr}\n\';""".format(cmdstr=self.to_bash_funcion())

    __str__ = to_shell_str



#######################################
# def build_*_env(env=None, **kwargs):
#    return env
#######################################

class Step(object):
    """
    A build task step which builds or transforms an
    :py:mod:`Env`, by calling ``step.build(env=env, **step.conf)``

    """
    def __init__(self, func=None, **kwargs):
        """
        Keyword Arguments:
            func (callable):
        """
        if func is None:
            func = Step.print_kwargs
        self.func = func
        self._name = kwargs.get('name')
        self.build = func
        # remove env from the conf dict # XXX
        kwargs.pop('env', None)
        # conf = kwargs if conf=None
        self.conf = kwargs.get('conf', kwargs)

    def _get_name(self):
        if self._name is not None:
            return self._name
        _name = None
        if self._name is None:
            _name = getattr(self.func, 'func_name', '')
        return _name

    @property
    def name(self):
        return self._get_name()

    @name.setter
    def __set_name(self, name):
        self._name = name

    def _iteritems(self):
        yield ('name', self.name)
        yield ('func', self.func)
        yield ('conf', self.conf)

    def asdict(self):
        return OrderedDict(self._iteritems())

    def print_kwargs(self):
        return pprint.pformat(self.asdict())

    def build(self, env=None, **kwargs):
        return self.func(env=env, **self.conf)


class PrintEnvStep(Step):
    _name = 'print_env'
    output = sys.stdout
    def print_env(self, env=None, **kwargs):
        if env is None:
            env = Env()
        print(kwargs)
        print(env, file=kwargs.get('output', self.output))
        return env
    func = print_env


class PrintEnvStderrStep(PrintEnvStep):
    _name = 'print_env_stderr'
    output = sys.stderr


class StepException(Exception):
    pass

class ConfigException(Exception):
    pass

class StepConfigException(StepException, ConfigException):
    pass

class StepBuilder(object):
    """
    A class for building a sequence of steps which modify env
    """
    def __init__(self, **kwargs):
        # conf=None, steps=None, show_diffs=False, debug=False
        """
        Keyword Argumentss:
            conf (dict): initial configuration dict
                show_diffs and debug overwrite
            steps (list): initial list of Step() instances (default: None)
            show_diffs (bool): show diffs of Envs between steps
            debug (bool): show debugging output
        """
        self.steps = kwargs.pop("steps", list())
        self.conf = kwargs.get('conf', OrderedDict())
        self.conf.update({
            "show_diffs": self.conf.get('show_diffs', kwargs.get('show_diffs')),
            "debug": self.conf.get('debug', kwargs.get('debug')) })

    @property
    def debug(self):
        return self.conf.get('debug')

    @property
    def show_diffs(self):
        return self.conf.get('show_diffs')

    def add_step(self, func, **kwargs):
        """
        Args:
            func (function): (env=None, **kwargs)
            kwargs (dict): kwargs for Step.conf
        Returns:
            Step: step object appended to self.steps
        """
        if isinstance(func, Step):
            step = func(**kwargs)
        else:
            step = Step(func, name=kwargs.get('name'), conf=kwargs)
        self.steps.append(step)
        return step

    def build_iter(self, env=None, show_diffs=True, debug=False):
        """
        Build a generator of Env's from (step.build() for step in self.steps)

        Keyword Arguments:
            env (Env): initial Env (default: None)
            show_diffs (bool): difflib.ndiffs of str(env)
        Yields:
            Env: initial_env,
        """
        if env:
            initial_env = env
        else:
            initial_env = self.env
        if env is None:
            env = Env()
        env = initial_env.copy()
        yield env
        output = sys.stdout
        # log = global log

        def write(*args, **kwargs):
            return print(*args, file=output, **kwargs)
            # TODO split('\n') and prefix with commentchar
            #return log.debug(*args, **kwargs)

        for step in self.steps:
            if self.debug:
                write(str.center(" %s " % step.name, 79, '#'))
                write("# <buildconf>\n%s\n# </buildconf>" % pprint.pformat(self.conf))
                write('# <stepconf>\n%s\n# </conf>' % pprint.pformat(step.conf))
                write('# <conf>\n%s\n# </conf>' % pprint.pformat(step.conf))
                write("# <input>\n%s\n# </input>" % env)
            new_env = env.copy()

            conf = self.conf.copy()
            conf.update(**step.conf)

            new_env = step.build(env=new_env, **conf)
            if self.debug:
                write("# <output>\n%s\n# </output>" % new_env)

            if isinstance(new_env, Env):
                write(new_env)
                if self.show_diffs and env:
                    diff_output = env.ndiff(new_env)
                    write('### <diff func="%s">' % step.name)
                    write(u'\n'.join(
                        ("# %s" % s.rstrip() for s in diff_output)))
                    write("### </diff>")
                yield new_env
                env = new_env
            else:
                if debug:
                    write("# %r returned %r which is not an Env"
                                    % (step.name, new_env))
            if self.debug:
                write("# <output>\n%s\n</output>" % step)

    def build(self, *args, **kwargs):
        debug = kwargs.get('debug', self.debug)
        step_envs = []
        for env in self.build_iter(*args, **kwargs):
            if debug:
                log.debug(env)
                step_envs.append(env)
        if step_envs:
            return step_envs[-1]
        #return step_envs


## Build everything


def build_dotfiles_env(env=None, HOME=None, __WRK=None, **kwargs):
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
    if HOME is not None:
        env['HOME'] = HOME
    if __WRK is not None:
        env['__WRK'] = __WRK

    HOME = env.get('HOME')
    if HOME is None:
        env['HOME'] = os.path.expanduser('~')

    __WRK = env.get('__WRK')
    if __WRK is None:
        env['__WRK'] = get___WRK_default()

    env['__SRC'] = joinpath(env['__WRK'], '-src')
    env['__DOTFILES'] = joinpath(env['HOME'], '-dotfiles')
    return env


def build_python_env(env=None, **kwargs):
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


def build_virtualenvwrapper_env(env=None, **kwargs):
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


def build_conda_env(env=None, **kwargs):
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


def build_conda_cfg_env(env=None, CONDA_ROOT=None, CONDA_HOME=None, **kwargs):
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


def build_venv_paths_full_env(env=None,
                              venvstr=None,
                              venvappstr=None,
                              prefix=None,
                              pyver=None,
                              **kwargs):
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
    conf = {
        'venvstr': venvstr,
        'venvappstr': venvappstr,
        'prefix': prefix,
        'pyver': pyver}
    if env is None:
        env = Env()
    if pyver is None:
        pyver = get_pyver(pyver)

    if venvstr is not None:
        env = Venv.parse_venvstr(env=env, **conf)

    VIRTUAL_ENV = env.get('VIRTUAL_ENV')
    if prefix in (None, False):
        if VIRTUAL_ENV:
            prefix = VIRTUAL_ENV
        else:
            raise StepConfigException(
                {'msg': 'prefix or VIRTUAL_ENV must be specified',
                 'env': env,
                 'envstr': str(env)})
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


def build_venv_paths_cdalias_env(env=None, **kwargs):
    """
    Build CdAliases for standard paths

    Keyword Args:
        env (Env dict): :py:class:`dotfiles.venv.ipython_config.Env`
    Returns:
        env (Env dict): :py:class:`dotfiles.venv.ipython_config.Env`
                        with ``.aliases`` extended.

    .. note:: These do not work in IPython as they run in a subshell.
        See: :py:mod:`dotfiles.venv.ipython_magics`.
    """
    if env is None:
        env = Env()
    aliases = env.aliases

    aliases['cdhome']        = CdAlias('HOME', aliases=['cdh'])
    aliases['cdwrk']         = CdAlias('__WRK')
    aliases['cdddotfiles']   = CdAlias('__DOTFILES', aliases=['cdd'])

    aliases['cdprojecthome'] = CdAlias('PROJECT_HOME', aliases=['cdp', 'cdph'])
    aliases['cdworkonhome']  = CdAlias('WORKON_HOME', aliases=['cdwh', 'cdve'])
    aliases['cdcondahome']   = CdAlias('CONDA_HOME', aliases=['cda', 'cdce'])

    aliases['cdvirtualenv']  = CdAlias('VIRTUAL_ENV', aliases=['cdv'])
    aliases['cdsrc']         = CdAlias('_SRC', aliases=['cds'])
    aliases['cdwrd']         = CdAlias('_WRD', aliases=['cdw'])

    aliases['cdbin']         = CdAlias('_BIN', aliases=['cdb'])
    aliases['cdetc']         = CdAlias('_ETC', aliases=['cde'])
    aliases['cdlib']         = CdAlias('_LIB', aliases=['cdl'])
    aliases['cdlog']         = CdAlias('_LOG')
    aliases['cdpylib']       = CdAlias('_PYLIB')
    aliases['cdpysite']      = CdAlias('_PYSITE', aliases=['cdsitepackages'])
    aliases['cdvar']         = CdAlias('_VAR')
    aliases['cdwww']         = CdAlias('_WWW', aliases=['cdww'])

    aliases['cdhelp']        =  """set | grep "^cd.*()" | cut -f1 -d" " #%l"""
    return env


def build_user_aliases_env(env=None,
                           dont_reflect=False,
                           VIRTUAL_ENV=None,
                           _SRC=None,
                           _ETC=None,
                           _CFG=None,
                           PROJECT_FILES=None,
                           **kwargs):
    """
    Configure env variables and return an OrderedDict of aliases

    Args:
        dont_reflect (bool): Whether to always create aliases and functions
            referencing ``$_WRD`` even if ``$_WRD`` doesn't exist.
            (default: False)
    Returns:
        OrderedDict: dict of aliases
    """
    if env is None:
        env = Env()

    aliases = env.aliases

    if VIRTUAL_ENV is not None:
        env['VIRTUAL_ENV'] = VIRTUAL_ENV
    if _SRC is not None:
        env['_SRC'] = _SRC
    if _ETC is not None:
        env['_ETC'] = _ETC
    if _CFG is not None:
        env['_CFG'] = _CFG
    if PROJECT_FILES is not None:
        env['PROJECT_FILES'] = PROJECT_FILES

    PROJECT_FILES = env.get('PROJECT_FILES', list())
    env['PROJECT_FILES'] = PROJECT_FILES


    VIRTUAL_ENV = env.get('VIRTUAL_ENV')
    if VIRTUAL_ENV is None:
        VIRTUAL_ENV = ""
        env['VIRTUAL_ENV'] = VIRTUAL_ENV
        logging.debug('VIRTUAL_ENV is none')
        # raise Exception()
    _SRC = env.get('_SRC')
    if _SRC is None:
        if VIRTUAL_ENV:
            _SRC = joinpath(env['VIRTUAL_ENV'], 'src')
        else:
            _SRC = ""
        env['_SRC'] = _SRC
    _ETC = env.get('_ETC')
    if _ETC is None:
        if VIRTUAL_ENV:
            _ETC = joinpath(env['VIRTUAL_ENV'], 'src')
        else:
            _ETC = '/etc'
        env['_ETC'] = _ETC

    _APP = env.get('_APP')
    if _APP is None:
        if VIRTUAL_ENV:
            _APP = joinpath(env['VIRTUAL_ENV'], 'src')
        else:
            _APP = ''
        env['_APP'] = _APP

    _WRD = env.get('_WRD')
    if _WRD is None:
        if _SRC:
            if _APP:
                _WRD = joinpath(env['_SRC'], env['_APP'])
            else:
                _WRD = env['_SRC']
        else:
            _WRD = ""
        env['_WRD'] = _WRD

    # EDITOR configuration
    env['VIMBIN']       = distutils.spawn.find_executable('vim')
    env['GVIMBIN']      = distutils.spawn.find_executable('gvim')
    env['MVIMBIN']      = distutils.spawn.find_executable('mvim')
    env['GUIVIMBIN']    = env.get('MVIMBIN', env.get('GVIMBIN'))
    # set the current vim servername to _APP
    env['VIMCONF']      = "--servername %s" % (
                            shell_quote(env['_APP']).strip('"'))
    if not env.get('GUIVIMBIN'):
        env['_EDIT_']   = "%s -f" % env.get('VIMBIN')
    else:
        env['_EDIT_']   = '%s %s --remote-tab-silent' % (
                            env.get('GUIVIMBIN'),
                            env.get('VIMCONF'))
    env['EDITOR_']      = env['_EDIT_']

    aliases['edit-']    = env['_EDIT_']
    aliases['gvim-']    = env['_EDIT_']


    # IPYTHON configuration
    env['_NOTEBOOKS']   = joinpath(env.get('_SRC',
                                    env.get('__WRK',
                                    env.get('HOME'))),
                                    'notebooks')
    env['_IPYSESKEY']   = joinpath(env.get('_SRC', env.get('HOME')),
                                    '.ipyseskey')
    if sys.version_info.major == 2:
        _new_ipnbkey="print os.urandom(128).encode(\\\"base64\\\")"
    elif sys.version_info.major == 3:
        _new_ipnbkey="print(os.urandom(128).encode(\\\"base64\\\"))"
    else:
        raise KeyError(sys.version_info.major)
    aliases['ipskey']   = ('(python -c \"'
                            'import os;'
                            ' {_new_ipnbkey}\"'
                            ' > {_IPYSESKEY} )'
                            ' && chmod 0600 {_IPYSESKEY};'
                            ' # %l'
                            ).format(
                                _new_ipnbkey=_new_ipnbkey,
                                _IPYSESKEY=shell_varquote('_IPYSESKEY'))
    aliases['ipnb']     = ('ipython notebook'
                            ' --secure'
                            ' --Session.keyfile={_IPYSESKEY}'
                            ' --notebook-dir={_NOTEBOOKS}'
                            ' --deep-reload'
                            ' %l').format(
                                _IPYSESKEY=shell_varquote('_IPYSESKEY'),
                                _NOTEBOOKS=shell_varquote('_NOTEBOOKS'))

    env['_IPQTLOG']     = joinpath(env['VIRTUAL_ENV'], '.ipqt.log')
    aliases['ipqt']     = ('ipython qtconsole'
                            ' --secure'
                            ' --Session.keyfile={_IPYSESKEY}'
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
                                _IPYSESKEY=shell_varquote('_IPYSESKEY'),
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
        logging.error('app configuration %r not found' % _CFG)
        env['_CFG']         = ""

    aliases['edit-']    = "${_EDIT_} %l"
    aliases['e']        = aliases['edit-']
    env['PROJECT_FILES']= " ".join(
                            str(x) for x in PROJECT_FILES)
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
        logging.error('supervisord configuration %r not found' % _SVCFG)
        env['_SVCFG_']  = ''
    aliases['ssv']      = 'supervisord -c "${_SVCFG}"'
    aliases['sv']       = 'supervisorctl -c "${_SVCFG}"'
    aliases['svt']      = 'sv tail -f'
    aliases['svd']      = ('supervisorctl -c "${_SVCFG}" restart dev'
                        ' && supervisorctl -c "${_SVCFG}" tail -f dev')
    return env


def build_usrlog_env(env=None,
                     _TERM_ID=None,
                     shell='bash',
                     prefix=None,
                     USER=None,
                     HOSTNAME=None,
                     lookup_hostname=False,
                     **kwargs):
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
        env['HOME']     = os.path.expanduser('~')
        env['__WRK']    = env.get('__WRK',
                               joinpath(env['HOME'], '-wrk'))
        #env['HOSTNAME'] = HOSTNAME
        #env['USER'] = USER

    #HOSTNAME = env.get('HOSTNAME')
    #if HOSTNAME is None:
        #if lookup_hostname:
            #HOSTNAME = os.environ.get('HOSTNAME')
            #if HOSTNAME is None:
                #HOSTNAME = __import__('socket').gethostname()
        #env['HOSTNAME'] = HOSTNAME
    #env['HISTTIMEFORMAT']   = '%F %T%z  {USER}  {HOSTNAME}  '.format(
        #USER=env.get('USER','-'),
        #HOSTNAME=env.get('HOSTNAME','-'))
    #env['HISTSIZE']         = 1000000
    #env['HISTFILESIZE']     = 1000000

    # user default usrlog
    env['__USRLOG']     = joinpath(env['HOME'], '-usrlog.log')

    # current usrlog
    if prefix is None:
        prefix = env.get('VIRTUAL_ENV')
        if prefix is None:
            prefix = env.get('HOME', os.path.expanduser('~'))

    env['_USRLOG']      = joinpath(prefix, "-usrlog.log")
    env['_TERM_ID']     = _TERM_ID or ""
    #env['_TERM_URI']    = _TERM_ID  # TODO

    # shell HISTFILE
    #if shell == 'bash':
        #env['HISTFILE'] = joinpath(prefix, ".bash_history")
    #elif shell == 'zsh':
        #env['HISTFILE'] = joinpath(prefix, ".zsh_history")
    #else:
        #env['HISTFILE'] = joinpath(prefix, '.history')

    return env


def build_venv_activate_env(env=None,
                        venvstr=None,
                        venvappstr=None,
                        from_environ=False,
                        prefix=None,
                        VIRTUAL_ENV=None,
                        VIRTUAL_ENV_NAME=None,
                        _APP=None,
                        _SRC=None,
                        _WRD=None,
                        **kwargs):

    conf = {
        'venvstr': venvstr,
        'venvappstr': venvappstr,
        'from_environ': from_environ,
        'prefix': prefix,
        'VIRTUAL_ENV': VIRTUAL_ENV,
        'VIRTUAL_ENV_NAME': VIRTUAL_ENV_NAME,
        '_APP': _APP,
        '_SRC': _SRC,
        '_WRD': _WRD }

    venvstr_env = None
    if venvstr:
        venvstr_env = Venv.parse_venvstr(env=env, **conf)

    if env is None:
        env = venvstr_env
    else:
        if venvstr_env:
            for (key, value) in venvstr_env.environ.items():
                if env.get(key) != value:
                    env[key] = value
                    log.debug("key override")

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
        return env

    VIRTUAL_ENV_NAME = env.get('VIRTUAL_ENV_NAME')
    if VIRTUAL_ENV_NAME is None:
        pass

    if _APP is None:
        if VIRTUAL_ENV_NAME is not None:
            _APP = VIRTUAL_ENV_NAME
        else:
            _APP = ""
        env['_APP'] = _APP

    _ETC = env.get('_ETC')
    if _ETC is None:
        _ETC = joinpath(env['VIRTUAL_ENV'], 'etc')
        env['_ETC'] = _ETC

    _SRC = env.get('_SRC')
    if _SRC is None:
        _SRC = joinpath(env['VIRTUAL_ENV'], 'src')
        env['_SRC'] = _SRC

    _ERD = env.get('_WRD')
    if _WRD is None:
        _WRD = joinpath(env['_SRC'], env['_APP'])
        env['_WRD'] = _WRD
    return env

class Env(object):
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

    def __init__(self, *args, **kwargs):
        self.environ = OrderedDict(*args, **kwargs)
        self.aliases = OrderedDict()

    def __setitem__(self, k, v):
        return self.environ.__setitem__(k, v)

    def __getitem__(self, k):
        return self.environ.__getitem__(k)

    def __contains__(self, k):
        return self.environ.__contains__(k)

    def __iter__(self):
        return self.environ.__iter__()

    def get(self, k, default=None):
        return self.environ.get(k, default)

    def copy(self):
        return copy.deepcopy(self)

    @classmethod
    def from_environ(cls, environ, verbose=False):
        """
        Build an ``Env`` from a dict (e.g. ``os.environ``)

        Args:
            environ (dict): a dict with variable name keys and values
            verbose (bool): whether to be verbose about dict merging
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
            ((k, v) for (k, v) in self.environ.items()
             if isinstance(v, STR_TYPES) and v.startswith('/')),
            key=lambda v: (len(v[1]), v[0]),
            reverse=True)
        for varname, value in compress:
            _path = path_.replace(value, '${%s}' % varname)
        return _path

    def to_string_iter(self):
        yield '## <env>'
        for name, value in self.environ.items():
            strblock="{name}={value}".format(name=name, value=repr(value))
            for line in prepend_comment_char(strblock):
                yield line
        yield '## </env>'

    def __str__(self):
        return u'\n'.join(self.to_string_iter())

    def ndiff(self, other_env):
        """
        Args:
            other_env (Env): env to compare with
        Returns:
            iterable: strings from difflib.ndiff
        """
        if not hasattr(other_env, 'to_string_iter'):
            raise AttributeError('can only compare envs with envs')
        return difflib.unified_diff(
            list(self.to_string_iter()),
            list(other_env.to_string_iter()))


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
    def __init__(self,
                 env=None,
                 venvstr=None,
                 venvappstr=None,
                 __WRK=None,
                 WORKON_HOME=None,
                 prefix=None,
                 VIRTUAL_ENV=None,
                 _SRC=None,
                 VIRTUAL_ENV_NAME=None,
                 _APP=None,
                 _WRD=None,
                 __DOTFILES=None,
                 root_prefix=None,
                 from_environ=False,
                 open_editors=False,
                 open_terminals=False,
                 dont_reflect=True,
                 debug=False,
                 show_diffs=False):
        """
        Initialize a new Venv from a default configuration

        Minimally:

        >>> v = Venv(

        Keyword Arguments:

            env (Env): initial Env

            venvstr (str): VIRTUAL_ENV_NAME or VIRTUAL_ENV

            __WRK (str): None (~/-wrk) OR
                path to a workspace root
                containing one or more ``WORKON_HOME`` directories

                .. code:: bash

                    test $__WRK == echo "${HOME}/-wrk"
                    cdwrk

            WORKON_HOME (str): path to a ``WORKON_HOME`` directory
                containing zero or more 'VIRTUAL_ENV`` directories

                .. code:: bash

                    test $WORKON_HOME == echo "${__WRK}/-ve27"
                    cdworkonhome ; cdwh


            VIRTUAL_ENV_NAME (str): None or a string path component

                .. code:: bash

                    test "$VIRTUAL_ENV" == "${WORKON_HOME}/${VIRTUAL_ENV_NAME}"
                    cdvirtualenv ; cdv

                .. note:: if None (not specified),
                   ``VIRTUAL_ENV_NAME`` defaults to
                   the basename of ``$VIRTUAL_ENV``
                   or what is in ``os.environ``, if ``from_environ`` is True)


            VENV__PREFIX (str): for when VIRTUAL_ENV is not set {/,~,~/-wrk}
                some paths may not make sense with PREFIX=/.
                #TODO: list sensible defaults
                # the issue here is whether to raise an error when
                venvstr or VIRTUAL_ENV are not specified.

            VIRTUAL_ENV (str): None, a path to a virtualenv, or the basename
                of a virtualenv in ``$WORKON_HOME``

                .. code:: bash

                    test "$VIRTUAL_ENV" == "${WORKON_HOME}/${VIRTUAL_ENV_NAME}"
                    cdvirtualenv ; cdv

                .. note:: if not specified,
                   ``$_APP`` defaults to the basename of ``$VIRTUAL_ENV``
                    (or what is in os.environ, if ``from_environ`` is True)

            _SRC (str): None or a string path component

                .. code:: bash

                    test "$_SRC" == "${VIRTUAL_ENV}/src"
                    cdsrc ; cds

            _APP (str): None or a string path component

                .. code:: bash

                    test "${_SRC}/${_APP}" == "${_WRD}"
                    cdwrd ; cdw

                .. note:: if not specified,
                   ``$_APP`` defaults to the basename of ``$VIRTUAL_ENV``
                    (or what is in os.environ, if ``from_environ`` is True)

            _WRD (str): None or path to working directory

                .. code:: bash

                    test "${_SRC}/${_APP}" == "${_WRD}"
                    cdwrd ; cdw

            __DOTFILES (str): None or path to dotfiles symlink

                .. code:: bash

                    test "${__DOTFILES}" == "~/-dotfiles"
                    cddotfiles ; cdd

            env (Env): an initial Env with zero or more values for self.env
                (default: None)
            from_environ (bool): read self.env from ``os.environ``
                (default: False)
            open_editors (bool): Open an editor with Venv.project_files
                (default: False)
            open_terminals (bool): Open terminals for the Venv
                (default: False)
            dont_reflect (bool): Always create aliases and functions
                referencing ``$_WRD`` even if ``$_WRD`` doesn't exist.
                (default: True)
        Raises:
            Exception: if both ``env`` and ``from_environ=True`` are specified
            Exception: if VIRTUAL_ENV is not specified or incalculable
                from the given combination of
                ``virtualenv`` and ``from_environ`` arguments

        """
        if from_environ:
            if env is None:
                env = Env.from_environ(os.environ)
            else:
                raise Exception("both 'env' and 'from_environ=True' were specified")

        if env is None:
            env = Env()

        if VIRTUAL_ENV is not None:
            env['VIRTUAL_ENV'] = VIRTUAL_ENV
        if _APP is not None:
            env['_APP'] = _APP
        if VIRTUAL_ENV_NAME is not None:
            env['VIRTUAL_ENV_NAME'] = VIRTUAL_ENV_NAME
        if _SRC is not None:
            env['_SRC'] = _SRC
        if _WRD is not None:
            env['_WRD'] = _WRD
        if __WRK is not None:
            env['__WRK'] = __WRK
        if __DOTFILES is not None:
            env['__DOTFILES'] = __DOTFILES

        if venvstr:
            env = Venv.parse_venvstr(env=env,
                                     venvstr=venvstr,
                                     venvappstr=venvappstr,
                                     prefix=prefix)

        #prefix = None
        #VIRTUAL_ENV = env.get('VIRTUAL_ENV')
        #if VIRTUAL_ENV is not None:
            #prefix = VIRTUAL_ENV
        #else:
            #logging.debug('VIRTUAL_ENV / prefix')
            #if default_prefix:
                #prefix = default_prefix

        self.env = self.build(env=env,
                              venvstr=venvstr,
                              venvappstr=venvappstr,
                              prefix=prefix,
                              from_environ=from_environ,
                              dont_reflect=True,
                              debug=debug,
                              show_diffs=show_diffs)
        if open_editors:
            self.open_editors()

        if open_terminals:
            self.open_terminals()

    def build(self,
              env=None,
              venvstr=None,
              venvappstr=None,
              prefix=None,
              from_environ=False,
              dont_reflect=True,
              debug=False,
              show_diffs=False,
              ):

        conf = {
            'venvstr': venvstr,
            'venvappstr': venvappstr,
            'prefix': prefix,
            'from_environ': from_environ,
            'dont_reflect': dont_reflect,
            'debug': debug,
            'show_diffs': show_diffs}

        builder = StepBuilder(conf=conf)
        builder.add_step(PrintEnvStderrStep)
        builder.add_step(build_venv_activate_env)

        builder.add_step(build_dotfiles_env)
        builder.add_step(build_usrlog_env)
        builder.add_step(build_python_env)
        builder.add_step(build_virtualenvwrapper_env)
        builder.add_step(build_conda_env)
        builder.add_step(build_conda_cfg_env)
        builder.add_step(build_venv_activate_env)
        builder.add_step(build_venv_paths_full_env)
        builder.add_step(build_venv_paths_cdalias_env)
        builder.add_step(build_user_aliases_env)
        new_env = builder.build(env=env)
        return new_env

    @staticmethod
    def parse_venvstr(env=None,
                      venvstr=None,
                      venvappstr=None,
                      #TODO: prefix=None,
                      from_environ=False,
                      **kwargs):
        """
        Get the path to a virtualenv

        Args:
            venvstr (str): a path to a virtualenv containing ``/``
                OR just the name of a virtualenv in ``$WORKON_HOME``
            from_environ (bool): whether to try and read from
                ``os.environ["VIRTUAL_ENV"]``
        Returns:
            str: a path to a virtualenv (for ``$VIRTUAL_ENV``)
        """
        if from_environ is True:
            env = Env.from_environ(os.environ)
        else:
            if env is None:
                env = Env()
                env['WORKON_HOME'] = get_WORKON_HOME_default()

        VIRTUAL_ENV = env.get('VIRTUAL_ENV')
        WORKON_HOME = env.get('WORKON_HOME')
        if WORKON_HOME is None:
            WORKON_HOME = get_WORKON_HOME_default()

        if venvstr is not None:
            if '/' not in venvstr:
                VIRTUAL_ENV = joinpath(WORKON_HOME, venvstr)
            else:
                VIRTUAL_ENV = venvstr

        _APP = None
        if venvappstr is None:
            VIRTUAL_ENV_NAME = venvstr
            _APP = venvstr
        else:
            VIRTUAL_ENV_NAME = os.path.basename(venvappstr)
            _APP = venvappstr

        env['VIRTUAL_ENV'] = VIRTUAL_ENV
        env['VIRTUAL_ENV_NAME'] = VIRTUAL_ENV_NAME
        env['_APP'] = _APP
        return env


    def aliases(self):
        return self.env.aliases

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
                (k,v) for (k,v) in self.env.aliases.items()
                    if not k.startswith('cd')]
        return Venv._configure_ipython(*args, setup_func=setup_func, **kwargs)

    def generate_vars_env(self):
        """
        Generate a string containing VARIABLE='./value'
        """
        if self.env is None:
            return
        for block in self.env.to_string_iter():
            yield block

    def generate_bash_env(self):
        """
        Generate a ``source``-able script for the environment variables,
        aliases, and functions defined by the current ``Venv``.

        Yields:
            str: block of bash script
        """
        if self.env is None:
            return

        for k, v in self.env.items():
            yield ("export %s=%r" % (k, v))
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
            yield bash_alias

    def generate_vim_env(self):
        """
        Generate a ``source``-able vimscript for vim

        Yields:
            str: block of vim script
        """

        #for k, v in self.env.items():
        #    yield ("export %s=%r" % (k, v))

        for k, v in self.aliases.items():
            if hasattr(v, 'to_vim_function'):
                yield v.to_vim_function()


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
    def PROJECT_FILES(self):
        PROJECT_FILES = ' '.join(
                shell_quote(joinpath(self.env['_WRD'], fpath))
                    for fpath in (self.project_files))
        return PROJECT_FILES

    @property
    def _edit_project_cmd(self):
        """
        Command to edit ``self.project_files``

        Returns:
            str: ``$_EDIT_`` ``self.project_files``
        """
        return "%s %s" % (self.env['_EDIT_'], self.PROJECT_FILES)

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

            return os.system(_cmd)

    def open_editors(self):
        """
        Run ``self._edit_project_cmd``
        """
        cmd = self._edit_project_cmd
        return self.system(cmd=cmd)

    def open_terminals(self):
        """
        Run ``self._open_terminals_cmd``
        """
        cmd = self._open_terminals_cmd
        return self.system(cmd=cmd)

    def to_dict(self):
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
            str: json.dumps(self.to_dict())
        """
        class VenvJSONEncoder(json.JSONEncoder):
            def default(self, obj):
                if hasattr(obj, 'to_dict'):
                    return dict(obj.to_dict())
                if isinstance(obj, OrderedDict):
                    # TODO: why is this necessary?
                    return dict(obj)
                if isinstance(obj, CdAlias):
                    #return dict(type="cdalias",value=(obj.name, obj.pathvar))
                    return obj.pathvar
                return json.JSONEncoder.default(self, obj)
        return json.dumps(self, indent=indent, cls=VenvJSONEncoder)


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
        environ.update((k, str(v)) for (k, v) in venv.env.environ.items())
        return environ


    def call(self, command):
        """
        Args:
            command (str): command to run
        Returns:
            str: output from subprocess.call
        """
        env = self.update_os_environ(self, os.environ)
        prefix = self.env.get('prefix', self.env.get('VIRTUAL_ENV', None))
        return subprocess.call(
            command,
            shell=True,
            env=env,
            cwd=prefix)


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
    import json

    def ppd(self, *args, **kwargs):
        print(type(self))
        print(
            json.dumps(*args, indent=2))

## Tests

class Test_200_StepBuilder(unittest.TestCase):
    def test_000_Step(self):
        def build_func(env, **kwargs):
            return env
        s = Step(build_func)
        self.assertTrue(s)

    def test_500_StepBuilder(self):
        env = Env()
        env['_test'] = True
        builder = StepBuilder(env=env)
        new_env = builder.build()
        self.assertTrue(new_env)
        self.assertEqual(env, new_env)

        builder = StepBuilder()
        new_env = builder.build(env=env)
        self.assertTrue(new_env)
        self.assertEqual(env, new_env)

    def test_600_StepBuilder(self):
        env = Env()
        env['_test'] = True

        builder = StepBuilder()
        builder.add_step(PrintEnvStderrStep)
        new_env = builder.build(env=env)
        self.assertTrue(new_env)
        self.assertEqual(env, new_env)

class Test_700_venv_build_env(unittest.TestCase):

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

    def test_600_build_conda_cfg_env(self):
        env = build_conda_cfg_env()
        #env = build_conda_cfg_env(env=env, conda_root=None, conda_home=None)
        print(env)
        self.assertTrue(env)

    def test_600_build_venv_paths_full_env__prefix_None(self):
        with self.assertRaises(ConfigException):
            env = build_venv_paths_full_env()

    def test_610_build_venv_paths_full_env__prefix_None(self):
        env = build_venv_paths_full_env(prefix='/')
        print(env)
        self.assertTrue(env)
        self.assertIn('WORKON_HOME', env)

    def test_620_build_venv_paths_full_env__prefix_None(self):
        env = build_venv_activate_env(venvstr=self.env["VENVSTR"])
        env = build_venv_paths_full_env(env)
        print(env)
        self.assertTrue(env)
        self.assertIn('VIRTUAL_ENV', env)
        self.assertEqual(env["VIRTUAL_ENV"], self.env["VIRTUAL_ENV"])

    def test_650_build_venv_paths_cdalias_env(self):
        env = build_venv_paths_cdalias_env()
        print(env)
        self.assertTrue(env)


class Test_100_Env(unittest.TestCase):

    def test_010_Env(self):
        e = Env()
        self.assertTrue(e)
        assert 'WORKON_HOME' not in e
        e['WORKON_HOME'] = '~/-wrk/-ve'
        assert 'WORKON_HOME' in e
        assert 'WORKON_HOME' in e.environ

    def test_020_Env_copy(self):
        e = Env()
        self.assertNotIn('_test', e)
        e['_test'] = True
        self.assertIn('_test', e)
        e2 = e.copy()
        self.assertIn('_test', e2)
        e2['_test2'] = True
        self.assertIn('_test', e2)
        self.assertNotIn('_test', e)



    def test_Env_from_environ(self):
        import os
        e = Env.from_environ(os.environ)
        print(e)
        self.assertTrue(e)

class VenvTestUtils(object):
    @staticmethod
    def build_test_env():
        env = Env()
        env['__WRK']            = get___WRK_default()
        env['WORKON_HOME']      = get_WORKON_HOME_default()

        env['VENVSTR']          = 'dotfiles'

        env['VIRTUAL_ENV_NAME'] = 'dotfiles'
        env['_APP']             = env['VIRTUAL_ENV_NAME']
        env['VIRTUAL_ENV']      = joinpath(env['WORKON_HOME'],
                                           env['VIRTUAL_ENV_NAME'])

        env['prefix']           = env['VIRTUAL_ENV']
        env['_SRC']             = joinpath(env['prefix'], 'src')
        env['_ETC']             = joinpath(env['prefix'], 'etc')
        env['_WRD']             = joinpath(env['_SRC'], env['_APP'])
        return env


class Test_500_Venv(unittest.TestCase):

    def setUp(self):
        self.env = VenvTestUtils.build_test_env()

    def test_000_venv(self):
        with self.assertRaises(Exception):
            venv = Venv()


    def test_001_Venv_parse_venvstr(self):
        env = Venv.parse_venvstr(self.env, self.env['VENVSTR'])
        for attr in ['VIRTUAL_ENV', 'VIRTUAL_ENV_NAME', '_APP']:
            self.assertIn(attr, env)
            self.assertEqual(env[attr], self.env[attr])

    def test_005_venv(self):
        venv = Venv(venvstr=self.env['VENVSTR'])
        print(venv.env)
        for attr in ['VIRTUAL_ENV', 'VIRTUAL_ENV_NAME', '_APP']:
            self.assertIn(attr, venv.env)
            self.assertEqual(venv.env[attr], self.env[attr])

    def test_010_venv__APP(self):
        venv = Venv(venvstr=self.env['VIRTUAL_ENV'], _APP=self.env['_APP'])
        self.assertIn('_APP', venv.env)
        self.assertEqual(venv.env['_APP'], self.env['_APP'])

    def test_020_venv_from_null_environ(self):
        self.failUnlessRaises(Exception, Venv)

    def test_030_venv_without_environ(self):
        os.environ['VIRTUAL_ENV'] = self.env['VIRTUAL_ENV']
        venv = Venv()
        self.assertTrue(venv)


    def test_040_venv_with_environ(self):
        os.environ['VIRTUAL_ENV'] = self.env['VIRTUAL_ENV']
        venv = Venv(from_environ=True)
        venv

class Test_900_Venv_main(unittest.TestCase):
    def setUp(self):
        self.env = VenvTestUtils.build_test_env()

    def test_001_main_null(self):
        output = main()
        self.assertEqual(output, 0)

    #calls SystemExit
    #def test_002_main_help(self):
    #    output = main('-h')
    #    self.assertEqual(output, 0)
    #    output = main('--help')
    #    self.assertEqual(output, 0)

    def test_100_main(self):
        output = main('--ve','dotfiles','--app','dotfiles')
        self.assertEqual(output, 0)

    def test_110_main(self):
        output = main('dotfiles')
        self.assertEqual(output, 0)

    def test_200_main_print_bash(self):
        output = main('dotfiles', '--print-bash')
        self.assertEqual(output, 0)

    def test_300_main_print_zsh(self):
        output = main('dotfiles', '--print-zsh')
        self.assertEqual(output, 0)

    def test_400_main_print_vim(self):
        output = main('dotfiles', '--print-vim')
        self.assertEqual(output, 0)

## optparse.OptionParser

def build_venv_arg_parser():
    """
    Returns:
        optparse.OptionParser: options for the commandline interface
    """
    import argparse
    prs = argparse.ArgumentParser(
        prog="venv",
        #usage=("%prog [-b|--print-bash] [-t] [-e] [-E<virtualenv>] [appname]"),
        description=(
"""
venv is a configuration utility for virtual environments.

"""),
        epilog="Copyright 2014 Wes Turner. New BSD License.\n")


    prs.add_argument('-e','--from-environ',
                   help="Build venv.env.environ from keys in os.environ",
                   dest='from_environ',
                   action='store_true',
                   )
    prs.add_argument('--__WRK', '--WRK', '--wrk',
                   help="Path to workspace -- ~/-wrk",
                   dest='__WRK',
                   nargs='?',
                   action='store',
                   )
    prs.add_argument('--__DOTFILES', '--DOTFILES', '--dotfiles',
                     help="Path to dotfiles symlink -- ~/-dotfiles",
                     dest='__DOTFILES',
                     nargs='?',
                     action='store',
                   )
    prs.add_argument('--WORKON_HOME', '--workonhome', '--wh',
                     help="Path to working directory",
                     dest='WORKON_HOME',
                     nargs='?',
                     action='store',
                   )
    prs.add_argument('--prefix',
                     help='Prefix for _SRC, _ETC, _WRD if [ -z VIRTUAL_ENV ]',
                     dest='prefix',
                     nargs='?',
                     action='store')

    prs.add_argument('--VIRTUAL_ENV_NAME', '--virtual-env-name', '--vename',
                     help=("dirname in WORKON_HOME -- "
                           "WORKON_HOME/{VIRTUAL_ENV_NAME}"),
                     dest='VIRTUAL_ENV_NAME',
                     nargs='?',
                     action='store',
                   )
    prs.add_argument('--VIRTUAL_ENV', '--virtual-env', '--ve',
                     help=("Path to VIRTUAL_ENV -- "
                           "WORKON_HOME/{VIRTUAL_ENV_NAME} "
                           "(or a dirname in $WORKON_HOME) "),
                     dest='VIRTUAL_ENV',
                     nargs='?',
                     action='store',
                   )
    prs.add_argument('--_SRC', '--SRC', '--src',
                     help='Path to source -- VIRTUAL_ENV/src")',
                     dest='_SRC',
                     nargs='?',
                     action='store',
                    )
    prs.add_argument('--_APP', '--APP', '--app',
                     help="Path component string -- {_SRC}/{_APP}",
                     dest='_APP',
                     nargs='?',
                     action='store',
                   )
    prs.add_argument('--_WRD', '--WRD', '--wrd',
                     help="Path to working directory -- {_SRC}/{_APP}",
                     dest='_WRD',
                     nargs='?',
                     action='store',
                   )

    prs.add_argument('--platform',
                   help='Platform string (default: None)',
                   dest='platform',
                   action='store',
                   default=None,
                   )

    prs.add_argument('--print-json',
                   help="Print venv configuration as JSON",
                   dest='print_json',
                   action='store_true',
                   )
    prs.add_argument('--print-json-filename',
                   help="Path to write venv env JSON to",
                   dest='print_json_filename',
                   nargs='?',
                   action='store',
                   default='venv.json',
                   )
    prs.add_argument('--print-vars',
                   help='Print vars',
                   dest='print_vars',
                   #nargs='?',
                   action='store_true',
                   default=None,
                   )
    prs.add_argument('--print-bash', '--bash',
                   help="Print Bash shell configuration",
                   dest='print_bash',
                   action='store_true',
                   default=None,
                   #default='venv.bash.sh',
                   )
    prs.add_argument('--print-bash-filename',
                   help="Path to write Bash shell configuration into",
                   dest='print_bash_filename',
                   nargs='?',
                   action='store',
                   default='venv.bash.sh',
                   #default='venv.bash.sh',
                   )
    prs.add_argument('--print-bash-cdalias', '--bash-cdalias',
                   help="Print Bash cdalias script",
                   dest='print_bash_cdalias',
                   action='store_true',
                   )
    prs.add_argument('--print-bash-cdalias-filename',
                   help="Path to write Bash cdalias shell configuration into",
                   dest='print_bash_cdalias_filename',
                   nargs='?',
                   action='store',
                   default='venv.cdalias.sh',
                   #default='venv.bash.sh',
                   )
    prs.add_argument('--print-zsh',
                   help="Print ZSH shell configuration",
                   dest='print_zsh',
                   action='store_true',
                   )
    prs.add_argument('--print-zsh-filename',
                   help="Print ZSH shell configuration",
                   dest='print_zsh_filename',
                   action='store',
                   nargs='?',
                   default='venv.zsh.sh',
                   )
    prs.add_argument('--print-vim-cdalias',
                   help="Print vimscript configuration ",
                   dest='print_vim_cdalias',
                   action='store_true',
                   )
    prs.add_argument('--print-vim-cdalias-filename',
                   help="Path to write cdalias vimscript into",
                   dest='print_vim_cdalias_filename',
                   nargs='?',
                   action='store',
                   default='venv.cdalias.vim',
                   )

    prs.add_argument('-x', '--cmd', '--command',
                   help="Run a command in a venv-configured shell",
                   dest='run_command',
                   action='store',
                   )
    prs.add_argument('-b', '-xb', '--xbash',
                   help="Run bash in the specified venv",
                   dest='run_bash',
                   action='store_true',
                   )

    prs.add_argument('-E', '--open-editors','--edit', '--ed',
                   help=("Open $EDITOR_ with venv.project_files"
                         " [$PROJECT_FILES]"),
                   dest='open_editors',
                   action='store_true',
                   default=False,
                   )
    prs.add_argument('-T', '--open-terminals','--terminals',
                   help="Open terminals within the venv [gnome-terminal]",
                   dest='open_terminals',
                   action='store_true',
                   default=False,
                   )


    prs.add_argument('--pathall','-a', '--all-paths', '--ap',
        help="Print possible paths for the given path",
        dest="all_paths",
        action='store_true',
        )
    prs.add_argument('--pwrk', '--wrk-path',
        help="Print $__WRK/$@",
        dest="path__WRK",
        )
    prs.add_argument('--pworkonhome', '--workonhome-path','--pwh',
        help="Print $__WORKON_HOME/$@",
        dest="path_WORKON_HOME",
        )
    prs.add_argument('--pvirtualenv', '--virtualenv-path', '--pv',
        help="Print $VIRTUAL_ENV/${@}",
        dest='path_VIRTUAL_ENV',
        action='store_true',
        )
    prs.add_argument('--psrc', '--src-path', '--ps',
        help="Print $_SRC/${@}",
        dest='path__SRC',
        action='store_true',
        )
    prs.add_argument('--pwrd', '--wrd-path', '--pw',
        help="Print $_WRD/${@}",
        dest='path__WRD',
        action='store_true',
        )
    prs.add_argument('--pdotfiles', '--dotfiles-path', '--pd',
        help="Print ${__DOTFILES}/${path}",
        dest='path__DOTFILES',
        action='store_true',
        )


    prs.add_argument('--prel', '--relative-path',
        help="Print ${@}",
        dest='relative_path',
        action='store_true',
        )
    prs.add_argument('--pkg-resource-path',
        help="Path from pkg_resources.TODOTODO",
        dest="pkg_resource_path",
        action='store_true',
        )

    prs.add_argument('--diff', '--show-diffs',
                   dest='show_diffs',
                   action='store_true',)
    prs.add_argument('-v', '--verbose',
                   dest='verbose',
                   action='store_true',)
    prs.add_argument('-q', '--quiet',
                   dest='quiet',
                   action='store_true',)
    prs.add_argument('-t', '--test',
                   dest='run_tests',
                   action='store_true',)
    prs.add_argument('--version',
                   dest='version',
                   action='store_true',)

    prs.add_argument('venvstr', nargs='?', action='store')
    prs.add_argument('venvappstr', nargs='?', action='store')

    # Store remaining args in a catchall list (opts.args)
    prs.add_argument('args', metavar='args', nargs=argparse.REMAINDER)
    return prs


def main(*argv):
    """
    main function called if ``__name__=="__main__"``

    Returns:
        int: nonzero on error
    """
    import logging
    stderr = None
    stdout = None
    if not stderr:
        stderr = sys.stderr
    if not stdout:
        stdout = sys.stdout

    prs = build_venv_arg_parser()
    if not argv:
        _argv = sys.argv[1:]
    else:
        _argv = list(argv)

    def comment_comment(strblock, **kwargs):
        return u'\n'.join(
            prepend_comment_char(pprint.pformat(strblock),**kwargs))

    def dbglog(obj, file=sys.stderr):
        return print(comment_comment(obj), file=file)

    dbglog(
        {"sys.argv": sys.argv,
         "*argv": argv,
         "_argv": _argv},
        file=stderr)
    opts = prs.parse_args(args=_argv)
    args = opts.args
    dbglog(
        {"sys.argv": sys.argv,
         "*argv": argv,
         "_argv": _argv,
         "args": args,
         "opts": opts.__dict__},
        file=stderr)

    if not opts.quiet:
        logging.basicConfig()

        if opts.verbose:
            logging.getLogger().setLevel(logging.DEBUG)

    if opts.run_tests:
        sys.argv = [sys.argv[0]] + opts.args
        sys.exit(unittest.main())

    ## build or create a new Env
    if opts.from_environ:
        env = Env.from_environ(os.environ, verbose=opts.verbose)
    else:
        env = Env()

    ## read variables from options into the initial env dict

    varnames = ['__WRK','__DOTFILES','WORKON_HOME',
                'VIRTUAL_ENV_NAME', 'VIRTUAL_ENV', '_SRC', '_WRD']

    for varname in varnames:
        value = getattr(opts, varname, None)
        if value is not None:
            existing_value = env.get(varname)
            if existing_value != value:
                dbglog({
                    'msg': 'commandline options intersect with env',
                    'varname': varname,
                    'value': value
                }, file=stderr)
            env[varname] = value

    # virtualenv [, appname]
    venv = Venv(env=env,
                venvstr=opts.venvstr,
                venvappstr=opts.venvappstr,
                open_editors=opts.open_editors,
                open_terminals=opts.open_terminals,
                prefix=opts.prefix,
                show_diffs=opts.show_diffs,
                debug=opts.verbose,
                )

    output = sys.stdout

    if opts.print_vars:
        # skip print(str(env)) if writing to bash, zsh, vim
        if not any ((opts.print_bash, opts.print_zsh, opts.print_vim_cdalias,
                    opts.print_json)):
            for block in venv.generate_vars_env():
                print(block, file=output)

    if opts.print_json:
        print(venv.to_json(indent=4), file=output)

    if opts.print_bash:
        for block in venv.generate_bash_env():
            print(block, file=output)

    if opts.print_vim_cdalias:
        for block in venv.generate_vim_env():
            print(block, file=output)

    if opts.run_command:
        prcs = venv.call(opts.run_command)

    if opts.run_bash:
        prcs = venv.call('bash')

    if opts.version:
        try:
            import dotfiles
            version = dotfiles.version
            print(version, file=sys.stdout)
            return 0
        except ImportError:
            return 127

    def get_pkg_resource_filename(filename):
        import pkg_resources
        return pkg_resources.resource_filename(filename)

    if any((opts.all_paths,
            opts.path__WRD,
            opts.path__DOTFILES,
            opts.relative_path)):
        paths = []
        if opts.venvstr:
            paths.append(opts.venvstr)
        if opts.venvappstr:
            paths.append(venvappstr)
        paths.extend(args)
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
    sys.exit(main(*sys.argv[1:]))
