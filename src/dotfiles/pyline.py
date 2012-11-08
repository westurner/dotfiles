#!/usr/bin/env python
"""

# updated 2012.07.16, Wes Turner
# updated 2005.07.21, thanks to Jacob Oscarson
# updated 2006.03.30, thanks to Mark Eichin

see: http://code.activestate.com/recipes/437932-pyline-a-grep-like-sed-like-command-line-tool/

usage:

# first 20 chars of every line
tail $FNAME | pyline "line[:20]"

# urls in access log (7th word)
tail $FNAME | pyline "words[6]"

# os
ls | pyline -m os 'os.path.isfile(line) and os.stat(line).st_Size > 1024 and line'

# md5 digest
ls *.py | pyline -m md5 "'%s %s' % (md5.new(file(line).read()).hexdigest(), line)"
"""
import sys
import re
import getopt


# parse options for module imports
opts, args = getopt.getopt(sys.argv[1:], 'x:m:F:d:p')
opts = dict(opts)
if '-m' in opts:
    for imp in opts['-m'].split(','):
        locals()[imp] = __import__(imp.strip())



cmd = ' '.join(args)
if not cmd.strip():
    cmd = 'line'     # no-op


outp_delim = ' '
if '-d' in opts:
    outp_delim = opts['-d']

Path = None
try:
    if '-p' in opts:
        import path as _path
        Path = _path.path
except ImportError:
    raise

#if '-x' in opts:
    #possibleModules = re.findall(r'(\w+)\.', cmd)
    #for m in possibleModules:
        #try:
            #locals()[m] = __import__(m)
        #except ImportError:
            #print >>sys.stdrr, "autoimport %r failed" % m
            #pass

FS = None
if '-F' in opts:
    FS = opts['-F']


codeobj = compile(cmd, 'command', 'eval')
write = sys.stdout.write

for i, line in enumerate(sys.stdin):
    line = line[:-1]
    num = i + 1
    words = (w for w in line.strip().split(FS) if len(w))

    path = Path and _path.path(line)

    # Note: eval
    result =  eval(codeobj, globals(), locals()) # ...
    if result is None or result is False:
        continue
    elif isinstance(result, (list,tuple)):
        result = outp_delim.join(str(s) for s in result)
    else:
        result = str(result)
    write(result)
    if not result.endswith('\n'):
        write('\n')
