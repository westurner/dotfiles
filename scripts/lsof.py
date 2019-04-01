#!/usr/bin/env python
# encoding: utf-8
"""
What

appstr='$1'
lsof -nf | grep $appstr | grep home | sort -n | pycut -f 8 | sort -u
lsof.sh | grep 'fb' | pycut -f 6,5,0,2,1,7 -O '%s' | sort -n
"""

#import itertools

def lsof():
    import subprocess
    p = subprocess.Popen(('/usr/bin/lsof','-n','-f'), #
             shell=True,
             stdout=subprocess.PIPE)
    print(dir(p.stdout))
    return p.stdout.xreadlines()

def grep(lines, patternstr):
    import re
    pattern = re.compile(patternstr)
    for line in lines:
        matchobj=pattern.match(line)
        if matchobj:
            yield matchobj
        #else:
        #    raise NotImplementedError(str(matchobj), patternstr)
    return

def sort(lines):
    for line in sorted(lines):
        yield line
    return

def splitfields(lines, delim=None, fieldslice=':'):
    for line in lines:
        try:
            yield str.split(line, delim)[fieldslice]
        except:
            raise
    return

def main(lineiter, pattern):
    """
    mainfunc
    """

    lines = sort(
            splitfields(
                grep(
                    (str(s) for s in
                        grep(
                            lsof(),
                            pattern
                        )
                    ),
                    '/home'
                    )
                )
            )
    for line in lines:
        print(line)

    pass


if __name__ == "__main__":
    import optparse
    import logging

    prs = optparse.OptionParser(usage="./")

    prs.add_option('-p', '--pattern',
                    dest='pattern',)

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
        import sys
        sys.argv = [sys.argv[0]] + args
        import unittest
        exit(unittest.main())

    import sys
    main(sys.stdin, opts.pattern)

