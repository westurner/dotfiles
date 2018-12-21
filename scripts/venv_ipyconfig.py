#!/usr/bin/env python
# encoding: utf-8
from __future__ import print_function
"""

dotfiles.venv.venv_ipyconfig
==============================
venv_ipyconfig.py (venv)

Create virtual environment configurations
with a standard filesystem hierarchy overlay
and cd aliases for Bash, ZSH, Vim, and IPython
for use with virtualenv, virtualevwrapper,
and anything that has or should have
a prefix like ``VIRTUAL_ENV`` and
directories like
``./bin``, ``./etc``, ``./var/log``, and ``./src``.

Functional comparisons:

* T-Square, Compass, Table Sled, Stencil, Template, Floorplan, Lens


Venv Implementation
-------------------

- create an :py:mod:`Env` (``env = Env()``)
- define ``__WRK`` workspace root
- define ``VIRTUAL_ENV``, ``_SRC``, ``_ETC``, ``_WRD``
- define ``WORKON_HOME``

- create and add :py:mod:`Steps` (``builder.add_step(step_func)``)

  - define variables like ``env['__WRK']`` (``Venv.env.environ['PATH']``)
  - define IPython shell command aliases (``Env.aliases``,
    ``e``, ``ps``, ``git``, ``gitw``)

- create a :py:mod:`StepBuilder` (``builder = StepBuilder()``)
- build a new env from steps: ``new_env = builder.build(env)``

- print an :py:mod:`Env`to:

  - ``--print-json`` -- JSON (Env.to_dict, Env.to_json)
  - ``--print-ipython`` -- IPython configuration (Env.environ, Env.aliases)
  - ``--print-bash`` -- Bash configuration (Env.environ, Env.aliases)
  - ``--print-bash-cdalias`` -- Bash configuration (Env.environ, Env.aliases)
  - ``--print-zsh`` ZSH -- configuration (Env.environ, Env.aliases)
  - ``--print-zsh-cdalias`` -- ZSH configuration (Env.environ, Env.aliases)
  - ``--print-vim-cdalias`` -- Vim configuration (Env.aliases)

- generate and source CdAliases that expand and complete where possible
  (``cdwrk``, ``cdwrd``, ``cdw``)

  - define CdAliases in venv_ipyconfig.py (this file)
  - generate venv.sh (``cdwrk``)
  - generate venv.vim (``:Cdwrk``)
  - generate venv_cdmagic.py (``%cdwrk``, ``cdwrk``)


.. note::

   This module may only import from the Python standard library,
   so that it always works as ``~/.ipython/profile_default/venv_ipyconfig.py``

"""
import collections
import copy
import difflib
import distutils.spawn
import functools
import inspect
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

# try/except imports for IPython
# import IPython
# import zmq
## import sympy

if sys.version_info[0] == 2:
    STR_TYPES = basestring
    str_center = unicode.center
    import StringIO

    # workaround for Sphinx autodoc bug
    import __builtin__

    def print(*args, **kwargs):
        __builtin__.print(*args, **kwargs)

else:
    STR_TYPES = str
    str_center = str.center
    import io
    StringIO = io.StringIO

LOGNAME = 'venv'
log = logging.getLogger(LOGNAME)

__THISFILE = os.path.abspath(__file__)
#  __VENV_CMD = "python {~venv_ipyconfig.py}"
#  __VENV_CMD = "python %s" % __THISFILE

IN_IPYTHON = 'get_ipython' in locals()
IN_IPYTHON_CONFIG = 'get_config' in globals()
#print(("IN_IPYTHON", IN_IPYTHON))
#print(("IN_IPYTHON_CONFIG", IN_IPYTHON_CONFIG))

if IN_IPYTHON_CONFIG:
    IPYTHON_CONFIG = get_config()
else:
    IPYTHON_CONFIG = None

def in_venv_ipyconfig():
    """
    Returns:
        bool: True if ``get_ipython`` is in ``globals()``
    """
    return IN_IPYTHON_CONFIG

DEBUG_TRACE_MODPATH = False

def logevent(event,
             obj=None,
             logger=log,
             level=logging.DEBUG,
             func=None,
             lineno=None,
             modpath=None,
             show_modpath=None,
             wrap=False,
             splitlines=True):
    """
    Args:
        event (str): an event key
        obj (thing): thing to serialize and log
        logger (logging.Logger): logger to log to
        level (int): logging loglevel to log (event, obj)
        wrap (bool): Add header and footer <event> tags (default: False)
        splitlines (bool): split by newlines and emit one log message per line
    Returns:
        tuple: (event:str, output:str)
    """
    eventstr = event.replace('\t', '<tab/>')     # XXX: raises

    if show_modpath is None:
        show_modpath = DEBUG_TRACE_MODPATH

    if show_modpath and modpath is None:
        modpath = []
        _frame = frame = sys._getframe(1)
        if _frame:
            name = _frame.f_code.co_name
            if name == '<module>':
                name = _frame.f_globals['__name__']
            modpath.append((name, _frame.f_lineno))
            while hasattr(_frame, 'f_back'):
                _frame = _frame.f_back
                if hasattr(_frame, 'f_code') and hasattr(_frame, 'f_lineno'):
                    name = _frame.f_code.co_name
                    if name == '<module>':
                        name = "%s %s" % (
                            _frame.f_globals['__name__'],
                            os.path.basename(_frame.f_code.co_filename),
                        )
                    modpath.append((name, _frame.f_lineno))
            if hasattr(_frame, 'f_globals'):
                modpath[-1][0] = _frame.f_globals['__name__']

    funcstr = None

    if func is not None:
        funcstr = getattr(func, '__name__',
                            func if isinstance(func, STR_TYPES)
                            else None)
        if modpath:
            modpath.append((funcstr,))

    if modpath:
        funcstr = ' '.join("%s +%d" % (x,y) for x, y in modpath)

    def add_event_prefix(eventstr, line, funcstr=funcstr):
        if funcstr:
            fmtstr = '{eventstr}\t{line}\t##{funcstr}'
        else:
            fmtstr = '{eventstr}\t{line}'
        return fmtstr.format(
            eventstr=eventstr,
            line=line,
            funcstr=funcstr)

    def _log(event, output):
        logger.log(level, add_event_prefix(event, output))

    if wrap:
        _log(event, '# <{eventstr}>'.format(eventstr=eventstr))

    output = None
    if hasattr(obj, 'to_json'):
        output = obj.to_json(indent=2)
    else:
        output = pprint.pformat(obj)

    if splitlines:
        for line in output.splitlines():
            _log(event, line)  # TODO: comment?
    else:
        _log(event, output)

    if wrap:
        _log(event, '# </{eventstr}>'.format(eventstr=eventstr))

    return (event, output)


# Exception classes

class ConfigException(Exception):
    pass


class StepException(Exception):
    pass


class StepConfigException(StepException, ConfigException):
    pass


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


# Constant getters (for now)

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


def get___WRK_default(env=None, **kwargs):
    if env is None:
        env = Env()
    __WRK = kwargs.get('__WRK',
                       env.get('__WRK',
                               os.path.expanduser('~/-wrk')))
    log.debug('get__WRK\t%s' % {'__WRK': __WRK,
                                'env[__WRK]': env.get('__WRK')})
    return __WRK


def get_WORKON_HOME_default(env=None,
                            from_environ=False,
                            default='-ve27',
                            **kwargs):
    """
    Keyword Arguments:
        env (dict): Env dict to read from (default: None)
        from_environ (bool): read WORKON_HOME from os.environ
        default (str): default WORKON_HOME dirname
        __WRK (str):

    Returns:
        str: path to a ``WORKON_HOME`` directory

    """
    __WORKON_HOME_DEFAULT = default
    if env is None:
        if from_environ:
            env = Env.from_environ(os.environ)  # TODO: os.environ.copy()
        else:
            env = Env()
    env['__WRK'] = kwargs.get('__WRK',
                              env.get('__WRK',
                                      get___WRK_default(env=env)))
    workon_home = env.get('WORKON_HOME')  # TODO: WORKON_HOME_DEFAULT
    if workon_home:
        return workon_home
    python27_home = env.get('WORKON_HOME__py27')
    if python27_home:
        workon_home = python27_home
        return workon_home
    else:
        python27_home = joinpath(env['__WRK'], __WORKON_HOME_DEFAULT)
        workon_home = python27_home
        return workon_home
    workon_home = os.path.expanduser('~/.virtualenvs/')
    if os.path.exists(workon_home):
        return workon_home
    workon_home = joinpath(env['__WRK'], __WORKON_HOME_DEFAULT)
    return workon_home


class VenvJSONEncoder(json.JSONEncoder):

    def default(self, obj):
        if hasattr(obj, 'to_dict'):
            return dict(obj.to_dict())
        if isinstance(obj, OrderedDict):
            # TODO: why is this necessary?
            return dict(obj)
        if hasattr(obj, 'to_bash_function'):
            return obj.to_bash_function()
        if hasattr(obj, 'to_shell_str'):
            return obj.to_shell_str()
        if isinstance(obj, CdAlias):
            # return dict(type="cdalias",value=(obj.name, obj.pathvar))
            return obj.pathvar
        return json.JSONEncoder.default(self, obj)

##############
# define aliases as IPython aliases (which support %l and %s,%s)
# which can then be transformed to:
# * ipython aliases ("echo %l; ping -t %s -n %s")


class CmdAlias(object):

    """
    """

    def __init__(self, cmdstr):
        """
        Args:
            cmdstr (str): command alias
        """
        self.cmdstr = cmdstr

    def to_shell_str(self, name=None):
        """
        Generate an alias or function for bash/zsh

        Keyword Arguments:
            name (str): funcname to override default
        Returns:
            str: self.cmdstr (AS-IS)
        """
        return self.cmdstr

    def to_ipython_alias(self):
        """
        Generate an alias for IPython

        Returns:
            str: self.cmdstr (AS-IS)
        """
        return self.cmdstr

    #def to_vim_function(self):
    #    """
    #    Generate a vim function

    #    Raises:
    #        NotImplemented: See IpyAlias.to_vim_function
    #        str: self.cmdstr (AS-IS)
    #    """
    #    raise NotImplemented

    __str__ = to_shell_str
    __repr__ = to_shell_str


class IpyAlias(CmdAlias):

    """
    An IPython alias command string
    which expands to a shell function ``aliasname() { ... }``
    and handles positional args ``%s`` and ``%l``

    References:

        * TODO: IPython docs
    """

    def __init__(self, cmdstr, name=None, complfuncstr=None):
        """
        Args:
            cmdstr (str): if cmdstr contains ``%s`` or ``%l``,
                it will be expanded to a shell function
        Keyword Arguments:
            name (str): None to set at serialization
                (so that ``$ type cmd`` shows the actual command)
        """
        self.name = name
        self.cmdstr = cmdstr
        self.complfuncstr = complfuncstr

    def to_shell_str(self, name=None):
        """
        Generate an alias or function for bash/zsh

        Keyword Arguments:
            name (str): funcname to override default
        Returns:
            str: an ``alias`` or a ``function()``

            .. code:: bash

                alias name=repr(cmdstr)
                # or
                cmdname () {
                    cmdstr
                }
        """
        alias = self.cmdstr
        name = getattr(self, 'name') if name is None else name
        if '%s' in alias or '%l' in alias:
            # alias = '# %s' % alias
            # chunks = alias.split('%s')
            _alias = alias[:]
            count = 0
            while '%s' in _alias:
                count += 1
                _alias = _alias.replace('%s', '${%d}' % count, 1)
            _aliasmacro_tmpl = (
                u'eval \'{funcname} () {{\n    {funcstr}\n}}\';')
            _aliasmacro = _aliasmacro_tmpl.format(
                funcname=name,
                funcstr=_alias)
            _aliasmacro = _aliasmacro.replace('%l', '${@}')
            if self.complfuncstr:
                complfuncname = '_%s__complete' % name
                _aliasmacro = u'%s\n%s\ncomplete -o default -o nospace -F %s %s ;' % (
                    _aliasmacro,
                    _aliasmacro_tmpl.format(
                        funcname=complfuncname,
                        funcstr=self.complfuncstr.strip()),
                    complfuncname,
                    name)
            return _aliasmacro

        # TODO: repr(alias) / shell_quote / mangling #XXX
        return 'alias {}={} ;'.format(name, repr(alias))


