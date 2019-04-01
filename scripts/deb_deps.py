#!/usr/bin/env python
# encoding: utf-8
"""
========
aptdeps
========
Walk the local apt cache
"""
from __future__ import print_function
import subprocess
from collections import defaultdict
from collections import deque

import logging
import sys

if sys.version_info.major > 2:
    ifilter = filter
    izip = zip
    imap = map
else:
    from itertools import ifilter, izip, imap

log = logging.getLogger()

class Graph(object):
    """ Simple graph with edge indices
    """
    def __init__(self):
        self.G={}
        self.Eout=defaultdict(list)
        self.Einw=defaultdict(list)
        self._inputorder=[]

    def add_node(self, node):
        key = hasattr(node,'key') and node.key or str(node)
        if key not in self.G:
            self.G[key] = node #
            self._inputorder.append(key)
        else:
            raise Exception()

    def add_edge(self, src, dst):
        if src not in self.G:
            self.add_node(src)
        if dst not in self.G:
            self.add_node(dst)

        self.Eout[src].append(dst)
        self.Einw[dst].append(src)

    def __contains__(self, k):
        return (k in self.G)

    def by_edges_in(self):
        for n, k in sorted( ((len(self.Einw[k]), k) for k in self.Einw),
                reverse=True):
            yield (k, n)

    def by_edges_out(self):
        for n, k in sorted( ((len(self.Eout[k]), k) for k in self.Eout),
                reverse=True):
            yield (k, n)

    def nodes_sorted(self):
        for k in sorted(self.G.iterkeys()):
            yield k


def apt_cache_depends(pkg):
    """scrape the output of ``apt-cache depends <package>``

    :param pkg: pkgname
    :type pkg: str

    :returns: iterable of package names
    :rtype: iterable of strs
    """
    cmd=('apt-cache depends "%s" | egrep "Depends|PreDepends:"' % pkg)
    #log.debug(cmd)
    op = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
    if not op:
        raise Exception(str(op))
    return ( x.split(': ',1)[1].strip() for x in (op.stdout.readlines()) )


def apt_depgraph(start=[], prune=True, show_traversal=False):
    """Walk apt-cache depgraph from ``start`` packages

    :param start: packages to walk from
    :type start: list of strings
    :param prune: whether to prune re-traversal
    :type prune: bool
    :param show_traversal: whether to print depgraph while traversing
    :type show_traversal: bool

    :returns: dependency graph g
    :rtype: aptdeps.Graph

    """
    log.debug("Building depgraph for %r" % start)

    g=Graph()
    q=deque(( (n, []) for n in reversed(start) ))

    _print = lambda x: None
    if show_traversal:
        def _print(x):
            print(x,end='')
    while q:
        pkg, dpath = q.pop()
        dpathd = dict( (k, None) for k in dpath)
        for dpkg in (x.lstrip('<').rstrip('>') for x in
                        sorted(
                            apt_cache_depends(pkg),
                                reverse=True)):
            _print(' > '.join(dpath + [pkg,dpkg]))
            if (prune and (dpkg in g)) or (dpkg in dpathd):
                _print('  >{%d}'% len(g.Einw[dpkg]))
            else:
                q.append((dpkg,dpath+[pkg]))
            _print('\n')

            g.add_edge(pkg, dpkg)

    log.debug("Found %d packages", len(g.Eout))
    _print('\n')
    return g


def graph_stats_report(g):
    """Print graph stats to stdout

    :param g: depgraph graph
    :type g: aptdepts.Graph
    """

    fmtstr="%-4s %-36s %-4s %-36s"
    print(fmtstr % ('####','Dependants','####','Direct Dependencies'))
    for (k1, n1), (k2, n2) in izip(g.by_edges_in(), g.by_edges_out()):
        print(fmtstr % (n1, k1, n2, k2))


def split_and_flatten(iterable):
    """ flatten an iterator of space-delimeted tokens """
    for x in iterable:
        for y in x.split():
            yield y


def read_stdin(stdin):
    return ifilter(lambda x: bool(x) and x[0] != '#', imap(str.strip, stdin))


def main():
    import optparse
    import logging
    import sys

    prs = optparse.OptionParser(
            usage="%prog -d <package>|<-> [-r|report]",
            description="Walk the local apt-cache",
            epilog=" ")

    prs.add_option('-d','--depgraph',
                    dest='depgraph',
                    action='append',
                    help="Packages to walk from")
    prs.add_option('-l','--list-packages',
                    dest='print_package_list',
                    action='store_true',
                    help='List packages')
    prs.add_option('--dont-prune',
                    dest='prune',
                    action='store_false',
                    default=True,
                    help='Don\'t prune the depgraph')

    prs.add_option('-r','--report',
                    dest='graph_stats_report',
                    action='store_true',
                    help='Print pkgs, # deps, and # deps')

    prs.add_option('-v', '--verbose',
                    dest='verbose',
                    action='store_true',)
    prs.add_option('-q', '--quiet',
                    dest='quiet',
                    action='store_true',)
    prs.add_option('-t', '--test',
                    dest='run_tests',
                    action='store_true',)

    (opts, args) = prs.parse_args()

    if not opts.quiet:
        logging.basicConfig()

        if opts.verbose:
            logging.getLogger().setLevel(logging.DEBUG)

    if opts.run_tests:
        sys.argv = [sys.argv[0]] + args
        import unittest
        exit(unittest.main())

    if opts.depgraph:
        pkgs=opts.depgraph
        if pkgs == ['-']:
            pkgs = read_stdin(sys.stdin)

        pkgs = list(split_and_flatten(pkgs))
        g = apt_depgraph(pkgs, opts.prune, opts.verbose)

        if opts.print_package_list:
            for k in g.nodes_sorted():
                print(k)

        if g and opts.graph_stats_report:
            graph_stats_report(g)

if __name__ == "__main__":
    main()
