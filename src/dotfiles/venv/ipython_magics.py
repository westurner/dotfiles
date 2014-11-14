#!/usr/bin/env ipython
# dotfiles.venv.ipython_magic
"""
IPython ``%magic`` commands

* ``cd`` aliases
* ``ds`` (``dotfiles_status``)
* ``dr`` (``dotfiles_reload``)

Installation
--------------
.. code-block:: bash

    __DOTFILES="~/.dotfiles"
    ipython_profile="profile_default"
    ln -s ${__DOTFILES}/etc/ipython/ipython_magics.py \\
        ~/.ipython/${ipython_profile}/startup/ipython_magics.py
"""
import os
from IPython.core.magic import (Magics, magics_class, line_magic)

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

    @line_magic
    def cdb(self, line):
        """cdb()    -- cd ${_BIN}/${@}"""
        return self.cd('_BIN', line)

    @line_magic
    def cde(self, line):
        """cde()    -- cd ${_ETC}/${@}"""
        return self.cd('_ETC', line)

    @line_magic
    def cdh(self, line):
        """cdh()    -- cd ${HOME}/${@}"""
        return self.cd('HOME', line)

    @line_magic
    def cdl(self, line):
        """cdl()    -- cd ${_LIB}/${@}"""
        return self.cd('_LIB', line)

    @line_magic
    def cdlog(self, line):
        """cdlog()  -- cd ${_LOG}/${@}"""
        return self.cd('_LOG', line)

    @line_magic
    def cdp(self, line):
        """cdp()    -- cd ${PROJECT_HOME}/${@}"""
        return self.cd('PROJECT_HOME', line)

    @line_magic
    def cdph(self, line):
        """cdph()   -- cd ${PROJECT_HOME}/${@}"""
        return self.cd('PROJECT_HOME', line)

    @line_magic
    def cdpylib(self, line):
        """cdpylib()    -- cd ${PYLIB)/${@}"""
        return self.cd('_PYLIB', line)

    @line_magic
    def cdpysite(self, line):
        """cdpysite()   -- cd ${PYSITE}/${@}"""
        return self.cd('_PYSITE', line)

    @line_magic
    def cdsitepackages(self, line):
        """cdsitepackages() -- cd ${_PYSITE}/${@}"""
        return self.cd('_PYSITE', line)

    @line_magic
    def cds(self, line):
        """cds()            -- cd ${_SRC}/${@}"""
        return self.cd('_SRC', line)

    @line_magic
    def cdv(self, line):
        """cdv()            -- cd ${VIRTUAL_ENV}/${@}"""
        return self.cd('VIRTUAL_ENV', line)

    @line_magic
    def cdve(self, line):
        """cdve()           -- cd ${VIRTUAL_ENV}/${@}"""
        return self.cd('VIRTUAL_ENV', line)

    @line_magic
    def cdvirtualenv(self, line):
        """cdvirtualenv()   -- cd ${VIRTUAL_ENV}/${@}"""
        return self.cd('VIRTUAL_ENV', line)

    @line_magic
    def cdvar(self, line):
        """cdvar()          -- cd ${_VAR}/${@}"""
        return self.cd('_VAR', line)

    @line_magic
    def cdw(self, line):
        """cdw()            -- cd ${_WRD}/${@}"""
        return self.cd('_WRD', line)

    @line_magic
    def cdwrd(self, line):
        """cdwrd()          -- cd ${_WRD}/${@}"""
        return self.cd('_WRD', line)

    @line_magic
    def cdwrk(self, line):
        """cdwrk()          -- cd ${WORKON_HOME}/${@}"""
        return self.cd('WORKON_HOME', line)

    @line_magic
    def cdwh(self, line):
        """cdwh()           -- cd ${WORKON_HOME}/${@}"""
        return self.cd('WORKON_HOME', line)

    @line_magic
    def cdww(self, line):
        """cdww()           -- cd ${_WWW}/${@}"""
        return self.cd('_WWW', line)

    @line_magic
    def cdwww(self, line):
        """cdwww()          -- cd ${_WWW}/${@}"""
        return self.cd('_WWW', line)

    @line_magic
    def cdhelp(self, line):
        """cdhelp()         -- list cd commands"""
        print("\n".join(x for x in dir(self) if x.startswith('cd')))

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


if __name__=="__main__":
    main()
