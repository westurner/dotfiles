#!/usr/bin/python
from __future__ import print_function

from itertools import imap
from itertools import tee
from subprocess import PIPE
from subprocess import Popen
import sys

def apt_show(package):
    cmd = "apt-cache show %s" % package
    return Popen(
        cmd,
        stdout=PIPE,
        shell=True).stdout.read()


def apt_search(query):
    cmd = "apt-cache search %s" % query
    process = Popen(
        cmd,
        stdout=PIPE,
        shell=True
    )
    return iter(process.stdout)


def searchfor(query):
    for line in apt_search(query):
        pkg = line.split(' ',1)[0]
        yield (pkg, apt_show(pkg))


def main():
    _output = sys.stdout
    query = ' '.join(sys.argv[1:])
    names, descs = tee(searchfor(query))
    print(u"## Packages for query: %r" % query)
    for pkg, desc in names:
        print(u"# %s" % pkg, file=_output)
    for pkg, desc in descs:
        print(desc, file=_output)


if __name__=="__main__":
    main()

