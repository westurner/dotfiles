

import os
import subprocess
import sys
import unittest

here = os.path.dirname(__file__)
setup_py_cwd = os.path.abspath(os.path.join('here', '..'))


class TestDotfilesSetupPy(unittest.TestCase):
    def test_setuppy(self):
        commands = [
            ("setup.py", 1),
            ("setup.py --help", 0),
            ("setup.py --help-commands", 0),
            ("setup.py test", 0),
            ("setup.py git_manifest", 0),
            ("setup.py hg_manifest", 0),
            ("setup.py build", 0),
            ("setup.py build sdist", 0),
            ("setup.py build bdist", 0),
            ("setup.py build bdist_egg", 0),
            # ("setup.py build bdist_wheel", 0),
            # ("setup.py --command-packages=stdeb.command
            #   build sdist_dsc", 0),
            # ("setup.py --command-packages=stdeb.command
            #   build bdist_deb", 0),
            # ("setup.py --command-packages=stdeb.command
            #   install_deb", 0)
            # ("setup.py install", 0),
            # ("setup.py install_data", 0),
            # ("setup.py install_data -d ./test_dir_todelete", 0)
        ]
        for _cmd, expected_output in commands:
            _cmd = u" ".join((sys.executable, _cmd))
            try:
                print(_cmd)
                output = subprocess.call(_cmd, shell=True, cwd=setup_py_cwd)
                self.assertEqual(output, expected_output)
            except:
                print(_cmd)
                raise
