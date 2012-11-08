#!/usr/bin/python

import re, os, string, sys

pattern_current = r'''\((.*)\)\s?(.*)'''

def rename_dirs(indir,ipattern,opattern,preview=False):
    reg = re.compile(ipattern)
    #for cur_dir in filter(lambda x: os.path.isdir(x), os.listdir(indir)):
    for cur_dir in os.listdir(indir):
        mo = reg.search(cur_dir)
        if mo:
            t = string.Template(opattern)
        new_dir = t.substitute(mo.groupdict())
        print '"%s"///"%s"' % (cur_dir, new_dir),
        print preview
        if not preview:
            os.rename(cur_dir, new_dir)


if __name__=="__main__":
#    try:
    in_dir = sys.argv[1]
    ipattern = sys.argv[2]
    opattern = sys.argv[3]
    try:
        preview = bool(int(sys.argv[4]))
    except:
        preview = True

    rename_dirs(in_dir,ipattern,opattern,preview)
#    except:
    print 'Usage: %s <path> <ipattern> <opattern>' % sys.argv[0]
