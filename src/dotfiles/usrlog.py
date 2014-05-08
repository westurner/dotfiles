
def _ipython_test():
    lines = get_ipython().getoutput(u'cat ~/.usrlog')
    get_ipython().magic(u'pinfo lines.spstr')
    lines
    type(lines)
    from collections import Counter
    Counter
    get_ipython().magic(u'pinfo Counter')
    c = Counter((l[1] for l in l.split(':::',1))
    )
    c = Counter((l.split(':::',1)[1] for l in lines))
    c = Counter((l.split(':::',1)[1] for l in lines if ':::' in l))
    c
    c.iteritems()
    c.items()
    sorted(c.iteritems(), key=lambda x: x[::-1])
    sorted(c.iteritems(), key=lambda x: x[::-1], reverse=True)
    [(x[1],x[0]) for x in sorted(c.iteritems(), key=lambda x: x[::-1], reverse=True)]
    [(x[1],x[0]) for x in sorted(c.iteritems(), key=lambda x: x[::-1], reverse=True) if x[1] > 1]
    [(x[1],x[0]) for x in sorted(c.iteritems(), key=lambda x: x[::-1], reverse=True) if x[1] > 2]
    c = Counter((l.split('::: ',1)[1] for l in lines if ':::' in l))
    [(x[1],x[0]) for x in sorted(c.iteritems(), key=lambda x: x[::-1], reverse=True) if x[1] > 2]
    [l for l in lines if '::: ' not in l]
    get_ipython().magic(u'pwd ')
    get_ipython().magic(u'logstart usrlogpy')
    get_ipython().magic(u'edit ')
    [(x[1],x[0]) for x in sorted(c.iteritems(), key=lambda x: x[::-1], reverse=True) if x[1] > 2]
    [(x[1],x[0].split()) for x in sorted(c.iteritems(), key=lambda x: x[::-1], reverse=True) if x[1] > 2]
    [(x[1],tuple(x[0].split())) for x in sorted(c.iteritems(), key=lambda x: x[::-1], reverse=True) if x[1] > 2]
    [(x[1],tuple(x[0].split()[1])) for x in sorted(c.iteritems(), key=lambda x: x[::-1], reverse=True) if x[1] > 2]
    [(x[1],tuple(x[0].split()[0])) for x in sorted(c.iteritems(), key=lambda x: x[::-1], reverse=True) if x[1] > 2]
    [(x[1],tuple(x[0].split())[0]) for x in sorted(c.iteritems(), key=lambda x: x[::-1], reverse=True) if x[1] > 2]
    [(x[1],tuple(x[0].split())) for x in sorted(c.iteritems(), key=lambda x: x[::-1], reverse=True) if x[1] > 2]
    [(x[1],tuple(x[0].split())) for x in sorted(c.iteritems(), key=lambda x: (x[1],x[0][::-1]), reverse=True) if x[1] > 2]
    [(x[1],tuple(x[0].split())) for x in sorted(c.iteritems(), key=lambda x: (x[1],x[0]), reverse=True) if x[1] > 2]
    sorted((x[1],tuple(x[0].split())) for x in sorted(c.iteritems(), key=lambda x: (x[1],x[0]), reverse=True) if x[1] > 2)
    sorted((tuple(x[0].split()), x[1]) for x in sorted(c.iteritems(), key=lambda x: (x[1],x[0]), reverse=True) if x[1] > 2)
    sorted((tuple(x[0].split()), x[1]) for x in sorted(c.iteritems(), key=lambda x: (x[1],x[0]), reverse=True))
    sorted((x[0], x[1]) for x in sorted(c.iteritems(), key=lambda x: (x[1],x[0]), reverse=True))
