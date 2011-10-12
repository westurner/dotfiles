c = get_config()
c.InteractiveShellApp.ignore_old_config=True

import site
import sys
from os import environ
from os.path import join, exists
from sys import version_info
environ['PAGER'] = '/usr/bin/less -r'
if 'VIRTUAL_ENV' in environ:
    pyver = 'python%d.%d' % version_info[:2]
    virtualenv = environ['VIRTUAL_ENV']
    libdir = join(virtualenv, 'lib', pyver)
    site_packages = join(libdir, 'site-packages')
    if exists(join(libdir,'no-global-site-packages.txt')):
        sys_libdir = join("/usr/lib", pyver)
        sys.path = [join(sys_libdir, p) for p in (
                    "", "plat-linux2", "lib-tk", "lib-dynload")]
        sys.path.extend( (p for p in sys.path if p.startswith(environ['VIRTUAL_ENV']) ) )
        sys.path.append('/usr/local/lib/python2.6/dist-packages/IPython/extensions')
    #sys.path.sort()
    site.addsitedir(site_packages)
    print >> sys.stderr , "Path:\n-----"
    print >> sys.stderr , '\n'.join(sys.path)
    print >> sys.stderr , '-----'
del site, sys, environ, join, exists, version_info
