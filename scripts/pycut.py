#!/usr/bin/env python

def fields_from_list(line, columns=None, default=""):
    for n in columns or xrange(len(line)):
        try:
            yield line[n].rstrip()
        except IndexError:
            yield default

def split_lines(lines, fields=None, delim=None):
    for line in lines:
        yield tuple(fields_from_list(line.split(delim), fields))

def get_list_from_str(str_, cast_callable=int):
    return [cast_callable(x.strip()) for x in str_.split(',')]


def main():
    import sys
    from optparse import OptionParser
    argp = OptionParser(version="0.2",
            description="Python port of cut with sort by field")
    argp.add_option("-f","--fields", dest="column_ordinals",
            help="Field Number")
    argp.add_option("-d","--delimeter", dest="idelim",
            help="Field Delimiter",
            default=None)
    argp.add_option("-o","--output-delim", dest="odelim",
            help="Output Delimiter",
            default='||')
    argp.add_option('-O', "--output-formatstr", dest="output_formatstr",
            help="Output Formatter")
    argp.add_option("--nh","--no-header", dest="sheader",
            action="store_true",
            help="Drop First Line")
    argp.add_option("-s","--sort-asc", dest="sort_a",
            help="Sort Ascending by field number")
    argp.add_option("-r","--sort-reverse", dest="sort_reverse",
            action='store_true',
            default=False,
            help="Reverse the sort order")

    (options,args) = argp.parse_args()

    ilines = sys.stdin.readlines()

    if (options.sheader):
        ilines.pop(0)

    if (options.column_ordinals):
        nl = []
        column_ordinals = get_list_from_str(options.column_ordinals)
        nl = split_lines(ilines, column_ordinals, options.idelim)
    else:
        nl = split_lines(ilines, delim=options.idelim)

    if (options.sort_a):
        columns = get_list_from_str(options.sort_a)

        #column_indexes = fields.index(int(options.sort_a))
        nl = sorted(nl,
                key=lambda row: list(fields_from_list(row,columns)),
                reverse=options.sort_reverse)

    if options.output_formatstr:
        fmtstr = options.output_formatstr
        for line in nl:
            print(fmtstr % list(line))

    else:
        for line in nl:
            print(options.odelim.join(line).rstrip())


if __name__=="__main__":
    main()