class CdAlias(CmdAlias):

    """
    A CmdAlias for ``cd`` change directory
    functions with venv paths (e.g. $_WRD)
    for Bash, ZSH, IPython, Vim.

    * venv.sh bash functions with tab-completion (cdwrd, cdw, cdw<tab>)
    * venv_ipymagics.py: ipython magics (%cdwrd, cdwrd, cdw)
    * venv.vim: vim functions  (:Cdwrd)
    """

    def __init__(self, pathvar, name=None, aliases=None):
        """
        Args:
            pathvar (str): path variable to cd to
        Keyword Arguments:
            name (str): alias name (default: ``pathvar.lower.replace('_','')``)
                _WRD -> cdwrd, :Cdwrd
                WORKON_HOME -> workonhome
            aliases (list[str]): additional alias names (e.g. ['cdw',])

        .. py:attribute:: BASH_ALIAS_TEMPLATE

        .. py:attribute:: BASH_FUNCTION_TEMPLATE

        .. py:attribute:: BASH_COMPLETION_TEMPLATE

        .. py:attribute:: VENV_IPYMAGICS_FILE_HEADER

        .. py:attribute:: VENV_IPYMAGIC_METHOD_TEMPLATE

        .. py:attribute:: VIM_COMMAND_TEMPLATE

        .. py:attribute:: VIM_FUNCTION_TEMPLATE
        """

        self.pathvar = pathvar
        self.cmdstr = "cd {}".format(self.pathvar)

        if name is None:
            name = pathvar.lower().replace('_', '')
        self.name = name
        if aliases is None:
            aliases = list()
        self.aliases = aliases

    VENV_IPYMAGICS_FILE_HEADER = (
        '''
#!/usr/bin/env ipython
# dotfiles.venv.venv_ipymagics
from __future__ import print_function
"""
IPython ``%magic`` commands

* ``cd`` aliases
* ``ds`` (``dotfiles_status``)
* ``dr`` (``dotfiles_reload``)

Installation
--------------
.. code-block:: bash

    __DOTFILES="${HOME}/-dotfiles"
    ipython_profile="profile_default"
    ln -s ${__DOTFILES}/etc/ipython/venv_ipymagics.py \\
        ~/.ipython/${ipython_profile}/startup/venv_ipymagics.py
"""
import os
import sys
try:
    from IPython.core.magic import (Magics, magics_class, line_magic)
except ImportError:
    print("ImportError: IPython")
    # Mock IPython for building docs
    Magics = object
    magics_class = lambda cls, *args, **kwargs: cls
    line_magic = lambda func, *args, **kwargs: func

if sys.version_info.major == 2:
    str = unicode

def ipymagic_quote(_str):
    return str(_str)

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
        _dstpath = line.lstrip(os.path.sep)
        path = os.path.join(prefix, _dstpath)
        cmd = ("cd %s" % ipymagic_quote(path))
        print("%" + cmd, file=sys.stderr)
        return self.shell.magic(cmd)''')

    VENV_IPYMAGIC_METHOD_TEMPLATE = (
        '''
    @line_magic
    def {ipy_func_name}(self, line):
        """{ipy_func_name}    -- cd ${pathvar}/${{@}}"""
        return self.cd('{pathvar}', line)''')

    VENV_IPYMAGICS_FOOTER = (
        '''
    @line_magic
    def cdhelp(self, line):
        """cdhelp()         -- list cd commands"""
        for cdfunc in dir(self):
            if cdfunc.startswith('cd') and cdfunc not in ('cdhelp','cd'):
                docstr = getattr(self, cdfunc).__doc__.split('--',1)[-1].strip()
                print("%%%-16s -- %s" % (cdfunc, docstr))

    @staticmethod
    def _dotfiles_status():
        """
        Print ``dotfiles_status``: venv variables
        """
        env_vars = [
            'HOSTNAME',
            'USER',
            'PROJECT_HOME',
            'WORKON_HOME',
            'VIRTUAL_ENV_NAME',
            'VIRTUAL_ENV',
            '_USRLOG',
            '_TERM_ID',
            '_SRC',
            '_APP',
            '_WRD',
            'PATH',
            '__DOTFILES',
        ]
        environ = dict((var, os.environ.get(var)) for var in env_vars)
        environ['HOSTNAME'] = __import__('socket').gethostname()
        for var in env_vars:
            print('{}="{}"'.format(var, "%s" % environ.get(var,'')))

    @line_magic
    def dotfiles_status(self, line):
        """dotfiles_status()    -- print dotfiles_status() ."""
        return self._dotfiles_status()

    @line_magic
    def ds(self, line):
        """ds()                 -- print dotfiles_status() ."""
        return self._dotfiles_status()

    @staticmethod
    def _dotfiles_reload():
        """_dotfiles_reload()   -- print NotImplemented"""
        print("NotImplemented: dotfiles_reload()")

    @line_magic
    def dotfiles_reload(self, line):
        """dotfiles_reload()    -- print NotImplemented"""
        return self._dotfiles_reload()

    @line_magic
    def dr(self, line):
        """dr()                 -- print NotImplemented [dotfiles_reload()]"""
        return self._dotfiles_reload()


def main():
    """
    Register VenvMagics with IPython
    """
    import IPython
    ip = IPython.get_ipython()
    ip.register_magics(VenvMagics)


if __name__ == "__main__":
    main()
''')

    def to_ipython_method(self):
        """
        Keyword Arguments:
            include_completions (bool): generate inline Bash completions
        Returns:
            str: ipython method block
        """

        for cmd_name in self.bash_func_names:
            yield (CdAlias.VENV_IPYMAGIC_METHOD_TEMPLATE.format(
                pathvar=self.pathvar,
                ipy_func_name=cmd_name))

    VIM_HEADER_TEMPLATE = (
        '''\n'''
        '''" ### venv.vim\n'''
        '''" # Src: https://github.com/westurner/venv.vim\n\n'''
        '''function! Cd_help()\n'''
        '''" cdhelp()           -- list cd commands\n'''
        '''    :verbose command Cd\n'''
        '''endfunction\n'''
        '''command! -nargs=0 Cdhelp call Cd_help()\n'''
        '''\n''')

    VIM_FUNCTION_TEMPLATE = (
        '''function! {vim_func_name}(...)\n'''
        '''" {vim_func_name}()  -- cd ${pathvar}/$1\n'''
        '''    if ${pathvar} ==? ''\n'''
        '''        echoerr "${pathvar} is not set"\n'''
        '''        return\n'''
        '''    endif\n'''
        '''    if a:0 > 0\n'''
        '''       let pathname = join([${pathvar}, a:1], "/")\n'''
        '''    else\n'''
        '''       let pathname = "${pathvar}"\n'''
        '''    endif\n'''
        '''    execute '{vim_cd_func}' pathname \n'''
        '''    pwd\n'''
        '''endfunction\n'''
        '''\n'''
        '''function! Compl_{vim_func_name}(ArgLead, ...)\n'''
        '''    if ${pathvar} ==? ''\n'''
        '''        echoerr "${pathvar} is not set"\n'''
        '''        return []\n'''
        '''    endif\n'''
        '''    lcd ${pathvar}\n'''
        '''    return map(sort(filter(globpath('.', a:ArgLead . '*/', 0, 1), 'isdirectory(v:val)'), 'i'), 'v:val[2:]')\n'''
        '''    lcd -\n'''
        '''    endfor\n'''
        '''endfunction\n'''

    )
    VIM_COMMAND_TEMPLATE = (
        '''"   :{cmd_name} -- {vim_func_name}()\n'''
        """command! -nargs=* -complete=customlist,Compl_{vim_func_name} {cmd_name} call {vim_func_name}(<f-args>)\n"""
    )

    @property
    def vim_cmd_name(self):
        """
        Returns:
            str: e.g "Cdwrd"
        """
        return "Cd{}".format(self.name)

    @property
    def vim_cmd_names(self):
        """
        Returns:
            list: self.vim_cmd_name + self.aliases.title()
        """
        return ([self.vim_cmd_name, ] +
                [alias.title() for alias in self.aliases
                 if not alias.endswith('-')])

    def to_vim_function(self):
        """
        Returns:
            str: vim function block
        """
        confs = []
        conf = {}
        conf['pathvar'] = self.pathvar
        conf['vim_func_name'] = "Cd_" + self.pathvar
        conf['vim_cmd_name'] = self.vim_cmd_name
        conf['vim_cmd_names'] = self.vim_cmd_names
        conf['vim_cd_func'] = 'cd'
        confs.append(conf)
        conf2 = conf.copy()
        conf2['vim_func_name'] = "L" + conf['vim_func_name']
        conf2['vim_cmd_name'] = "L" + conf['vim_cmd_name']
        conf2['vim_cmd_names'] = ["L{}".format(x) for x in conf['vim_cmd_names']]
        conf2['vim_cmd_names'] += ["L{}".format(x).title() for x in conf['vim_cmd_names']]
        conf2['vim_cd_func'] = 'lcd'
        confs.append(conf2)
        output = []
        for conf in confs:
            output += (CdAlias.VIM_FUNCTION_TEMPLATE.format(**conf),)
            for cmd_name in conf['vim_cmd_names']:
                output += (CdAlias.VIM_COMMAND_TEMPLATE
                                .format(cmd_name=cmd_name,
                                        pathvar=conf['pathvar'],
                                        vim_func_name=conf['vim_func_name']),)
        return u''.join(output)

    BASH_CDALIAS_HEADER = (
        '''#!/bin/sh\n'''
        """## venv.sh\n"""
        """# generated from $(venv --print-bash --prefix=/)\n"""
        """\n""")

    BASH_FUNCTION_TEMPLATE = (
        """{bash_func_name} () {{\n"""
        """    # {bash_func_name:16}  -- cd ${pathvar} /$@\n"""
        """    [ -z "${pathvar}" ] && echo "{pathvar} is not set" && return 1\n"""
        """    cd "${pathvar}"${{@:+"/${{@}}"}}\n"""
        """}}\n"""
        """{bash_compl_name} () {{\n"""
        """    local cur="$2";\n"""
        """    COMPREPLY=($({bash_func_name} && compgen -d -- "${{cur}}" ))\n"""
        """}}\n"""
    )
    BASH_ALIAS_TEMPLATE = (
        """{cmd_name} () {{\n"""
        """    # {cmd_name:16}  -- cd ${pathvar}\n"""
        """    {bash_func_name} $@\n"""
        """}}\n"""
    )
    BASH_COMPLETION_TEMPLATE = (
        """complete -o default -o nospace -F {bash_compl_name} {cmd_name}\n"""
    )

    @property
    def bash_func_name(self):
        """
        Returns:
            str: e.g. "cdwrd"
        """
        return "cd{}".format(self.name)

    @property
    def bash_func_names(self):
        """
        Returns:
            list: self.bash_func_name + self.aliases
        """
        return [self.bash_func_name, ] + self.aliases

    def to_bash_function(self, include_completions=True):
        """
        Keyword Arguments:
            include_completions (bool): generate inline Bash completions
        Returns:
            str: bash function block
        """
        conf = {}
        conf['pathvar'] = self.pathvar
        conf['bash_func_name'] = self.bash_func_name
        conf['bash_func_names'] = self.bash_func_names
        conf['bash_compl_name'] = "_cd_%s_complete" % self.pathvar

        def _iter_bash_function(conf):
            yield (CdAlias.BASH_FUNCTION_TEMPLATE.format(**conf))
            for cmd_name in conf['bash_func_names'][1:]:
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

    # def to_shell_str(self):
    #    return 'cd {}/%l'.format(shell_varquote(self.PATH_VARIABLE))
    def to_shell_str(self):
        """
        Returns:
            str: eval \'{_to_bash_function()}\'
        """
        return """eval \'\n{cmdstr}\n\';""".format(
            cmdstr=self.to_bash_function())

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
            func (callable): ``function(env=None, **kwargs)``
            name (str): a name for the step
            conf (dict): a configuration dict (instead of kwargs) for this step
        """
        if not func:
            func = self.DEFAULT_FUNC
        self.func = func
        self._name = kwargs.get('name')
        self.build = func
        # remove env from the conf dict # XXX
        kwargs.pop('env', None)
        # conf = kwargs if conf=None
        self.conf = kwargs.get('conf', kwargs)

    @property
    def name(self):
        """
        Returns:
            str: a name for this Step
        """
        namestr = getattr(self.func, '__name__', self.func)
        if self._name is not None:
            namestr = "%s %s" % (self._name, namestr)
        return namestr

    @name.setter
    def __set_name(self, name):
        self._name = name

    def __str__(self):
        return '<step name=%s>' % (self.name)

    def __repr__(self):
        return '<step name=%s>' % (self.name)

    def _iteritems(self):
        """
        Yields:
            tuple: ('attrname', obj)
        """
        yield ('name', self.name)
        yield ('func', self.func)
        yield ('conf', self.conf)

    def asdict(self):
        """
        Returns:
            OrderedDict: OrderedDict(self._iteritems())
        """
        return OrderedDict(self._iteritems())

    def build_print_kwargs_env(self, env=None, **kwargs):
        """
        Default ``build_*_env`` Step.func function to print ``env``

        Keyword Arguments:
            env (:py:mod:`Env`): Env object (default: None)
            kwargs (dict): kwargs dict

        Returns:
            :py:mod:`Env`: updated Env
        """
        if env is None:
            env = Env()
        else:
            # Note: StepBuilder also does env.copy before each step
            # making this unnecessary for many build_*_env functions
            env = env.copy()
        env['kwargs'] = kwargs
        output = env.to_json()
        logevent('build_print_kwargs_env', comment_comment(output))
        env.pop('kwargs', None)
        return env

    DEFAULT_FUNC = build_print_kwargs_env
    func = DEFAULT_FUNC

    def build(self, env=None, **kwargs):
        """
        Call ``self.func(env=env, **self.conf.copy().update(**kwargs))``

        Keyword Arguments:
            env (Env): Env object (default: None)
            kwargs (dict): kwargs dict
        Returns:
            obj: ``self.func(env=env, **self.conf.copy().update(**kwargs))``
        """
        conf = self.conf.copy()
        conf.update(kwargs)  # TODO: verbose merge
        return self.func(env=env, **conf)


class PrintEnvStep(Step):

    """
    Print env and kwargs to stdout
    """
    _name = 'print_env'
    stdout = sys.stdout
    stderr = sys.stderr
    func = Step.build_print_kwargs_env


class PrintEnvStderrStep(PrintEnvStep):

    """
    Print env and kwargs to stderr
    """
    _name = 'print_env_stderr'
    stdout = sys.stderr


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
        self.conf["show_diffs"] = kwargs.get(
            'show_diffs',
            self.conf.get('show_diffs'))
        self.conf["debug"] = kwargs.get('debug', self.conf.get('debug'))
        logevent('StepBuilder %s %s' % (self.name, '__init__'))

    @property
    def name(self):
        return getattr(self, '_name', str(hex(id(self))))

    @property
    def debug(self):
        """
        Returns:
            str: self.conf.get('debug')
        """
        return self.conf.get('debug')

    @property
    def show_diffs(self):
        """
        Returns:
            str: self.conf.get('show_diffs')
        """
        return self.conf.get('show_diffs')

    def add_step(self, func, **kwargs):
        """
        Add a step to ``self.steps``

        Args:
            func (Step or function or str): ``func(env=None, **kwargs)``
            kwargs (dict): kwargs for Step.conf
        Keyword Arguments:
            name (str): function name (default: None)
        Returns:
            :py:mod:`Step`: Step object appended to self.steps
        """
        if isinstance(func, Step):
            step = func(**kwargs)
        elif isinstance(func, STR_TYPES):
            step = PrintEnvStep(name=func)
        elif callable(func):
            step = Step(func, name=kwargs.get('name'), conf=kwargs)
        else:
            raise StepConfigException({
                'func': func,
                'msg': 'func must be a (Step, STR_TYPES, callable)'})
        self.steps.append(step)
        return step

    def build_iter(self, env=None, show_diffs=True, debug=False):
        """
        Build a generator of (Step, Env) tuples from the
        functional composition of StepBuilder.steps
        given an initial :py:mod:`Env` (or None).

        .. code:: python

            # pseudocode
            env_previous = Env()
            for step in self.steps:
                (step, env) = step.build(env=env_previous.copy(),**conf)
                env_previous=env

        Keyword Arguments:
            env (Env): initial Env (default: None)
            show_diffs (bool): show difflib.ndiffs of Envs between steps
            debug (bool):
        Yields:
            tuple: (:py:mod:`Step`, :py:mod:`Env`)
        """
        if env:
            env0 = env
            env = env0.copy()
        else:
            env = Env()

        yield (PrintEnvStep('env0'), env)
        output = sys.stdout
        # log = global log

        for step in self.steps:
            logevent('BLD %s build %s' % (self.name, step.name),
                     str_center(u" %s " % step.name, 79, '#'),)
            logevent('%s build.conf' % step.name, self.conf, wrap=True)
            logevent('%s step.conf ' % step.name, step.conf, wrap=True)
            logevent('%s >>> %s' % (step.name, hex(id(env))),
                     env, wrap=True)
            env = env.copy()
            conf = self.conf.copy()
            conf.update(**step.conf)

            new_env = step.build(env=env, **conf)
            logevent('%s >>> %s' % (step.name, hex(id(new_env))),
                     new_env,
                     wrap=True)

            if isinstance(new_env, Env):
                # logevent('%s new_env' % step.name, new_env, wrap=True)
                if self.show_diffs and env:
                    diff_output = env.ndiff(new_env)
                    logevent('%s <diff>' % step.name)
                    for line in diff_output:
                        logevent('diff', line.rstrip())
                    logevent('%s </diff>' % step.name)
                yield (step, new_env)
                env = new_env
            else:
                logevent("# %r returned %r which is not an Env"
                         % (step.name, new_env))
            logevent('%s stepdict' % step.name, step.__dict__, wrap=True)

    def build(self, *args, **kwargs):
        """
        Build a list of Envs from ``self.build_iter(*args, **kwargs)``
        and return the last Env.

        Keyword Arguments:
            debug (bool): log.debug(env)

        Returns:
            Env or None: the last env returned from ``.build_iter``

        """
        debug = kwargs.get('debug', self.debug)
        step_envs = []
        logevent('BLD %s %s' % (self.name, 'build'))
        for env in self.build_iter(*args, **kwargs):
            step_envs.append(env)
            if debug:
                log.debug(env)
        if step_envs:
            return_env = step_envs[-1]
        else:
            return_env = None
        logevent('BLD %s %s' % (self.name, 'build-out'),
                 env.to_json(indent=2) if hasattr(return_env, 'to_json') else return_env,
                 wrap=True)
        return return_env
        # return step_envs



def lookup_from_kwargs_env(kwargs, env, attr, default=None):
    """
    __getitem__ from kwargs, env, or default.

    Args:
        kwargs (dict): kwargs dict
        env (Env): :py:mod:`Env` dict
        attr (str): attribute name
        default (obj): default value to return if not found in kwargs or env
    Returns:
        obj: kwargs.get(attr, env.get(attr, default))
    """
    return kwargs.get(attr, env.get(attr, default))


def build_dotfiles_env(env=None,
                       **kwargs):
    """
    Configure dotfiles base environment (HOME, __WRK, __SRC, __DOTFILES)

    Keyword Arguments:
        env (Env dict): :py:class:`dotfiles.venv.venv_ipyconfig.Env`
        HOME (str): home path (``$HOME``, ``~``)
        __WRK (str): workspace path (``$__WRK``, ``~/-wrk``)
        __SRC (str): path to source repos (``$__WRK/-src``)
        __DOTFILES (str): current dotfiles path (``~/-dotfiles``)

    Returns:
        env (Env dict): :py:class:`dotfiles.venv.venv_ipyconfig.Env`

        Sets:

        * HOME
        * __WRK
        * __SRC
        * __DOTFILES
    """
    if env is None:
        env = Env()

    def lookup(attr, default=None):
        return lookup_from_kwargs_env(kwargs, env, attr, default=default)

    env['HOME'] = lookup('HOME',  default=os.path.expanduser('~'))
    env['__WRK'] = lookup('__WRK', default=get___WRK_default(env))
    env['__SRC'] = lookup('__SRC', default=joinpath(env['__WRK'], '-src'))
    env['__DOTFILES'] = lookup('__DOTFILES',
                               default=joinpath(env['HOME'], '-dotfiles'))
    return env


# DEFAULT_WORKON_HOME_DEFAULT (str): variable holding path to WORKON_HOME
DEFAULT_WORKON_HOME_DEFAULT = "WORKON_HOME__py27"


def build_virtualenvwrapper_env(env=None, **kwargs):
    """
    Set WORKON_HOME to WORKON_HOME or WORKON_HOME_DEFAULT

    Keyword Arguments:
        env (Env dict): :py:class:`dotfiles.venv.venv_ipyconfig.Env`
        __WRK (str): workspace path (``$__WRK``, ``~/-wrk``)
        WORKON_HOME_DEFAULT (str): variable name (default: ``WORKON_HOME__py27``)
        WORKON_HOME__* (str): path to a WORKON_HOME set
    Returns:
        env (Env dict): :py:class:`dotfiles.venv.venv_ipyconfig.Env`

        Sets:

        * WORKON_HOME__py27='${__WRK}/-ve27'
        * WORKON_HOME__py34='${__WRK}/-ve34'
        * WORKON_HOME__*=kwargs.get(WORKON_HOME__*)
        * WORKON_HOME_DEFAULT='WORKON_HOME_py27'
    """
    if env is None:
        env = Env()

    def lookup(attr, default=None):
        return lookup_from_kwargs_env(kwargs, env, attr, default=default)
    env['__WRK'] = lookup('__WRK', default=get___WRK_default(env=env))
    env['PROJECT_HOME'] = lookup('PROJECT_HOME',
                                 default=env['__WRK'])      # cdprojecthome cdph

    #env['PYTHON27_ROOT'] = joinpath(env['__WRK'], '-python27')
    env['WORKON_HOME__py27'] = lookup('WORKON_HOME__py27',
                                      default=joinpath(env['__WRK'], '-ve27'))
    #env['PYTHON34_ROOT'] = joinpath(env['__WRK'], '-python34')
    env['WORKON_HOME__py34'] = lookup('WORKON_HOME__py34',
                                      default=joinpath(env['__WRK'], '-ve34'))

    for key in kwargs:
        if key.startswith("WORKON_HOME__"):
            env[key] = kwargs.get(key)

    env['WORKON_HOME_DEFAULT'] = lookup('WORKON_HOME_DEFAULT',
                                        default=DEFAULT_WORKON_HOME_DEFAULT)

    env['WORKON_HOME'] = lookup('WORKON_HOME',
                                default=env.get(env.get('WORKON_HOME_DEFAULT')))
    # cdworkonhome  cdwh
    return env


def build_conda_env(env=None, **kwargs):
    """
    Configure conda27 (2.7) and conda (3.4)
    with condaenvs in ``-wrk/-ce27`` and ``-wrk/ce34``.

    Other Parameters:
        __WRK (str): workspace root (``$__WRK``, ``~/-wrk``)
        CONDA_ROOT__py27 (str): path to conda27 root environment
        CONDA_ENVS__py27 (str): path to conda27 envs (e.g. WORKON_HOME)
        CONDA_ROOT__py34 (str): path to conda34 root environment
        CONDA_ENVS__py34 (str): path to conda34 envs (e.g. WORKON_HOME)

    Keyword Arguments:
        env (Env dict): :py:class:`dotfiles.venv.venv_ipyconfig.Env`
    Returns:
        env (Env dict): :py:class:`dotfiles.venv.venv_ipyconfig.Env`
    """
    if env is None:
        env = Env()

    def lookup(attr, default=None):
        return lookup_from_kwargs_env(kwargs, env, attr, default=default)
    env['__WRK'] = lookup('__WRK', default=get___WRK_default(env=env))

    # get default env paths
    confs = [
        dict(
            env_prefix="__py",
            env_suffix="27",
            env_root_prefix="-conda",
            env_home_prefix="-ce",
        ),
        dict(
            env_prefix="__py",
            env_suffix="34",
            env_root_prefix="-conda",
            env_home_prefix="-ce",
        ),
        dict(
            env_prefix="__py",
            env_suffix="35",
            env_root_prefix="-conda",
            env_home_prefix="-ce",
        ),
        dict(
            env_prefix="__py",
            env_suffix="36",
            env_root_prefix="-conda",
            env_home_prefix="-ce",
        ),
        dict(
            env_prefix="__py",
            env_suffix="37",
            env_root_prefix="-conda",
            env_home_prefix="-ce",
        ),
    ]

    for conf in confs:
        # CONDA27
        env_name = "{env_prefix}{env_suffix}".format(**conf)
        # -conda27
        env_root = "{env_root_prefix}{env_suffix}".format(**conf)
        # -ce27
        env_home = "{env_home_prefix}{env_suffix}".format(**conf)

        root_key = "CONDA_ROOT{env_name}".format(env_name=env_name)
        home_key = "CONDA_ENVS{env_name}".format(env_name=env_name)
        env[root_key] = (kwargs.get(root_key, env.get(root_key)) or
                         joinpath(env['__WRK'], env_root))
        env[home_key] = (kwargs.get(home_key, env.get(home_key)) or
                         joinpath(env['__WRK'], env_home))

    return env


DEFAULT_CONDA_ROOT_DEFAULT = 'CONDA_ROOT__py27'
DEFAULT_CONDA_ENVS_DEFAULT = 'CONDA_ENVS__py27'


def build_conda_cfg_env(env=None, **kwargs):
    """
    Configure conda for a specific environment
    TODO build_venv_config

    Args:
        env (Env dict): :py:class:`dotfiles.venv.venv_ipyconfig.Env`
    Returns:
        env (Env dict): :py:class:`dotfiles.venv.venv_ipyconfig.Env`
    """
    if env is None:
        env = Env()

    def lookup(attr, default=None):
        return lookup_from_kwargs_env(kwargs, env, attr, default=default)

    env['__WRK'] = lookup('__WRK', default=get___WRK_default(env=env))

    conda_envs = [27, 34, 35, 36, 37]
    for n in conda_envs:
        env['CONDA_ROOT__py%s' % n] = (
            lookup('CONDA_ROOT__py%s % n',
            default=joinpath(env['__WRK'], '-conda%s' % n)))
        env['CONDA_ENVS__py%s' % n] = (
            lookup('CONDA_ENVS__py%s' % n,
            default=joinpath(env['__WRK'], '-ce%s' % n)))
    # env['CONDA_ROOT__py27'] = lookup('CONDA_ROOT__py27',
    #                                  default=joinpath(env['__WRK'], '-conda27'))
    # env['CONDA_ENVS__py27'] = lookup('CONDA_ENVS__py27',
    #                                  default=joinpath(env['__WRK'], '-ce27'))


    #env['CONDA_ROOT_DEFAULT'] = lookup('CONDA_ROOT_DEFAULT',
    #                                   default=DEFAULT_CONDA_ROOT_DEFAULT)
    #env['CONDA_ENVS_DEFAULT'] = lookup('CONDA_ENVS_DEFAULT',
    #                                   default=DEFAULT_CONDA_ENVS_DEFAULT)

    env['CONDA_ROOT'] = lookup('CONDA_ROOT',
                               default=env[DEFAULT_CONDA_ROOT_DEFAULT])
    env['CONDA_ENVS_PATH'] = lookup('CONDA_ENVS_PATH',
                               default=env[DEFAULT_CONDA_ENVS_DEFAULT])
    return env


def build_venv_paths_full_env(env=None,
                              pyver=None,
                              **kwargs):
    """
    Set variables for standard paths in the environment

    Keyword Args:
        env (Env dict): :py:class:`dotfiles.venv.venv_ipyconfig.Env` (default: None (Env()))
        VENVPREFIX (str): venv prefix path (default: None (VIRTUAL_ENV))
        VENVSTR (str): name of a VIRTUAL_ENV in WORKON_HOME or path to a VIRTUAL_ENV (default: None)
        VIRTUAL_ENV (str): path to a VIRTUAL_ENV (default: None)
    Returns:
        env (Env dict): :py:class:`dotfiles.venv.venv_ipyconfig.Env`
    Raises:
        StepConfigException: When not any((
            VIRTUAL_ENV, VENVPREFIX, VENVSTR, VENVSTRAPP))

    References:
        - https://en.wikipedia.org/wiki/Unix_directory_structure
        - https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard
    """
    if env is None:
        env = Env()

    def lookup(attr, default=None):
        return lookup_from_kwargs_env(kwargs, env, attr, default=default)

    if pyver is None:
        pyver = get_pyver(pyver)

    env['VENVPREFIX'] = lookup('VENVPREFIX', default=lookup('VIRTUAL_ENV'))
    env['VENVSTR'] = lookup('VENVSTR')
    env['VENVSTRAPP'] = lookup('VENVSTRAPP')
    env['VIRTUAL_ENV'] = lookup('VIRTUAL_ENV')

    env = Venv.parse_VENVSTR(env=env,
                                pyver=pyver,
                                **kwargs)
    VIRTUAL_ENV = env.get('VIRTUAL_ENV')
    VENVPREFIX = env.get('VENVPREFIX')
    if VENVPREFIX in (None, False):
        if VIRTUAL_ENV is not None:
            VENVPREFIX = VIRTUAL_ENV
            env['VENVPREFIX'] = VIRTUAL_ENV
        else:
            errmsg = (
                {'msg': 'VENVPREFIX or VIRTUAL_ENV must be specified',
                 'env': env.to_json(indent=2),
                 #'envstr': str(env),
                 })
            raise StepConfigException(errmsg)

    env['_BIN']        = joinpath(VENVPREFIX, "bin")            # ./bin
    env['_ETC']        = joinpath(VENVPREFIX, "etc")            # ./etc
    env['_ETCOPT']     = joinpath(VENVPREFIX, "etc", "opt")     # ./etc/opt
    env['_HOME']       = joinpath(VENVPREFIX, "home")           # ./home
    env['_LIB']        = joinpath(VENVPREFIX, "lib")            # ./lib
    env['_PYLIB']      = joinpath(VENVPREFIX, "lib",       # ./lib/pythonN.N
                                 pyver)
    env['_PYSITE']     = joinpath(VENVPREFIX,  # ./lib/pythonN.N/site-packages
                                  "lib",
                                  pyver, 'site-packages')
    env['_MNT']        = joinpath(VENVPREFIX, "mnt")            # ./mnt
    env['_MEDIA']      = joinpath(VENVPREFIX, "media")          # ./media
    env['_OPT']        = joinpath(VENVPREFIX, "opt")            # ./opt
    env['_ROOT']       = joinpath(VENVPREFIX, "root")           # ./root
    env['_SBIN']       = joinpath(VENVPREFIX, "sbin")           # ./sbin
    env['_SRC']        = joinpath(VENVPREFIX, "src")            # ./src
    env['_SRV']        = joinpath(VENVPREFIX, "srv")            # ./srv
    env['_TMP']        = joinpath(VENVPREFIX, "tmp")            # ./tmp
    env['_USR']        = joinpath(VENVPREFIX, "usr")            # ./usr
    env['_USRBIN']     = joinpath(VENVPREFIX, "usr", "bin")      # ./usr/bin
    env['_USRINCLUDE'] = joinpath(VENVPREFIX, "usr", "include")  # ./usr/include
    env['_USRLIB']     = joinpath(VENVPREFIX, "usr", "lib")      # ./usr/lib
    env['_USRLOCAL']   = joinpath(VENVPREFIX, "usr", "local")    # ./usr/local
    env['_USRLOCALBIN']= joinpath(VENVPREFIX, "usr", "local", "bin")    # ./usr/local/bin
    env['_USRSBIN']    = joinpath(VENVPREFIX, "usr", "sbin")     # ./usr/sbin
    env['_USRSHARE']   = joinpath(VENVPREFIX, "usr", "share")    # ./usr/share
    env['_USRSRC']     = joinpath(VENVPREFIX, "usr", "src")      # ./usr/src
    env['_VAR']        = joinpath(VENVPREFIX, "var")            # ./var
    env['_VARCACHE']   = joinpath(VENVPREFIX, "var", "cache")    # ./var/cache
    env['_VARLIB']     = joinpath(VENVPREFIX, "var", "lib")      # ./var/lib
    env['_VARLOCK']    = joinpath(VENVPREFIX, "var", "lock")     # ./var/lock
    env['_LOG']        = joinpath(VENVPREFIX, "var", "log")      # ./var/log
    env['_VARMAIL']    = joinpath(VENVPREFIX, "var", "mail")     # ./var/mail
    env['_VAROPT']     = joinpath(VENVPREFIX, "var", "opt")      # ./var/opt
    env['_VARRUN']     = joinpath(VENVPREFIX, "var", "run")      # ./var/run
    env['_VARSPOOL']   = joinpath(VENVPREFIX, "var", "spool")    # ./var/spool
    env['_VARTMP']     = joinpath(VENVPREFIX, "var", "tmp")      # ./var/tmp
    env['_WWW']        = joinpath(VENVPREFIX, "var", "www")      # ./var/www
    return env


def build_venv_paths_cdalias_env(env=None, **kwargs):
    """
    Build CdAliases for standard paths

    Keyword Args:
        env (Env dict): :py:class:`Env`
    Returns:
        env (Env dict): :py:class:`Env`
        with ``.aliases`` extended.

    .. note:: These do not work in IPython as they run in a subshell.
       See: :py:mod:`dotfiles.venv.venv_ipymagics`.
    """
    if env is None:
        env = Env()
    aliases = env.aliases

    aliases['cdhome']        = CdAlias('HOME',         aliases=['cdh'])
    aliases['cdwrk']         = CdAlias('__WRK')
    aliases['cdddotfiles']   = CdAlias('__DOTFILES',   aliases=['cdd'])

    aliases['cdprojecthome'] = CdAlias('PROJECT_HOME', aliases=['cdp', 'cdph'])
    aliases['cdworkonhome']  = CdAlias('WORKON_HOME',  aliases=['cdwh', 'cdve'])
    aliases['cdcondahome']   = CdAlias('CONDA_ENVS_PATH',   aliases=['cda', 'cdce'])

    aliases['cdvirtualenv']  = CdAlias('VIRTUAL_ENV',  aliases=['cdv'])
    aliases['cdsrc']         = CdAlias('_SRC',         aliases=['cds'])
    aliases['cdwrd']         = CdAlias('_WRD',         aliases=['cdw'])

    aliases['cdbin']         = CdAlias('_BIN',         aliases=['cdb'])
    aliases['cdetc']         = CdAlias('_ETC',         aliases=['cde'])
    aliases['cdlib']         = CdAlias('_LIB',         aliases=['cdl'])
    aliases['cdlog']         = CdAlias('_LOG')
    aliases['cdpylib']       = CdAlias('_PYLIB')
    aliases['cdpysite']      = CdAlias('_PYSITE',    aliases=['cdsitepackages'])
    aliases['cdvar']         = CdAlias('_VAR')
    aliases['cdwww']         = CdAlias('_WWW',         aliases=['cdww'])

    aliases['cdls']   = """set | grep "^cd.*()" | cut -f1 -d" " #%l"""
    aliases['cdhelp'] = """cat ${__DOTFILES}/''scripts/venv_cdaliases.sh | pyline.py -r '^\s*#+\s+.*' 'rgx and l'"""
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
    VIRTUAL_ENV_NAME = env.get('VIRTUAL_ENV_NAME',
                               VIRTUAL_ENV.split(os.path.sep)[0])
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
            _ETC = joinpath(env['VIRTUAL_ENV'], 'etc')
        else:
            _ETC = '/etc'
        env['_ETC'] = _ETC

    _APP = env.get('_APP')
    if _APP is None:
        if VIRTUAL_ENV_NAME:
            _APP = VIRTUAL_ENV_NAME
        else:
            _APP = ''
        env['_APP'] = _APP

    _WRD = env.get('_WRD')
    if _WRD is None:
        if _SRC and _APP:
            _WRD = joinpath(env['_SRC'], env['_APP'])
        else:
            _WRD = ""
        env['_WRD'] = _WRD

    def build_editor_env(env):
        # EDITOR configuration
        env['VIMBIN']       = distutils.spawn.find_executable('vim')
        env['GVIMBIN']      = distutils.spawn.find_executable('gvim')
        env['MVIMBIN']      = distutils.spawn.find_executable('mvim')
        env['GUIVIMBIN']    = env.get('GVIMBIN', env.get('MVIMBIN'))
        # set the current vim servername to _APP
        VIMSERVER = '/'
        if _APP:
            VIMSERVER = _APP
        env['VIMCONF'] = "--servername %s" % (
            shell_quote(VIMSERVER).strip('"'))
        if not env.get('GUIVIMBIN'):
            env['_EDIT_'] = "%s -f" % env.get('VIMBIN')
        else:
            env['_EDIT_'] = '%s %s --remote-tab-silent' % (
                env.get('GUIVIMBIN'),
                env.get('VIMCONF'))
        env['EDITOR_'] = env['_EDIT_']
        aliases = env.aliases
        aliases['editw'] = env['_EDIT_']
        aliases['gvimw'] = env['_EDIT_']
        return env

    def build_ipython_env(env):
        # IPYTHON configuration
        env['_NOTEBOOKS'] = joinpath(env.get('_SRC',
                                            env.get('__WRK',
                                                    env.get('HOME'))),
                                    'notebooks')
        env['_IPYSESKEY'] = joinpath(env.get('_SRC', env.get('HOME')),
                                    '.ipyseskey')
        if sys.version_info.major == 2:
            _new_ipnbkey = "print os.urandom(128).encode(\\\"base64\\\")"
        elif sys.version_info.major == 3:
            _new_ipnbkey = "print(os.urandom(128).encode(\\\"base64\\\"))"
        else:
            raise KeyError(sys.version_info.major)
        aliases = env.aliases
        aliases['ipskey'] = ('(python -c \"'
                            'import os;'
                            ' {_new_ipnbkey}\"'
                            ' > {_IPYSESKEY} )'
                            ' && chmod 0600 {_IPYSESKEY};'
                            ' # %l'
                            ).format(
            _new_ipnbkey=_new_ipnbkey,
            _IPYSESKEY=shell_varquote('_IPYSESKEY'))
        aliases['ipnb'] = ('ipython notebook'
                        ' --secure'
                        ' --Session.keyfile={_IPYSESKEY}'
                        ' --notebook-dir={_NOTEBOOKS}'
                        ' --deep-reload'
                        ' %l').format(
            _IPYSESKEY=shell_varquote('_IPYSESKEY'),
            _NOTEBOOKS=shell_varquote('_NOTEBOOKS'))

        env['_IPQTLOG'] = joinpath(env['VIRTUAL_ENV'], '.ipqt.log')
        aliases['ipqt'] = ('ipython qtconsole'
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
        return env

    def build_grin_env(env):
        aliases = env.aliases
        aliases['grinv'] = 'grin --follow %%l %s' % shell_varquote('VIRTUAL_ENV')
        aliases[
            'grindv'] = 'grind --follow %%l --dirs %s' % shell_varquote('VIRTUAL_ENV')

        aliases['grins'] = 'grin --follow %%l %s' % shell_varquote('_SRC')
        aliases['grinds'] = 'grind --follow %%l --dirs %s' % shell_varquote('_SRC')
        return env

    def build_wrd_aliases_env(env):
        _WRD = env['_WRD']
        aliases = env.aliases
        if os.path.exists(_WRD) or dont_reflect:

            aliases['lsw'] = IpyAlias(
                '(cd {_WRD}; ls $(test -n "{__IS_MAC}" && echo "-G" || echo "--color=auto") %l)'.format(
                    _WRD=shell_varquote('_WRD'),
                    __IS_MAC=shell_varquote('__IS_MAC')),
                name='lsw',
                complfuncstr="""local cur=${2};
                COMPREPLY=($(cd ${_WRD}; compgen -f -- ${cur}));"""
            )

            aliases['findw'] = 'find {_WRD}'.format(
                _WRD=shell_varquote('_WRD'))
            aliases['grepw'] = 'grep %l {_WRD}'.format(
                _WRD=shell_varquote('_WRD'))

            aliases['grinw'] = 'grin --follow %l {_WRD}'.format(
                _WRD=shell_varquote('_WRD'))
            aliases['grindw'] = 'grind --follow %l --dirs {_WRD}'.format(
                _WRD=shell_varquote('_WRD'))

            env['PROJECT_FILES'] = " ".join(
                str(x) for x in PROJECT_FILES)
            aliases['editp'] = "ew ${PROJECT_FILES} %l"

            aliases['makewrd'] = "(cd {_WRD} && make %l)".format(
                    _WRD=shell_varquote('_WRD'))

            aliases['makew']   = aliases['makewrd']
            aliases['makewlog'] = (
                "_logfile=\"${_VARLOG}/make.log\"; "
                "(makew %l 2>&1 | tee $_logfile) && e $_logfile")
        else:
            log.error('app working directory %r not found' % _WRD)
        return env

    def build_python_testing_env(env):
        aliases = env.aliases
        env['_TESTPY_'] = "(cd {_WRD} && python setup.py test)".format(
            _WRD=shell_varquote('_WRD'),
            )
        aliases['testpyw'] = env['_TESTPY_']
        aliases['testpywr'] = 'reset && %s' % env['_TESTPY_']
        aliases['nosew'] = '(cd {_WRD} && nosetests %l)'.format(
            _WRD=shell_varquote('_WRD'))
        return env

    def build_pyramid_env(env, dont_reflect=True):
        _CFG = joinpath(env['_ETC'], 'development.ini')
        if dont_reflect or os.path.exists(_CFG):
            env['_CFG'] = _CFG
            env['_EDITCFG_'] = "{_EDIT_} {_CFG}".format(
                _EDIT_=env['_EDIT_'],
                _CFG=env['_CFG'])
            aliases['editcfg'] = "{_EDITCFG} %l".format(
                _EDITCFG=shell_varquote('_EDITCFG_'))
            # Pyramid pshell & pserve (#TODO: test -f manage.py (django))
            env['_SHELL_'] = "(cd {_WRD} && {_BIN}/pshell {_CFG})".format(
                _BIN=shell_varquote('_BIN'),
                _CFG=shell_varquote('_CFG'),
                _WRD=shell_varquote('_WRD'))
            env['_SERVE_'] = ("(cd {_WRD} && {_BIN}/pserve"
                              " --app-name=main"
                              " --reload"
                              " --monitor-restart {_CFG})").format(
                _BIN=shell_varquote('_BIN'),
                _CFG=shell_varquote('_CFG'),
                _WRD=shell_varquote('_WRD'))
            aliases['servew'] = env['_SERVE_']
            aliases['shellw'] = env['_SHELL_']
        else:
            logging.error('app configuration %r not found' % _CFG)
            env['_CFG'] = ""
        return env

    def build_supervisord_env(env):
        _SVCFG = env.get('_SVCFG', joinpath(env['_ETC'], 'supervisord.conf'))
        if os.path.exists(_SVCFG) or dont_reflect:
            env['_SVCFG'] = _SVCFG
            env['_SVCFG_'] = ' -c %s' % shell_quote(env['_SVCFG'])
        else:
            logging.error('supervisord configuration %r not found' % _SVCFG)
            env['_SVCFG_'] = ''
        aliases = env.aliases
        aliases['ssv'] = 'supervisord -c "${_SVCFG}"'
        aliases['sv'] = 'supervisorctl -c "${_SVCFG}"'
        aliases['svt'] = 'sv tail -f'
        aliases['svd'] = ('supervisorctl -c "${_SVCFG}" restart dev'
                        ' && supervisorctl -c "${_SVCFG}" tail -f dev')
        return env

    funcs = [
        build_editor_env,
        build_ipython_env,
        build_grin_env,
        build_wrd_aliases_env,
        build_python_testing_env,
        build_pyramid_env,
        build_supervisord_env]
    builder = StepBuilder(env)
    for func in funcs:
        builder.add_step(func)
    return builder.build()


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
        env (Env dict): :py:class:`dotfiles.venv.venv_ipyconfig.Env`
        _TERM_ID (str): terminal identifier string
        shell (str): shell name ("bash", "zsh")
        prefix (str): a path prefix (e.g. ``$VIRTUAL_ENV`` or ``$PREFIX``)
        USER (str): system username (``$USER``) for ``HISTTIMEFORMAT``
        HOSTNAME (str): system hostname (``HOSTNAME``) for ``HISTTIMEFORMAT``
        lookup_hostname (bool): if True, ``HOSTNAME`` is None,
            and not env.get('HOSTNAME'), try to read ``HOSTNAME``
            from ``os.environ`` and then ``socket.gethostname()``.
    Returns:
        env (Env dict): :py:class:`dotfiles.venv.venv_ipyconfig.Env`

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
        env['HOME'] = env.get('HOME', os.path.expanduser('~'))
        env['__WRK'] = env.get('__WRK',
                               get___WRK_default(env=env))
        #env['HOSTNAME'] = HOSTNAME
        #env['USER'] = USER

    #HOSTNAME = env.get('HOSTNAME')
    # if HOSTNAME is None:
        # if lookup_hostname:
            #HOSTNAME = os.environ.get('HOSTNAME')
            # if HOSTNAME is None:
                #HOSTNAME = __import__('socket').gethostname()
        #env['HOSTNAME'] = HOSTNAME
    # env['HISTTIMEFORMAT']   = '%F %T%z  {USER}  {HOSTNAME}  '.format(
        # USER=env.get('USER','-'),
        # HOSTNAME=env.get('HOSTNAME','-'))
    #env['HISTSIZE']         = 1000000
    #env['HISTFILESIZE']     = 1000000

    # user default usrlog
    # env['__USRLOG'] = joinpath(env['HOME'], '-usrlog.log')

    # current usrlog
    if prefix is None:
        prefix = env.get('VENVPREFIX', env.get('VIRTUAL_ENV'))
        if prefix in (None, "/"):
            prefix = env.get('HOME', os.path.expanduser('~'))

    env['_USRLOG'] = joinpath(prefix, "-usrlog.log")
    #_term_id = _TERM_ID if _TERM_ID is not None else (
    #    term_id_from_environ and os.environ.get('_TERM_ID'))
    #if _term_id:
    #    env['_TERM_ID'] = _term_id
    # env['_TERM_URI']    = _TERM_ID  # TODO

    # shell HISTFILE
    # if shell == 'bash':
        #env['HISTFILE'] = joinpath(prefix, ".bash_history")
    # elif shell == 'zsh':
        #env['HISTFILE'] = joinpath(prefix, ".zsh_history")
    # else:
        #env['HISTFILE'] = joinpath(prefix, '.history')

    return env


def build_venv_activate_env(env=None,
                            VENVSTR=None,
                            VENVSTRAPP=None,
                            from_environ=False,
                            VENVPREFIX=None,
                            VIRTUAL_ENV=None,
                            VIRTUAL_ENV_NAME=None,
                            _APP=None,
                            _SRC=None,
                            _WRD=None,
                            **kwargs):

    if env is None:
        env = Env()

    keys = [
        'VENVPREFIX',
        'VENVSTR',
        'VENVSTRAPP',
        'VIRTUAL_ENV',
        'VIRTUAL_ENV_NAME',
        '_APP',
        '_SRC',
        '_WRD',
    ]


    def lookup(attr, default=None):
        return lookup_from_kwargs_env(kwargs, env, attr, default=default)


    _SENTINEL = None
    _vars = vars()
    for key in keys:
        value = _vars.get(key, _SENTINEL)
        if value is not _SENTINEL:
            kwargs[key] = value
            env[key] = lookup(key)

    env = Venv.parse_VENVSTR(env=env,
                            from_environ=from_environ,
                                **kwargs)


    env['__WRK'] = lookup('__WRK', default=get___WRK_default(env=env))

    VIRTUAL_ENV = env.get('VIRTUAL_ENV')
    if VIRTUAL_ENV is None:
        return env

    VIRTUAL_ENV_NAME = env.get('VIRTUAL_ENV_NAME')
    if VIRTUAL_ENV_NAME is None:
        pass

    _APP = env.get('_APP')
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

    _WRD = env.get('_WRD')
    if _WRD is None:
        _WRD = joinpath(env['_SRC'], env['_APP'])
        env['_WRD'] = _WRD
    return env


class Env(object):

    """
    OrderedDict of variables for/from ``os.environ``.

    """
    osenviron_keys_classic = (
        # Comment example paths have a trailing slash,
        # test and actual paths should not have a trailing slash
        # from os.path import join as joinpath

        # editors
        'VIMBIN',
        'GVIMBIN',
        'MVIMBIN',
        'GUIVIMBIN',
        'VIMCONF',
        'EDITOR',
        'EDITOR_',
        'PAGER',
        # venv
        '__WRK',            # ~/-wrk/
        '__DOTFILES',
        # virtualenvwrapper
        'PROJECT_HOME',     # ~/-wrk/ #$__WRK
        'WORKON_HOME',      # ~/-wrk/-ve27/
        'WORKON_HOME__py27',      # ~/-wrk/-ve27/
        'WORKON_HOME__py34',      # ~/-wrk/-ve34/
        # venv
        # ~/-wrk/-ve27/dotfiles/ # ${VENVPREFIX:-${VIRTUAL_ENV}}
        'VENVPREFIX',
        'VENVSTR',         # "dotfiles"
        'VENVSTRAPP',      # "dotfiles", "dotfiles/docs"
        '_APP',             # dotfiles/tests
        'VIRTUAL_ENV_NAME',  # "dotfiles"
        # virtualenv
        'VIRTUAL_ENV',      # ~/-wrk/-ve27/dotfiles/  # ${VIRTUAL_ENV_NAME}
        # venv
        '_SRC',  # ~/-wrk/-ve27/dotfiles/src/  # ${VIRTUAL_ENV}/src
        '_ETC',  # ~/-wrk/-ve27/dotfiles/etc/  # ${VIRTUAL_ENV}/etc

        '_BIN',
        '_CFG',
        '_LIB',
        '_LOG',
        '_MNT',
        '_OPT',
        '_PYLIB',
        '_PYSITE',
        '_SRV',
        '_VAR',
        '_WRD',
        '_WRD_SETUPY',
        '_WWW',

        # dotfiles
        '__SRC',
        '__DOCSWWW',
        # usrlog
        '_USRLOG',
        '__USRLOG',
        '_TERM_ID',
        '_TERM_URI',
    )
    osenviron_keys = OrderedDict((
## <env>
        # ("HOME", "/Users/W"),
        ("__WRK", "${HOME}/-wrk"),
        ("__SRC", "${__WRK}/-src"),
        ("__DOTFILES", "${HOME}/-dotfiles"),
        ("__WRK", "${HOME}/-wrk"),
        #("PROJECT_HOME", "${HOME}/-wrk"),
        ("PROJECT_HOME", "${__WRK}"),
        ("CONDA_ROOT", "${__WRK}/-conda27"),
        ("CONDA_ENVS_PATH", "${__WRK}/-ce27"),
        ("WORKON_HOME", "${__WRK}/-ve27"),
        ("VENVSTR", "dotfiles"),
        ("VENVSTRAPP", "dotfiles"), # or None
        ("VIRTUAL_ENV_NAME", "dotfiles"),
        ("VIRTUAL_ENV", "${WORKON_HOME}/${VIRTUAL_ENV_NAME}"),
        ("VENVPREFIX", "${VIRTUAL_ENV}"), # or /
        ("_APP", "dotfiles"),
        ("_ETC", "${VIRTUAL_ENV}/etc"),
        ("_SRC", "${VIRTUAL_ENV}/src"),
        ("_WRD", "${_SRC}/dotfiles"),
        ("_BIN", "${VIRTUAL_ENV}/bin"),
        ("_ETCOPT", "${_ETC}/opt"),
        ("_HOME", "${VIRTUAL_ENV}/home"),
        ("_LIB", "${VIRTUAL_ENV}/lib"),
        ("_PYLIB", "${_LIB}/python2.7"),
        ("_PYSITE", "${_PYLIB}/site-packages"),
        ("_MNT", "${VIRTUAL_ENV}/mnt"),
        ("_MEDIA", "${VIRTUAL_ENV}/media"),
        ("_OPT", "${VIRTUAL_ENV}/opt"),
        ("_ROOT", "${VIRTUAL_ENV}/root"),
        ("_SBIN", "${VIRTUAL_ENV}/sbin"),
        ("_SRV", "${VIRTUAL_ENV}/srv"),
        ("_TMP", "${VIRTUAL_ENV}/tmp"),
        ("_USR", "${VIRTUAL_ENV}/usr"),
        ("_USRBIN", "${VIRTUAL_ENV}/usr/bin"),
        ("_USRINCLUDE", "${VIRTUAL_ENV}/usr/include"),
        ("_USRLIB", "${VIRTUAL_ENV}/usr/lib"),
        ("_USRLOCAL", "${VIRTUAL_ENV}/usr/local"),
        ("_USRLOCALBIN", "${VIRTUAL_ENV}/usr/local/bin"),
        ("_USRSBIN", "${VIRTUAL_ENV}/usr/sbin"),
        ("_USRSHARE", "${VIRTUAL_ENV}/usr/share"),
        ("_USRSRC", "${VIRTUAL_ENV}/usr/src"),
        ("_VAR", "${VIRTUAL_ENV}/var"),
        ("_VARCACHE", "${_VAR}/cache"),
        ("_VARLIB", "${_VAR}/lib"),
        ("_VARLOCK", "${_VAR}/lock"),
        ("_LOG", "${_VAR}/log"),
        ("_VARMAIL", "${_VAR}/mail"),
        ("_VAROPT", "${_VAR}/opt"),
        ("_VARRUN", "${_VAR}/run"),
        ("_VARSPOOL", "${_VAR}/spool"),
        ("_VARTMP", "${_VAR}/tmp"),
        ("_WWW", "${_VAR}/www"),

        ("WORKON_HOME__py27", "${__WRK}/-ve27"),
        ("WORKON_HOME__py34", "${__WRK}/-ve34"),
        ("WORKON_HOME_DEFAULT", "WORKON_HOME__py27"),
        ("CONDA_ROOT__py27", "${__WRK}/-conda27"),
        ("CONDA_ENVS__py27", "${__WRK}/-ce27"),
        ("CONDA_ROOT__py34", "${__WRK}/-conda34"),
        ("CONDA_ENVS__py34", "${__WRK}/-ce34"),
        #("CONDA_ROOT_DEFAULT", "CONDA_ROOT__py27"),
        #("CONDA_ENVS_DEFAULT", "CONDA_ENVS__py27"),
        #("PROJECT_FILES", ""),
        #("VIMBIN", "/usr/bin/vim"),
        #("GVIMBIN", "/usr/local/bin/gvim"),
        #("MVIMBIN", "/usr/local/bin/mvim"),
        #("GUIVIMBIN", "/usr/local/bin/gvim"),
        #("VIMCONF", "--servername dotfiles"),
        #("_EDIT_", "/usr/local/bin/gvim --servername dotfiles --remote-tab-silent"),
        #("EDITOR_", "/usr/local/bin/gvim --servername dotfiles --remote-tab-silent"),
        #("_NOTEBOOKS", "${_SRC}/notebooks"),
        #("_IPYSESKEY", "${_SRC}/.ipyseskey"),
        #("_IPQTLOG", "${VIRTUAL_ENV}/.ipqt.log"),
        #("_WRD_SETUPY", "${_WRD}/setup.py"),
        #("_TEST_", "(cd {_WRD} && python \"${_WRD_SETUPY}\" test)"),
        #("_CFG", "${_ETC}/development.ini"),
        #("_EDITCFG_", "/usr/local/bin/gvim --servername dotfiles --remote-tab-silent ${_ETC}/development.ini"),
        #("_SHELL_", "(cd {_WRD} && \"${_BIN}\"/pshell \"${_CFG}\")"),
        #("_SERVE_", "(cd {_WRD} && \"${_BIN}\"/pserve --app-name=main --reload --monitor-restart \"${_CFG}\")"),
        #("_SVCFG", "${_ETC}/supervisord.conf"),
        #("_SVCFG_", " -c \"${_ETC}/supervisord.conf\""),
        #("__USRLOG", "${HOME}/-usrlog.log"),
        #("_USRLOG", "${VIRTUAL_ENV}/-usrlog.log"),
    ))


    def __init__(self, *args, **kwargs):
        if 'name' in kwargs:
            self._name = kwargs.pop('name', None)
        self.environ = OrderedDict(*args, **kwargs)
        self.aliases = OrderedDict()
        self.logevent('env', "__init__")

    @property
    def name(self):
        return getattr(self, '_name', str(hex(id(self))))

    def logevent(self, *args, **kwargs):
        #kwargs['logger'] = self.log
        args = list(args)
        if args[0].startswith('env'):
            args[0] = 'env {} {}'.format(
                self.name,
                args[0][3:])
        return logevent(*args, **kwargs)

    def __setitem__(self, k, v):
        self.logevent("envexport", "{}={}".format(k, v))
        return self.environ.__setitem__(k, v)

    def __getitem__(self, k, *args, **kwargs):
        try:
            v = self.environ.__getitem__(k, *args, **kwargs)
            self.logevent("env[k]  ", "{}={}".format(k, repr(v)))
            return v
        except Exception as e:
            self.logevent("env[k]  ", "{}={}".format(k, e))
            raise

    def __contains__(self, k):
        return self.environ.__contains__(k)

    def __iter__(self, *args, **kwargs):
        return self.environ.__iter__(*args, **kwargs)

    def iterkeys(self):
        keys = self.osenviron_keys.keys()
        allkeys = OrderedDict.fromkeys(
            itertools.chain(['HOME'],
                             keys,
                            self.environ.keys()))
        return allkeys.keys()

    def iteritems_environ(self):
        for key in self.iterkeys():
            if key in self.environ:
                yield (key, self.environ.get(key))


    def iteritems(self):
        yield ('environ', OrderedDict(self.iteritems_environ()))
        yield ('aliases', self.aliases)

    def get(self, k, default=None):
        return self.environ.get(k, default)

    def copy(self):
        self.logevent('env.copy', level=logging.DEBUG)
        return copy.deepcopy(self)

    def __eq__(self, env):
        if isinstance(env, Env):
            return ((self.environ == env.environ) and (
                self.aliases == env.aliases))
        elif hasattr(env, 'keys'):
            return self.environ == env
        return False

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
        env = cls((k, environ.get(k, '')) for k in cls.osenviron_keys)
        logevent('env.from_environ',
                 env, # OrderedDict(environ).items(), indent=2),
                 wrap=True,
                 splitlines=True,
                 level=logging.DEBUG)
        return env

    def compress_paths(self, path_, keys=None, keyname=None):
        """
        Given an arbitrary string,
        replace absolute paths (starting with '/')
        with the longest matching Env path variables.

        Args:
            path_ (str): a path string
        Returns:
            str: path string containing ``${VARNAME}`` variables
        """

        if keys is not None:
            keylist = keys
        else:
            #keys_longest_to_shortest
            keydict = self.osenviron_keys.copy()
            other_keys = [x for x in self.environ if x not in keydict]
            default_keys = (list(keydict) +
                            [ 'VIRTUAL_ENV', '_SRC', '_ETC', '_WRD'])
            keylist = default_keys[::-1] + other_keys

        if not isinstance(path_, STR_TYPES):
            return path_
        _path = path_
        for varname in keylist:
            value = self.environ.get(varname)
            if isinstance(value, STR_TYPES) and value.startswith('/'):
                _path = _path.replace(value + "/", '${%s}/' % varname)
        for varname in ['VENVSTRAPP', 'VENVSTR']:
            if keyname == varname:
                continue
            value = self.environ.get(varname)
            if isinstance(value, STR_TYPES):
                if value in _path:
                    _path = _path.replace(value, '${%s}' % varname)

        return _path

    def to_string_iter(self, **kwargs):
        yield '## <env>'
        compress_paths = kwargs.get('compress_paths')
        for name, value in self.iteritems_environ():
            if compress_paths:
                value = self.compress_paths(value, keyname=name)
            yield "{name}={value}".format(name=name, value=repr(value))
        yield '## </env>'

    def __str__(self):
        #return u'\n'.join(self.to_string_iter())
        return self.to_json(indent=2)

    def __repr__(self):
        return "<Env: len=%d>" % len(self.environ)
        # XXX
        return repr(self.to_dict())
        #"Env: " + repr(str(self))

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

    def to_dict(self):
        return OrderedDict(self.iteritems())

    def to_json(self, *args, **kwargs):
        _dict = self.to_dict()
        try:
            jsonstr = json.dumps(_dict, *args, cls=VenvJSONEncoder, **kwargs)
            return jsonstr
        except Exception as e:
            print('\n\n\n\n\n')
            print(pprint.pformat(_dict))
            raise


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
                 VENVSTR=None,
                 VENVSTRAPP=None,
                 __WRK=None,
                 __DOTFILES=None,
                 WORKON_HOME=None,
                 VIRTUAL_ENV_NAME=None,
                 VENVPREFIX=None,
                 VIRTUAL_ENV=None,
                 _SRC=None,
                 _APP=None,
                 _WRD=None,
                 env=None,
                 from_environ=False,
                 open_editors=False,
                 open_terminals=False,
                 dont_reflect=True,
                 debug=False,
                 show_diffs=False,
                 **kwargs):
        """
        Initialize a new Venv from a default configuration

        Keyword Arguments:

            env (Env): initial Env

            VENVSTR (str): VIRTUAL_ENV_NAME ('dotfiles') or VIRTUAL_ENV
                ('$WORKON_HOME/dotfiles')

            VENVSTRAPP (str): _APP ('dotfiles', 'dotfiles/etc/bash')

            __WRK (str): None (~/-wrk) OR
                path to a workspace root
                containing one or more ``WORKON_HOME`` directories

                .. code:: bash

                    test $__WRK == echo "${HOME}/-wrk"
                    cdwrk

            __DOTFILES (str): None or path to dotfiles symlink

                .. code:: bash

                    test "${__DOTFILES}" == "~/-dotfiles"
                    cddotfiles ; cdd

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


            VENVPREFIX (str): for when VIRTUAL_ENV is not set {/,~,~/-wrk}
                some paths may not make sense with PREFIX=/.
                #TODO: list sensible defaults
                # the issue here is whether to raise an error when
                VENVSTR or VIRTUAL_ENV are not specified.

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
                raise Exception(
                    "both 'env' and 'from_environ=True' were specified")
        if env is None:
            env = Env()

        keys = [
            'VENVSTR',
            'VENVSTRAPP',
            '__WRK',
            '__DOTFILES',
            'WORKON_HOME',
            'VIRTUAL_ENV',
            'VENVPREFIX',
            '_APP',
            'VIRTUAL_ENV_NAME',
            '_SRC',
            '_WRD']

        kwargs = OrderedDict()

        def lookup(attr, default=None):
            return lookup_from_kwargs_env(kwargs, env, attr, default=default)

        _SENTINEL = None
        _vars = vars()
        for key in keys:
            value = _vars.get(key, _SENTINEL)
            if value is not _SENTINEL:
                kwargs[key] = value
                env[key] = lookup(key)

        VENVSTR = env.get('VENVSTR')
        if VENVSTR:
            env = Venv.parse_VENVSTR(env=env,
                                     from_environ=from_environ,
                                     **kwargs)
        self.env = env
        built_envs = self.build(env=env,
                                from_environ=from_environ,
                                dont_reflect=dont_reflect,
                                debug=debug,
                                show_diffs=show_diffs)
        if not built_envs:
            raise ConfigException(built_envs)

        self.env = built_envs[-1]

        if open_editors:
            self.open_editors()
        if open_terminals:
            self.open_terminals()

    def build(self,
              env=None,
              VENVSTR=None,
              VENVSTRAPP=None,
              VENVPREFIX=None,
              from_environ=False,
              dont_reflect=True,
              debug=False,
              show_diffs=False,
              build_user_aliases=False,
              build_userlog_env=False,
              ):
        """
        Build :py:class:`Venv` :py:class:`Steps` with :py:class:`StepBuilder`

        """
        conf = OrderedDict()

        if VENVSTR is not None:
            conf['VENVSTR'] = VENVSTR
        if VENVSTRAPP is not None:
            conf['VENVSTRAPP'] = VENVSTRAPP
        if VENVPREFIX is not None:
            conf['VENVPREFIX'] = VENVPREFIX

        conf.update({
            'from_environ': from_environ,
            'dont_reflect': dont_reflect,
            'debug': debug,
            'show_diffs': show_diffs,
        })

        builder = StepBuilder(conf=conf)
        builder.add_step(PrintEnvStderrStep)

        builder.add_step(build_dotfiles_env)
        builder.add_step(build_virtualenvwrapper_env)
        builder.add_step(build_venv_activate_env)

        builder.add_step(build_conda_env)
        builder.add_step(build_conda_cfg_env)
        builder.add_step(build_venv_activate_env)
        builder.add_step(build_venv_paths_full_env)
        builder.add_step(build_venv_paths_cdalias_env)

        # if you would like to fork, fork.
        # if you would like to submit a patch or a pull request, please do.

        if build_user_aliases:
            builder.add_step(build_user_aliases_env)
        if build_usrlog_env:
            builder.add_step(build_usrlog_env)

        logevent('Venv.build',
                 dict(env=env, conf=conf),
                 wrap=True,
                 level=logging.DEBUG)
        new_env = builder.build(env=env)
        #logevent('Venv.build', dict(env=env, conf=conf), wrap=True, level=logging.INFO)
        return new_env

    @staticmethod
    def parse_VENVSTR(env=None,
                      VENVSTR=None,
                      VENVSTRAPP=None,
                      VENVPREFIX=None,
                      VIRTUAL_ENV=None,
                      VIRTUAL_ENV_NAME=None,
                      _APP=None,
                      _SRC=None,
                      _WRD=None,
                      __WRK=None,
                      WORKON_HOME=None,
                      from_environ=False,
                      **kwargs):
        """
        Get the path to a virtualenv given a ``VENVSTR``

        Keyword Arguments:
            env (Env):
            VENVSTR (str): a path to a virtualenv containing ``/``
                OR just the name of a virtualenv in ``$WORKON_HOME``
            VENVSTRAPP (str):
            VENVPREFIX (str):
            WORKON_HOME (str):
            from_environ (bool): whether to try and read from
                ``os.environ["VIRTUAL_ENV"]``
        Returns:
            str: a path to a virtualenv (for ``$VIRTUAL_ENV``)
        """

        _vars = vars()
        keys = [
            '__WRK',
            'WORKON_HOME',
            'VENVSTR',
            'VENVSTRAPP',
            'VENVPREFIX',
            'VIRTUAL_ENV',
            'VIRTUAL_ENV_NAME',
            '_APP',
            '_SRC',
            '_WRD',
        ]

        if env is None:
            env = Env()

        if from_environ is True:
            if VENVSTR or VENVSTRAPP or VENVPREFIX:
                raise ConfigException(
                    "from_environ=True cannot be specified with any of "
                    "[VENVSTR, VENVSTRAPP, VENVPREFIX]")
            env = Env.from_environ(os.environ)

        def lookup(attr, default=None):
            return lookup_from_kwargs_env(kwargs, env, attr, default=default)

        SENTINEL = None
        for key in keys:
            value = _vars.get(key, SENTINEL)
            if value is not SENTINEL:
                kwargs[key] = value
                env[key] = lookup(key)

        logevent('parse_VENVSTR_input', {'kwargs': kwargs, 'env': env})

        WORKON_HOME = lookup('WORKON_HOME', default=get_WORKON_HOME_default())
        VENVSTR = lookup('VENVSTR')
        if VENVSTR is not None:
            env['VENVSTR'] = VENVSTR
        VENVSTRAPP = lookup('VENVSTRAPP', default=lookup('_APP'))

        _APP = lookup('_APP',
                      default=lookup('VENVSTRAPP',
                                     default=lookup('VENVSTR')))

        if VENVSTR not in (None, ''):
            if '/' not in VENVSTR:
                VIRTUAL_ENV = joinpath(WORKON_HOME, VENVSTR)
            else:
                VIRTUAL_ENV = os.path.abspath(VENVSTR)

        if VENVSTRAPP is not None:
            VIRTUAL_ENV_NAME = VENVSTRAPP.split(os.path.sep)[0]
            _APP = VENVSTRAPP
        else:
            if VIRTUAL_ENV:
                VIRTUAL_ENV_NAME = os.path.basename(VIRTUAL_ENV)
            else:
                VIRTUAL_ENV_NAME = VENVSTR
            _APP = VIRTUAL_ENV_NAME
            VENVSTRAPP = _APP


        if VIRTUAL_ENV is None:
            VIRTUAL_ENV = lookup('VIRTUAL_ENV')
            if VIRTUAL_ENV is None:
                if WORKON_HOME and VIRTUAL_ENV_NAME:
                    VIRTUAL_ENV = joinpath(WORKON_HOME, VIRTUAL_ENV_NAME)
        if VIRTUAL_ENV:
            env['VIRTUAL_ENV'] = VIRTUAL_ENV

        VENVPREFIX = lookup('VENVPREFIX', default=VIRTUAL_ENV)

        env['WORKON_HOME'] = WORKON_HOME
        env['VENVSTR'] = VENVSTR
        env['VENVSTRAPP'] = VENVSTRAPP
        env['_APP'] = _APP
        env['VIRTUAL_ENV_NAME'] = VIRTUAL_ENV_NAME
        env['VENVPREFIX'] = VENVPREFIX
        env['VIRTUAL_ENV'] = VIRTUAL_ENV

        logevent('parse_VENVSTR_output', {'env': env, 'kwargs': kwargs, })

        #import ipdb
        # ipdb.set_trace()
        return env

    @property
    def aliases(self):
        """
        Returns:
            OrderedDict: self.env.aliases
        """
        return self.env.aliases

    @staticmethod
    def _configure_sys(env=None, from_environ=False, pyver=None):
        """
        Configure ``sys.path`` with the given :py:mod:`Env`,
        or from ``os.environ``.

        Args:
            env (Env): Env to configure sys.path according to
                (default: None)
            from_environ (bool): whether to read Env from ``os.environ``
                (default: False)
            pyver (str): "python2.7" "python3.4" defaults to ``sys.platform``

        .. note:: This method adds
           ``/usr/local/python.ver.ver/dist-packages/IPython/extensions``
            to ``sys.path``

            Why? When working in a virtualenv which does not have
            an additional local copy of IPython installed,
            the lack of an extensions path was causing errors
            in regards to missing extensions.

            If the path does not exist, it will not be added.

        """
        if from_environ:
            env = Env.from_environ(os.environ)
        if pyver is None:
            pyver = get_pyver()

        env['_PYLIB'] = joinpath(env['_LIB'], pyver)
        env['_PYSITE'] = joinpath(env['_PYLIB'], 'site-packages')

        # emulate virtualenv check for no-global-site-packages.txt
        no_global_site_packages = joinpath(
            env('_PYLIB'), 'no-global-site-packages.txt')
        if not os.path.exists(no_global_site_packages):
            sys_libdir = joinpath("/usr/lib", pyver)

            # XXX: **OVERWRITE** sys.path
            sys.path = [joinpath(sys_libdir, p) for p in (
                        "", "plat-linux2", "lib-tk", "lib-dynload")]

            # XXX: append /usr/local/lib/{pyver}/IPython/extensions # TODO?
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

        return env

    def configure_sys(self):
        """
        Returns:
            list: ``sys.path`` list from ``_configure_sys``.
        """
        return Venv._configure_sys(self.env)

    @classmethod
    def workon(cls, env=None, VENVSTR=None, VENVSTRAPP=None, **kwargs):
        """
        Args:
            VENVSTR (str): a path to a virtualenv containing ``/``
                OR just the name of a virtualenv in ``$WORKON_HOME``
            VENVSTRAPP (str): e.g. ``dotfiles`` or ``dotfiles/docs``
            kwargs (dict): kwargs to pass to Venv (see ``Venv.__init__``)
        Returns:
            Venv: an intialized ``Venv``
        """
        return cls(env=env, VENVSTR=VENVSTR, VENVSTRAPP=VENVSTRAPP, **kwargs)

    @staticmethod
    def _configure_ipython(c=None,
                           platform=None,
                           sympyprinting=False,
                           parallelmagic=False,
                           storemagic=True,
                           storemagic_autorestore=False,
                           autoreload=True,
                           deep_reload=False,

                           venvaliases=True,
                           usrlog=True,

                           venv_ipyconfig_debug=False,

                           setup_func=None):
        """

        Configure IPython with ``autoreload=True``, ``deep_reload=True``,
        the **storemagic** extension, the **parallelmagic**
        extension if ``import zmq`` succeeds,
        and ``DEFAULT_ALIASES`` (``cd`` aliases are not currently working).

        Args:
            c (object): An IPython configuration object
                (``get_ipython()``)
            platform (str): platform string
                (``uname``: {'Linux', 'Darwin'})

                .. note:: If ``None``, ``platform`` is necessarily autodetected
                so that ``ps`` and ``ls`` aliases work with syntax coloring and
                Linux and OSX BSD coreutils.

            setup_func (function): a function to call with
                config as the first positional argument,
                **after** default configuration (default: ``None``)

        References:

            * http://ipython.org/ipython-doc/dev/config/
            * http://ipython.org/ipython-doc/dev/config/options/terminal.html

        """
        if c is None:
            if not IN_IPYTHON_CONFIG:
                # skip IPython configuration
                log.error("not in_venv_ipyconfig")
                return
            else:
                c = IPYTHON_CONFIG # get_config()

        if venv_ipyconfig_debug:
            import pdb; pdb.set_trace()

        # c.InteractiveShellApp.ignore_old_config = True
        c.InteractiveShellApp.log_level = 20

        # TODO: c.InteractiveShellApp.extensions.append?
        c.InteractiveShellApp.extensions = [
            # 'autoreload',
        ]
        if sympyprinting:
            try:
                import sympy
                c.InteractiveShellApp.extensions.append('sympyprinting')
            except ImportError as e:
                pass
        if parallelmagic:
            try:
                import zmq
                zmq
                c.InteractiveShellApp.extensions.append('parallelmagic')
            except ImportError:
                pass

        # c.InteractiveShell.autoreload = autoreload
        c.InteractiveShell.deep_reload = deep_reload

        if storemagic:
            # %store [name]
            c.InteractiveShellApp.extensions.append('storemagic')
            c.StoreMagic.autorestore = storemagic_autorestore

        if venvaliases:
            ipython_default_aliases = get_IPYTHON_ALIAS_DEFAULTS(
                platform=platform).items()
            c.AliasManager.default_aliases.extend(ipython_default_aliases)
            ipython_alias_overlay = get_IPYTHON_ALIAS_OVERLAY()
            c.AliasManager.default_aliases.extend(ipython_alias_overlay)

        if usrlog:
            # TODO: if kwargs.get('_USRLOG', kwargs.get('__USRLOG'))
            usrlog_alias_overlay = get_USRLOG_ALIAS_OVERLAY()
            c.AliasManager.default_aliases.extend(usrlog_alias_overlay)

        output = c
        if setup_func:
            output = setup_func(c)

        return output

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
                (k, v) for (k, v) in self.env.aliases.items()
                if not k.startswith('cd')]
        return Venv._configure_ipython(*args, setup_func=setup_func, **kwargs)

    def generate_vars_env(self, **kwargs):
        """
        Generate a string containing VARIABLE='./value'
        """
        for block in self.env.to_string_iter(**kwargs):
            yield block

    def generate_bash_env(self,
                          shell_keyword='export ',
                          shell_quotefunc=shell_quote,
                          include_paths=True,
                          include_aliases=True,
                          include_cdaliases=False,
                          **kwargs):
        """
        Generate a ``source``-able script for the environment variables,
        aliases, and functions defined by the current ``Venv``.

        Keyword Arguments:
            shell_keyword (str): shell variable def (default: "export ")
            include_paths (bool): Include environ vars in output (default: True)
            include_aliases (bool): Include aliases in output (default: True)
            include_cdaliases (bool): Include cdaliases in output (default: False)
            compress_paths (bool): Compress paths to $VAR (default=False)

        Yields:
            str: block of bash script
        """
        compress_paths = kwargs.get('compress_paths')
        if include_paths:
            for k, v in self.env.iteritems_environ():
                # TODO: XXX:
                if v is None:
                    v = ''
                if compress_paths:
                    v = self.env.compress_paths(v, keyname=k)
                # if _shell_supports_declare_g():
                #   shell_keyword="declare -grx "
                #    yield "declare -grx %s=%r" % (k, v)
                # else:
                #     yield "export %s=%r" % (k, v
                #     yield("declare -r %k" % k, file=output)
                yield "{keyword}{VAR}={value}".format(
                    keyword=shell_keyword,
                    VAR=k,
                    value=shell_quotefunc(v))

        if include_cdaliases:
            yield CdAlias.BASH_CDALIAS_HEADER
        if include_aliases:
            for k, v in self.env.aliases.items():
                bash_alias = None
                if hasattr(v, 'to_bash_function'):
                    bash_alias = v.to_bash_function()
                if hasattr(v, 'to_shell_str'):
                    bash_alias = v.to_shell_str()
                else:
                    _alias = IpyAlias(v, k)
                    bash_alias = _alias.to_shell_str()
                if compress_paths:
                    bash_alias = self.env.compress_paths(bash_alias, keyname=k)
                yield bash_alias

    def generate_bash_cdalias(self):
        """
        Generate a ``source``-able script for cdalias functions

        Yields:
            str: block of bash script
        """
        yield CdAlias.BASH_CDALIAS_HEADER
        for k, v in self.env.aliases.items():
            if isinstance(v, CdAlias):
                yield v.to_bash_function()
            elif k in ('cdls', 'cdhelp'):
                yield IpyAlias(v, k).to_shell_str()

    def generate_vim_cdalias(self):
        """
        Generate a ``source``-able vimscript for vim

        Yields:
            str: block of vim script
        """

        yield CdAlias.VIM_HEADER_TEMPLATE
        # for k, v in self.env.items():
        #    yield ("export %s=%r" % (k, v))
        for k, v in self.env.aliases.items():
            if hasattr(v, 'to_vim_function'):
                yield v.to_vim_function()

    def generate_venv_ipymagics(self):
        """
        Generate an ``venv_ipymagics.py`` file for IPython

        Yields:
            str: block of Python code
        """

        yield CdAlias.VENV_IPYMAGICS_FILE_HEADER
        for k, v in self.env.aliases.items():
            if hasattr(v, 'to_ipython_method'):
                for block in v.to_ipython_method():
                    yield block
        yield CdAlias.VENV_IPYMAGICS_FOOTER

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

            '--tab', '--title', '%s: bash' % self.env['_APP'],
            '--command', 'bash',
            '--tab', '--title', '%s: serve' % self.env['_APP'],
            '--command', "bash -c 'we %s %s'; bash" % (
                self.env['VIRTUAL_ENV'], self.env['_APP']),  #
            '--tab', '--title', '%s: shell' % self.env['_APP'],
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
        return self.env.to_dict()
        #OrderedDict(
            #env=self.env,
            ## aliases=self.aliases,
        #)

    def to_json(self, indent=None):
        """
        Args:
            indent (int): number of spaces with which to indent JSON output
        Returns:
            str: json.dumps(self.to_dict())
        """
        return json.dumps(self.to_dict(), indent=indent, cls=VenvJSONEncoder)

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
        VENVPREFIX = self.env.get('VENVPREFIX',
                                  self.env.get('VIRTUAL_ENV', None))
        if VENVPREFIX is None:
            raise ConfigException("VENVPREFIX is None")
        config = {
            'command': command,
            'shell': True,
            #'env': env,
            'VENVPREFIX': VENVPREFIX,
            'cwd': VENVPREFIX}
        logevent('subprocess.call', config, level=logging.INFO)
        config.pop('command')
        config.pop('VENVPREFIX')
        return subprocess.call(command + " #venv.call", **config)


def get_IPYTHON_ALIAS_DEFAULTS(platform=None):
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
        ('lll', 'ls {} -altr'.format(LS_COLOR_AUTO)),
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
    )
    return IPYTHON_ALIAS_OVERLAY


def get_USRLOG_ALIAS_OVERLAY():
    USRLOG_ALIAS_OVERLAY = (
        ('ut', 'tail $$_USRLOG'),
    )
    return USRLOG_ALIAS_OVERLAY



def ipython_main():
    """
    Configure IPython with :py:class:`Venv`
    :py:method:`configure_ipython`
    (:py:method:`_configure_ipython`).
    """
    venv = None
    if 'VIRTUAL_ENV' in os.environ:
        venv = Venv(from_environ=True)
        venv.configure_ipython()
    else:
        Venv._configure_ipython()


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

# Tests


class VenvTestUtils(object):

    """
    Test fixtures for TestCases and examples
    """
    @staticmethod
    def build_env_test_fixture(env=None):
        if env is None:
            env = Env()
        env['__WRK'] = env.get('__WRK',
                               get___WRK_default(env=env))
        env['WORKON_HOME'] = env.get('WORKON_HOME',
                                     get_WORKON_HOME_default(env=env))
        env['VENVSTR'] = env.get('VENVSTR',
                                 'dotfiles')
        env['VENVSTRAPP'] = env.get('VENVSTRAPP',
                                    env['VENVSTR'])
        env['_APP'] = env.get('_APP',
                              env.get('VENVSTRAPP',
                                env['VENVSTR']))  # TODO || basename(VENVPREFIX)
        env['VIRTUAL_ENV_NAME'] = env.get('VIRTUAL_ENV_NAME',
                                          os.path.basename(
                                              env['VENVSTR']))
        env['VIRTUAL_ENV'] = env.get('VIRTUAL_ENV',
                                     joinpath(
                                         env['WORKON_HOME'],
                                         env['VIRTUAL_ENV_NAME']))
        env['VENVPREFIX'] = env.get('VENVPREFIX') or env.get('VIRTUAL_ENV')
        env['_SRC'] = joinpath(env['VENVPREFIX'], 'src')
        env['_ETC'] = joinpath(env['VENVPREFIX'], 'etc')
        env['_WRD'] = joinpath(env['_SRC'], env['_APP'])
        return env

    @staticmethod
    def capture_io(f):
        """
        Add stdout and sterr kwargs to a function call
        and return (output, _stdout, _stderr)
        """
        functools.wraps(f)

        def __capture_io(*args, **kwargs):
            # ... partial/wraps
            _stdout = kwargs.get('stdout', StringIO.StringIO())
            _stderr = kwargs.get(StringIO.StringIO())
            ioconf = {"stdout": _stdout, "stderr": _stderr}
            kwargs.update(ioconf)
            output = f(*args, **kwargs)
            # _stdout.seek(0), _stderr.seek(0)
            return output, _stdout, _stderr
        return __capture_io


if __name__ == '__main__':
    _TestCase = unittest.TestCase
else:
    _TestCase = object


class VenvTestCase(_TestCase):
    """unittest.TestCase or object"""


class Test_001_lookup(VenvTestCase):

    def test_100_lookup(self):
        kwargs = {'True': True, 'envTrue': True,
                  'isNone': None, 'kwargsTrue': True,
                  'collide': 'kwargs'}
        env = {'True': True, 'envTrue': True,
               'isNone': None, 'envNone': True,
               'collide': 'env'}

        def lookup(attr, default=None):
            return lookup_from_kwargs_env(kwargs, env, attr, default=default)
        self.assertTrue(lookup('True'))
        self.assertTrue(lookup('kwargsTrue'))
        self.assertTrue(lookup('envTrue'))
        self.assertEqual(lookup('collide'), 'kwargs')
        self.assertIsNone(lookup('...'))
        self.assertTrue(lookup('...', default=True))


class Test_100_Env(VenvTestCase):

    def test_010_Env(self):
        e = Env()
        self.assertTrue(e)
        assert 'WORKON_HOME' not in e
        e['WORKON_HOME'] = '~/-wrk/-ve27'
        assert 'WORKON_HOME' in e
        assert 'WORKON_HOME' in e.environ

    def test_020_Env_copy(self):
        e = Env()
        keyname = '_test'
        self.assertNotIn(keyname, e)
        e[keyname] = True
        self.assertIn(keyname, e)
        e2 = e.copy()
        self.assertIn(keyname, e2)

        keyname = '_test2'
        e2[keyname] = True
        self.assertIn(keyname, e2)
        self.assertNotIn(keyname, e)

    def test_Env_from_environ(self):
        import os
        e = Env.from_environ(os.environ)
        print(e)
        self.assertTrue(e)


class Test_200_StepBuilder(VenvTestCase):

    def test_000_Step(self):
        def build_func(env, **kwargs):
            return env
        s = Step(build_func)
        self.assertTrue(s)

    def test_500_StepBuilder(self):
        env = Env()
        env['_test'] = True
        builder = StepBuilder()
        step, new_env = builder.build(env=env)
        self.assertTrue(new_env)
        self.assertEqual(env.environ.items(), new_env.environ.items())

        builder = StepBuilder()
        step, new_env = builder.build(env=env)
        self.assertTrue(new_env)
        self.assertEqual(env, new_env)

    def test_600_StepBuilder(self):
        env = Env()
        env['_test'] = True

        builder = StepBuilder()
        builder.add_step(PrintEnvStderrStep)
        step, new_env = builder.build(env=env)
        self.assertTrue(new_env)
        self.assertEqual(env, new_env)


class Test_250_Venv(VenvTestCase):

    def setUp(self):
        self.env = VenvTestUtils.build_env_test_fixture()
        self.envattrs = ['VIRTUAL_ENV', 'VIRTUAL_ENV_NAME', '_APP',
                         'VENVSTR', 'VENVSTRAPP', 'VENVPREFIX']

    def test_000_venv_test_fixture(self):
        self.assertTrue(self.env)
        for attr in self.envattrs:
            self.assertIn(attr, self.env)
            self.assertIn(attr, self.env.environ)
            self.assertEqual(self.env.get(attr), self.env[attr])

    def test_010_assert_venv_requires_VENVPREFIX__or__VIRTUAL_ENV(self):
        with self.assertRaises(Exception):
            venv = Venv()

    def test_100_Venv_parse_VENVSTR_env__and__VENVSTR(self):
        env = Venv.parse_VENVSTR(env=self.env, VENVSTR=self.env['VENVSTR'])
        for attr in self.envattrs:
            self.assertIn(attr, env)
            self.assertEqual(env[attr], self.env.environ[attr])
            self.assertEqual(env[attr], self.env[attr])

    def test_110_Venv_parse_VENVSTR_VENVSTR(self):
        env = Venv.parse_VENVSTR(VENVSTR=self.env['VENVSTR'])
        for attr in self.envattrs:
            self.assertIn(attr, env)
            print(attr)
            try:
                self.assertEqual(env[attr], self.env[attr])
            except:
                print(attr)
                raise

    def test_110_Venv_parse_VENVSTR_VENVSTR(self):
        env = Venv.parse_VENVSTR(VENVSTR=self.env['VENVSTR'])
        for attr in self.envattrs:
            try:
                self.assertEqual(env[attr], self.env[attr])
            except:
                self.assertEqual(attr+'-'+env[attr], attr)
                raise

    def test_120_Venv_parse_VENVSTR_VENVSTR_VENVSTRAPP(self):
        VENVSTRAPP = 'dotfiles/docs'
        self.env = VenvTestUtils.build_env_test_fixture(
            Env(VENVSTRAPP=VENVSTRAPP, _APP=VENVSTRAPP))
        env = Venv.parse_VENVSTR(VENVSTR=self.env['VENVSTR'],
                                  VENVSTRAPP=VENVSTRAPP)
        for attr in self.envattrs:
            self.assertIn(attr, env)
            self.assertEqual(env[attr], self.env[attr])

        self.assertEqual(env['_APP'], VENVSTRAPP)
        self.assertEqual(env['VENVSTRAPP'], VENVSTRAPP)


class Test_300_venv_build_env(VenvTestCase):

    """
    test each build step independently

    .. code:: python

        kwargs = {}
        env = env.copy()
        buildfunc = build_virtualenvwrapper_env
        new_env = buildfunc(env=env, **kwargs)

    """

    def setUp(self):
        self.env = VenvTestUtils.build_env_test_fixture()

    @staticmethod
    def print_(self, *args, **kwargs):
        print(args, kwargs)

    def test_100_build_dotfiles_env(self):
        env = build_dotfiles_env()
        self.print_(env)
        self.assertTrue(env)

    def test_200_build_usrlog_env(self):
        env = build_usrlog_env()
        self.print_(env)
        self.assertTrue(env)

    def test_400_build_virtualenvwrapper_env(self):
        env = build_virtualenvwrapper_env()
        self.print_(env)
        self.assertTrue(env)

    def test_500_build_conda_env(self):
        env = build_conda_env()
        self.print_(env)
        self.assertTrue(env)

    def test_600_build_conda_cfg_env(self):
        env = build_conda_cfg_env()
        #env = build_conda_cfg_env(env=env, conda_root=None, conda_home=None)
        self.print_(env)
        self.assertTrue(env)

    def test_600_build_venv_paths_full_env__prefix_None(self):
        with self.assertRaises(ConfigException):
            env = build_venv_paths_full_env()

    def test_610_build_venv_paths_full_env__prefix_root(self):
        env = build_venv_paths_full_env(VENVPREFIX='/')
        self.print_(env)
        self.assertTrue(env)
        self.assertEqual(env['_BIN'], '/bin')
        self.assertEqual(env['_ETC'], '/etc')
        self.assertEqual(env['_SRC'], '/src')  # TODO
        self.assertEqual(env['_LOG'], '/var/log')
        # self.assertIn('WORKON_HOME', env)

    def test_620_build_venv_paths_full_env__prefix_None(self):
        env = build_venv_activate_env(VENVSTR=self.env["VENVSTR"])
        env = build_venv_paths_full_env(env)
        self.print_(env)
        self.assertTrue(env)
        self.assertIn('VIRTUAL_ENV', env)
        self.assertEqual(env["VIRTUAL_ENV"], self.env["VIRTUAL_ENV"])

    def test_650_build_venv_paths_cdalias_env(self):
        env = build_venv_paths_cdalias_env()
        self.print_(env)
        self.assertTrue(env)


class Test_500_Venv(VenvTestCase):

    def setUp(self):
        self.env = VenvTestUtils.build_env_test_fixture()

    def test_000_venv(self):
        self.assertTrue(self.env)
        for attr in ['VENVSTR', 'VIRTUAL_ENV', 'VIRTUAL_ENV_NAME', '_APP']:
            self.assertIn(attr, self.env)

        with self.assertRaises(Exception):
            venv = Venv()

    def test_005_venv(self):
        venv = Venv(VENVSTR=self.env['VENVSTR'])
        self.assertTrue(venv)
        self.assertTrue(venv.env)
        print(venv.env)
        for attr in ['VIRTUAL_ENV', 'VIRTUAL_ENV_NAME', '_APP']:
            self.assertIn(attr, venv.env)
            self.assertEqual(venv.env[attr], self.env[attr])

    def test_010_venv__APP(self):
        venv = Venv(VENVSTR=self.env['VIRTUAL_ENV'], _APP=self.env['_APP'])
        self.assertIn('_APP', venv.env)
        self.assertEqual(venv.env['_APP'], self.env['_APP'])

    def test_011_venv__APP(self):

        _APP = "dotfiles/docs"
        VENVSTRAPP = "dotfiles/docs"

        _env = Env(_APP=_APP)
        self.assertEqual(_env['_APP'], _APP)

        self.env = VenvTestUtils.build_env_test_fixture(_env)
        self.assertEqual(self.env['_APP'], _APP)

        venv = Venv(VENVSTR=self.env['VIRTUAL_ENV'],
                    _APP=_APP)
        self.assertIn('_APP', venv.env)
        self.assertEqual(venv.env['_APP'], self.env['_APP'])

        self.assertEqual(venv.env['_WRD'],
                         joinpath(self.env['_SRC'], self.env['_APP']))

    def test_020_venv_from_null_environ(self):
        self.failUnlessRaises(Exception, Venv)

    def test_030_venv_without_environ(self):
        os.environ['VIRTUAL_ENV'] = self.env['VIRTUAL_ENV']
        with self.assertRaises(StepConfigException):
            venv = Venv()

    # Errors w/ travis: TODO XXX FIXME
    #def test_040_venv_with_environ(self):
        #os.environ['VIRTUAL_ENV'] = self.env['VIRTUAL_ENV']
        #venv = Venv(from_environ=True)
        #self.assertTrue(venv)
        #self.assertEqual(venv.env['VIRTUAL_ENV'], self.env['VIRTUAL_ENV'])

    def test_050_venv__VENVSTR__WORKON_HOME(self):
        WORKON_HOME = '/WRKON_HOME'
        venv = Venv(self.env['VENVSTR'], WORKON_HOME=WORKON_HOME)
        self.assertTrue(venv)
        self.assertEqual(venv.env['WORKON_HOME'], WORKON_HOME)
        self.assertEqual(venv.env['_WRD'],
                         joinpath(WORKON_HOME,
                                  self.env['VIRTUAL_ENV_NAME'],
                                  'src',
                                  self.env['VENVSTR']))

    # TODO
    # def test_060_venv__VENVSTR__WRK(self):
        #__WRK = '/WRRK'
        #venv = Venv(VENVSTR=self.env['VENVSTR'], __WRK=__WRK)
        # self.assertTrue(venv)
        #self.assertEqual(venv.env['__WRK'], __WRK)
        # self.assertEqual(venv.env['_WRD'],
                         # joinpath(__WRK,
                                  #'-ve27',
                                  # self.env['VIRTUAL_ENV_NAME'],
                                  #'src',
                                  # self.env['VENVSTR']))


class Test_900_Venv_main(VenvTestCase):

    def setUp(self):
        self.env = VenvTestUtils.build_env_test_fixture()
        # wrap main as self.main on setup to always capture IO
        # (output, stdout, stderr)
        self.main = VenvTestUtils.capture_io(main)

    def test_001_main_null(self):
        #with self.assertRaises(SystemExit):
        #    retcode, stdout, stderr = self.main()
        #    self.assertEqual(retcode, 0)
        pass

    # calls SystemExit
    # def test_002_main_help(self):
    #    retcode, stdout, stderr = self.main('-h')
    #    self.assertEqual(retcode, 0)
    #    retcode, stdout, stderr = self.main('--help')
    #    self.assertEqual(retcode, 0)

    def test_100_main(self):
        retcode, stdout, stderr = self.main('dotfiles')
        self.assertEqual(retcode, 0)

        retcode, stdout, stderr = self.main(
            '--VIRTUAL_ENV', self.env['VIRTUAL_ENV'],
            '--APP', self.env['_APP'])
        self.assertEqual(retcode, 0)
        retcode, stdout, stderr = self.main(
            '--ve', 'dotfiles',
            '--app', 'dotfiles')
        self.assertEqual(retcode, 0)

    def test_110_main_VENVSTR(self):
        retcode, stdout, stderr = self.main('dotfiles')
        self.assertEqual(retcode, 0)
        retcode, stdout, stderr = self.main('dotfiles')
        self.assertEqual(retcode, 0)

    def test_120_main_print_bash_VENVSTR(self):
        retcode, stdout, stderr = self.main(
            '--print-vars',
            self.env['VENVSTR'])
        self.assertEqual(retcode, 0)
        retcode, stdout, stderr = self.main(
            '--print-vars',
            '--compress',
            self.env['VENVSTR'])
        self.assertEqual(retcode, 0)

    def test_130_main_print_bash_VENVSTR_VENVSTRAPP(self):
        (retcode, stdout, stderr) = (self.main(
            '--print-vars',
            self.env['VENVSTR'],
            self.env['_APP']))
        self.assertEqual(retcode, 0)

    def test_140_main_VENVSTR_WORKON_HOME(self):
        retcode, stdout, stderr = self.main('--print-vars',
            '--WORKON_HOME', '/WORKON_HOME',
            self.env['VENVSTR'])
        self.assertEqual(retcode, 0)

    def test_200_main_print_bash_VENVSTR__APP(self):
        retcode, stdout, stderr = self.main(
            '--print-bash',
            self.env['VENVSTR'],
            self.env['_APP'])
        self.assertEqual(retcode, 0)

    def test_200_main_print_bash(self):
        retcode, stdout, stderr = self.main('dotfiles', '--print-bash')
        self.assertEqual(retcode, 0)

    def test_210_main_print_bash_aliases(self):
        retcode, stdout, stderr = self.main('dotfiles', '--print-bash-aliases')
        self.assertEqual(retcode, 0)

    def test_220_main_print_bash_cdaliases(self):
        retcode, stdout, stderr = self.main('dotfiles', '--print-bash-cdaliases')
        self.assertEqual(retcode, 0)

    def test_300_main_print_zsh(self):
        retcode, stdout, stderr = self.main('dotfiles', '--print-zsh')
        self.assertEqual(retcode, 0)

    def test_300_main_print_zsh(self):
        retcode, stdout, stderr = self.main('dotfiles', '--print-zsh-cdalias')
        self.assertEqual(retcode, 0)

    def test_400_main_print_vim(self):
        retcode, stdout, stderr = self.main('dotfiles', '--print-vim-cdalias')
        self.assertEqual(retcode, 0)

# optparse.OptionParser


def build_venv_arg_parser():
    """
    Returns:
        optparse.OptionParser: options for the commandline interface
    """
    import argparse

    stdargs = argparse.ArgumentParser(add_help=False)

    prs = argparse.ArgumentParser(
        prog="venv",
        #usage=("%prog [-b|--print-bash] [-t] [-e] [-E<virtualenv>] [appname]"),
        description=(
            "venv is a configuration utility for virtual environments."),
        epilog=(
            "argparse.REMAINDER: "
            "If args must be specified, either (VENVSTR AND VENVSTRAPP) "
            "or (--ve [--app]) "
            "must be specified first: venv --ve dotfiles -xmake."),
        parents=[stdargs],
    )

    stdprs = prs
    stdprs.add_argument('-V', '--version',
                     dest='version',
                     action='store_true',)
    stdprs.add_argument('-v', '--verbose',
                     dest='verbose',
                     action='append_const',
                     const=1)
    stdprs.add_argument('-D', '--diff', '--show-diffs',
                     dest='show_diffs',
                     action='store_true',)
    stdprs.add_argument('-T', '--trace',
                     dest='trace',
                     action='store_true',)
    stdprs.add_argument('-q', '--quiet',
                     dest='quiet',
                     action='store_true',)
    stdprs.add_argument('-t', '--test',
                     dest='run_tests',
                     action='store_true',)
    prs.add_argument('--platform',
                     help='Platform string (default: None)',
                     dest='platform',
                     action='store',
                     default=None,
                     )


    envprs = prs
    envprs.add_argument('-e', '--from-environ',
                     help="Build venv.env.environ from keys in os.environ",
                     dest='from_environ',
                     action='store_true',
                     )
    envprs.add_argument('--__WRK', '--WRK', '--wrk',
                     help="Path to workspace -- ~/-wrk",
                     dest='__WRK',
                     nargs='?',
                     action='store',
                     )
    envprs.add_argument('--__DOTFILES', '--DOTFILES', '--dotfiles',
                     help="Path to ${__DOTFILES} symlink -- ~/-dotfiles",
                     dest='__DOTFILES',
                     nargs='?',
                     action='store',
                     )
    envprs.add_argument('--WORKON_HOME', '--workonhome', '--wh',
                     help=("Path to ${WORKON_HOME} directory "
                           "containing VIRTUAL_ENVs"),
                     dest='WORKON_HOME',
                     nargs='?',
                     action='store',
                     )
    envprs.add_argument('--CONDA_ROOT', '--condaroot', '--cr',
                     help=("Path to ${CONDA_ROOT} directory "
                           "containing VIRTUAL_ENVs"),
                     dest='CONDA_ROOT',
                     nargs='?',
                     action='store',
                     )
    envprs.add_argument('--CONDA_ENVS_PATH', '--condaenvs', '--ce',
                     help=("Path to ${CONDA_ENVS_PATH} directory "
                           "containing VIRTUAL_ENVs"),
                     dest='CONDA_ENVS_PATH',
                     nargs='?',
                     action='store',
                     )
    envprs.add_argument('--VENVSTR', '--venvstr', '--ve',
                     help=("Path to VIRTUAL_ENV -- "
                           "${WORKON_HOME}/${VIRTUAL_ENV_NAME} "
                           "(or a dirname in $WORKON_HOME) "),
                     dest='VENVSTR_',
                     nargs='?',
                     action='store')

    envprs.add_argument('--VENVSTRAPP', '--venvstrapp',
                     help=("Subpath within {VIRTUAL_ETC}/src/"),
                     dest='VENVSTRAPP_',
                     nargs='?',
                     action='store')

    envprs.add_argument('--VIRTUAL_ENV_NAME', '--virtual-env-name', '--vename',
                     help=("dirname in WORKON_HOME -- "
                           "${WORKON_HOME}/${VIRTUAL_ENV_NAME}"),
                     dest='VIRTUAL_ENV_NAME',
                     nargs='?',
                     action='store',
                     )

    envprs.add_argument('--VENVPREFIX', '--venvprefix', '--prefix',
                     help='Prefix for _SRC, _ETC, _WRD if [ -z VIRTUAL_ENV ]',
                     dest='VENVPREFIX',
                     nargs='?',
                     action='store')

    envprs.add_argument('--VIRTUAL_ENV', '--virtual-env',
                     help="Path to a $VIRTUAL_ENV",
                     dest='VIRTUAL_ENV',
                     nargs='?',
                     action='store',
                     )

    envprs.add_argument('--_SRC', '--SRC', '--src',
                     help='Path to source -- ${VIRTUAL_ENV}/src")',
                     dest='_SRC',
                     nargs='?',
                     action='store',
                     )
    envprs.add_argument('--_APP', '--APP',  '--app',  # see also: --VENVSTRAPP
                     help="Path component string -- ${_SRC}/${_APP}",
                     dest='_APP',
                     nargs='?',
                     action='store',
                     )
    envprs.add_argument('--_WRD', '--WRD', '--wrd',
                     help="Path to working directory -- ${_SRC}/${_APP}",
                     dest='_WRD',
                     nargs='?',
                     action='store',
                     )

    prnprs = prs
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
    prs.add_argument('--print-vars', '--vars',
                     help='Print vars',
                     dest='print_vars',
                     # nargs='?',
                     action='store_true',
                     default=None,
                     )
    prs.add_argument('--print-bash', '--bash',
                     help="Print Bash shell configuration",
                     dest='print_bash',
                     action='store_true',
                     default=None,
                     # default='venv.bash.sh',
                     )

    prs.add_argument('--print-bash-all',
                     help="Print Bash shell environ and aliases",
                     dest='print_bash_all',
                     action='store_true',
                     default=None,
                     # default='venv.bash.sh',
                     )
    prs.add_argument('--print-bash-aliases', '--bash-alias',
                     help="Print Bash alias script",
                     dest='print_bash_aliases',
                     action='store_true',
                     )
    prs.add_argument('--print-bash-cdaliases', '--bash-cdalias',
                     help="Print Bash cdalias script",
                     dest='print_bash_cdaliases',
                     action='store_true',
                     )
    prs.add_argument('-Z', '--print-zsh',
                     help="Print ZSH shell configuration",
                     dest='print_zsh',
                     action='store_true',
                     )
    prs.add_argument('--print-vim-cdalias', '--vim',
                     help="Print vimscript configuration ",
                     dest='print_vim_cdalias',
                     action='store_true',
                     )
    prs.add_argument('--print-ipython-magics',
                     help="Print IPython magic methods",
                     dest="print_venv_ipymagics",
                     action='store_true',)

    prs.add_argument('--command', '--cmd', '-x',
                     help="Run a command in a venv-configured shell",
                     dest='run_command',
                     action='store',
                     )
    prs.add_argument('--run-bash', '--xbash', '-xb',
                     help="Run bash in the specified venv",
                     dest='run_bash',
                     action='store_true',
                     )
    prs.add_argument('--run-make', '--xmake', '-xmake',
                     help="Run (cd $_WRD; make $@) in the specified venv",
                     dest='run_make',
                     action='store_true',
                     )

    prs.add_argument('--run-editp', '--open-editors', '--edit', '-E',
                     help=("Open $EDITOR_ with venv.project_files"
                           " [$PROJECT_FILES]"),
                     dest='open_editors',
                     action='store_true',
                     default=False,
                     )
    prs.add_argument('--run-terminal', '--open-terminals', '--terminals', '--terms',
                     help="Open terminals within the venv [gnome-terminal]",
                     dest='open_terminals',
                     action='store_true',
                     default=False,
                     )

    #subparsers = prs.add_subparsers(help='subcommands')
    #pthprs = subparsers.add_parser('path', help='see: $0 path --help')
    pthprs = prs


    pthprs.add_argument('--pall', '--pathall',
                     help="Print possible paths for the given path",
                     dest="all_paths",
                     action='store_true',
                     )
    pthprs.add_argument('--pwrk', '--wrk-path',
                     help="Print $__WRK/$@",
                     dest="path__WRK",
                     action='store_true',
                     )
    pthprs.add_argument('--pworkonhome', '--workonhome-path', '--pwh',
                     help="Print $__WORKON_HOME/$@",
                     dest="path_WORKON_HOME",
                     action='store_true',
                     )
    pthprs.add_argument('--pvirtualenv', '--virtualenv-path', '--pv',
                     help="Print $VIRTUAL_ENV/${@}",
                     dest='path_VIRTUAL_ENV',
                     action='store_true',
                     )
    pthprs.add_argument('--psrc', '--src-path', '--ps',
                     help="Print $_SRC/${@}",
                     dest='path__SRC',
                     action='store_true',
                     )
    pthprs.add_argument('--pwrd', '--wrd-path', '--pw',
                     help="Print $_WRD/${@}",
                     dest='path__WRD',
                     action='store_true',
                     )
    pthprs.add_argument('--pdotfiles', '--dotfiles-path', '--pd',
                     help="Print ${__DOTFILES}/${path}",
                     dest='path__DOTFILES',
                     action='store_true',
                     )

    pthprs.add_argument('--prel', '--relative-path',
                     help="Print ${@}",
                     dest='relative_path',
                     action='store_true',
                     )
    pthprs.add_argument('--pkg-resource-path',
                     help="Path from pkg_resources.TODOTODO",
                     dest="pkg_resource_path",
                     action='store_true',
                     )

    pthprs.add_argument('--compress', '--compress-paths',
                     dest='compress_paths',
                     help='Path $VAR-ify the given paths from stdin',
                     action='store_true')


    prs.add_argument('VENVSTR',
                     help=(
                         'a name of a virtualenv in WORKON_HOME '
                         'OR a full path to a VIRTUAL_ENV'),
                     nargs='?',
                     action='store',
                     )
    prs.add_argument('VENVSTRAPP',
                     help="a path within _SRC (_WRD=_SRC/VENVSTRAPP)",
                     nargs='?',
                     action='store',
                     )

    # Store remaining args in a catchall list (opts.args)
    prs.add_argument('args', metavar='args', nargs=argparse.REMAINDER)

    return prs


def comment_comment(strblock, **kwargs):
    """
    Args:
        strblock (str): string block (possibly containing newlines)
    Keyword Arguments:
        kwargs (dict): kwargs for prepend_comment_char
    Returns:
        str: string with each line prefixed with comment char
    """
    return u'\n'.join(
        prepend_comment_char(pprint.pformat(strblock), **kwargs))


def main(*argv, **kwargs):
    """
    main function called if ``__name__=="__main__"``

    Returns:
        int: nonzero on error
    """
    stderr = kwargs.get('stderr', sys.stderr)
    stdout = kwargs.get('stdout', sys.stdout)

    prs = build_venv_arg_parser()
    if not argv:
        _argv = sys.argv[1:]
    else:
        _argv = list(argv)

    opts = prs.parse_args(args=_argv)
    _, args = prs.parse_known_args(argv)
    # opts.args

    if not  _argv and IN_IPYTHON:
        opts.from_environ = True

    if (not opts.quiet) or (not opts.version):
        logging.basicConfig(
            format="%(levelname)-6s %(message)s",
        )
        log = logging.getLogger(LOGNAME)

        if opts.verbose:
            log.setLevel(logging.DEBUG)
        else:
            log.setLevel(logging.INFO)  # DEFAULT

    if opts.quiet:
        log = logging.getLogger(LOGNAME)
        log.setLevel(logging.ERROR)

    if opts.trace:
        global DEBUG_TRACE_MODPATH
        DEBUG_TRACE_MODPATH = opts.trace

    logevent('main()',
             {"sys.argv": sys.argv,
              "*argv": argv,
              "_argv": _argv,
              "args": args,
              "opts": opts.__dict__},
             level=logging.DEBUG)

    if opts.run_tests:
        sys.argv = [sys.argv[0]] + opts.args
        sys.exit(unittest.main())

    if opts.version:
        # TODO: independently __version__ this standalone script
        # and version-stamp --print-[...]
        try:
            import dotfiles
            version = dotfiles.version
            print(version, file=stdout)
            return 0
        except ImportError:
            return 127

    # build or create a new Env
    if opts.from_environ:
        env = Env.from_environ(os.environ, verbose=opts.verbose)
    else:
        env = Env()

    # read variables from options into the initial env dict

    varnames = ['__WRK', '__DOTFILES', 'WORKON_HOME',
                'VENVSTR', 'VENVSTRAPP', 'VENVPREFIX',
                'VIRTUAL_ENV_NAME', 'VIRTUAL_ENV', '_SRC', '_WRD',
                'CONDA_ROOT', 'CONDA_ENVS_PATH',
                'CONDA_ENVS_DEFAULT', 'CONDA_ROOT_DEFAULT']

    # get opts from args and update env
    for varname in varnames:
        value = getattr(opts, varname, None)
        if value is not None:
            existing_value = env.get(varname)
            if existing_value is not None and existing_value != value:
                logevent('main args', {
                    'msg': 'commandline options intersect with env',
                    'varname': varname,
                    'value': value,
                    'value_was': existing_value,
                }, level=logging.DEBUG)
            env[varname] = value
    if opts.VENVSTR_:
        env['VENVSTR'] = opts.VENVSTR_
    if opts.VENVSTRAPP_:
        env['VENVSTRAPP'] = opts.VENVSTRAPP_

    logevent('main_env', env, wrap=True, level=logging.DEBUG)

    if not any((
            env.get('VENVPREFIX'),
            env.get('VIRTUAL_ENV'),
            env.get('VENVSTR'),
            opts.from_environ)):
        errmsg = ("You must specify one of VENVSTR, VIRTUAL_ENV, VENVPREFIX, "
                  "or -e|--from-environ")
        prs.error(errmsg)

        # TODO: handle paths

    # virtualenv [, appname]
    venv = Venv(env=env,
                open_editors=opts.open_editors,
                open_terminals=opts.open_terminals,
                show_diffs=opts.show_diffs,
                debug=opts.verbose,
                )

    output = stdout

    print_cmd_opts = (opts.print_json,
                opts.print_vars,
                opts.print_bash,
                opts.print_bash_aliases,
                opts.print_bash_cdaliases,
                opts.print_bash_all,
                opts.print_zsh,
                opts.print_vim_cdalias,
                opts.print_venv_ipymagics
                )
    print_cmd = any(print_cmd_opts)
    if opts.print_vars:
        if False: # TODO: any(print_cmd_opts):
            prs.error("--print-vars specfied when\n"
                      "writing to json, bash, zsh, or vim.")
        else:
            for block in venv.generate_vars_env(
                compress_paths=opts.compress_paths):
                print(block, file=output)

    if opts.print_json:
        print(venv.to_json(indent=4), file=output)

    if opts.print_bash_all:
        for block in venv.generate_bash_env(compress_paths=opts.compress_paths,
                                            include_paths=True,
                                            include_aliases=True):
            print(block, file=output)

    if opts.print_bash:
        for block in venv.generate_bash_env(compress_paths=opts.compress_paths,
                                            include_paths=True,
                                            include_aliases=False):
            print(block, file=output)

    if opts.print_bash_aliases:
        for block in venv.generate_bash_env(compress_paths=opts.compress_paths,
                                            include_paths=False,
                                            include_aliases=True,
                                            include_cdaliases=True):
            print(block, file=output)

    if opts.print_bash_cdaliases:
        for block in venv.generate_bash_cdalias():
            print(block, file=output)

    if opts.print_vim_cdalias:
        for block in venv.generate_vim_cdalias():
            print(block, file=output)

    if opts.print_venv_ipymagics:
        for block in venv.generate_venv_ipymagics():
            print(block, file=output)

    if opts.run_command:
        prcs = venv.call(opts.run_command)

    if opts.run_bash:
        prcs = venv.call('cd $_WRD; bash')

    if opts.run_make:
        args = []
        argstr = " ".join(opts.args)
        prcs = venv.call('cd $_WRD; make {}'.format(argstr))

    def get_pkg_resource_filename(filename):
        import pkg_resources
        return pkg_resources.resource_filename('dotfiles', filename)

    if any((opts.all_paths,
            # TODO TODO TODO:
            # is there a way to
            # distinguish between unset and flag-specified-without-value
            # with argparse nargs='?'?
            opts.path__WRD,
            opts.path__DOTFILES,
            opts.relative_path,
            opts.pkg_resource_path)):
        paths = []
        VENVSTR = env.get('VENVSTR')
        if VENVSTR:
            paths.append(VENVSTR)
        VENVSTRAPP = env.get('VENVSTRAPP')
        if VENVSTRAPP:
            paths.append(VENVSTRAPP)
        paths.extend(args)
        basepath = get_pkg_resource_filename('/')

        if opts.all_paths or opts.path__DOTFILES is not None:
            __DOTFILES = env.get('__DOTFILES',
                                 os.path.join('~', '-dotfiles'))
            env['__DOTFILES'] = __DOTFILES

        for pth in paths:
            resource_path = get_pkg_resource_filename(pth)
            if opts.all_paths or opts.relative_path:
                relpath = os.path.relpath(resource_path, basepath)
                print(relpath, file=stdout)
            if opts.all_paths or opts.pkg_resource_path:
                print(resource_path, file=stdout)
            if opts.all_paths or opts.path__DOTFILES is not None:
                dotfiles_path = os.path.join(env['__DOTFILES'], pth)
                print(dotfiles_path, file=stdout)


    if not print_cmd and opts.compress_paths:
        stdin = sys.stdin
        for l in stdin:
            pathstr = l.rstrip()
            #print(pathstr)
            output = venv.env.compress_paths(pathstr)
            print(output, file=stdout)

    return 0


if __name__ == "__main__":
    retcode = main(*sys.argv[1:])
    if not IN_IPYTHON:
        sys.exit(retcode)
else:
    if IN_IPYTHON_CONFIG:
        logevent("ipython_main", "configuring IPython")
        ipython_main()
