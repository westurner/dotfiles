#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function
"""
git_changelog
===============


.. warning::

    This output is not escaped for/as ReStructuredText (RST in commits is parsed)

.. warning::

    The sort order for tags is whatever comes from ``git tag -l``.

    - [ ] TODO: version sorting: semver 2.0, semver 3.0 (PEP440),
      ``sort``, ``sort -n``

.. code:: bash

    git tag -l
    # [v0.1.0, v0.1.1, v0.2.0, --develop]
    echo ""
    echo "v0.1.0"
    echo "======"
    git log --reverse v0.1.0..v0.1.1
    git log --reverse v0.1.1..v0.1.2
    git log --reverse v0.1.2..v0.2.0
    git log --reverse v0.2.0..develop

"""


import collections
import distutils.spawn
import itertools
import logging
import re
import subprocess

# !pip install semantic_version
# | PyPI: https://pypi.python.org/pypi/semantic_version
# | Src : https://github.com/rbarrois/python-semanticversion
import semantic_version

TAGRGX_VER_NUM =    r'v\d+.*'
TAGRGX_VERSION_OPTION_NUM = r'v?\d+.*'
TAGRGX_VER =    r'v.*'
TAGRGX_DEFAULT = TAGRGX_VERSION_OPTION_NUM

BOLCHARSTOESCAPE = ['*', '.. ', '>>> ']
CHARSTOESCAPE = [
    #('\\', u'⧹'),  #TODO double-escaping
    ('`', '\`'),
    ('|', '\|'),
    ('[', '\['),
    (']', '\]'),
]

def rst_escape(_str):
    """XXX TODO

    References:
    - http://docutils.sourceforge.net/docs/user/rst/quickref.html#escaping
    - http://docutils.sourceforge.net/docs/ref/rst/restructuredtext.html#escaping-mechanism

    .. warning:: There are not yet any test cases for this function.
    """
    lines = _str.splitlines()
    output_lines = []
    for line in lines:
        # *      -> \*
        # '.. '  -> '\.. '
        # '>>> ' -> '\>>> '
        for c in BOLCHARSTOESCAPE:
            r = '\\' + c
            matchcount = line.count(c)
            if matchcount == 0:
                line = line
            elif matchcount == 1:
                if not line.lstrip().startswith(c):
                    line = line.replace(c, r)
            else:
                if line.lstrip().startswith(c):
                    beginning, rest = line.split(c, 1)
                    line = beginning + c + rest.replace(c, r)
                else:
                    line = line.replace(c, r)
        # characters to escape
        for char, repl in CHARSTOESCAPE:
            line = line.replace(char, repl)
        if line.startswith('__ ') and line.endswith('_'):
            # indirect hyperlink target
            line = u'\%s' % line
        # TODO: header lines
        # TODO: footnotes, citations
        output_lines.append(line)
    return u'\n'.join(output_lines)


def git_changelog(
    path=None,
    tags=None,
    append_tags=None,
    git_bin=None,
    heading_char='^'):
    """generate a git changelog from git tags

    Arguments:
         (str): ...

    Keyword Arguments:
        path (str): path to git repository ([path][./.git])
        tags (list[str]): optional list of repo tags (default: None (all))
        append_tags (list[str]): list of tags to append to tags

    Yields:
        str: changelog output

    Raises:
        subprocess.CalledProcessError: when/if git commands do not succeed
    """

    git_bin = (
        distutils.spawn.find_executable('git') if git_bin is None else git_bin)
    git_cmd = [git_bin]
    if path:
        git_cmd.extend(['-R', path])

    def git_list_tags(tags=None,
                      tagrgx=TAGRGX_DEFAULT,
                      append_tags=None,
                      git_cmd=git_cmd):
        """List git tag pairs which match a regex

        Keyword Arguments:
            tags (list): empty list of addition tags
            tagrgx (``rawstr``): default: ``'v?\d+.*'``
            append_tags (list or None): additional tags to append
            git_cmd (list): list of command strings

        Yields:
            str: tag name

        """
        git_list_tags_cmd = git_cmd[:] + ['tag', '-l']

        if tags is None:

            if True:
                git_get_first_rev_cmd = [
                    'rev-list', '--all', '--reverse', '--abbrev-commit']  #|head -n 1
                cmd = git_cmd + git_get_first_rev_cmd
                first_rev_output = subprocess.check_output(cmd).splitlines()
                if not first_rev_output:
                    raise Exception(('no first revision found:',
                                    ('cmd', cmd),
                                    ('output', first_rev_output)))
                else:
                    yield first_rev_output[0].rstrip()

            tag_output = subprocess.check_output(git_list_tags_cmd).splitlines()
            logging.debug(('tag_output', tag_output))

            # import semantic_version
            versiontags = []
            for x in tag_output:
                if re.match(tagrgx, x):
                    if x.startswith('v'):
                        _x = x[1:]
                    elif x.startswith('release/'):
                        _x = x[7:]
                    else:
                        _x = x
                    ver = semantic_version.Version(_x.rstrip())
                    versiontags.append((ver, x))
            for version, _tag in sorted(versiontags):
                yield _tag
        if append_tags:
            for _tag in append_tags:
                yield _tag

    tagsiter = git_list_tags(tags=tags,
                             append_tags=append_tags,
                             git_cmd=git_cmd)
    tags = list(tagsiter)
    logging.debug(('tags', tags))

    def git_get_rev_date(revstr, git_cmd=git_cmd):
        git_get_rev_date_cmd = ['log', '-n1', revstr, '--format=%ci']
        cmd = git_cmd + git_get_rev_date_cmd
        return subprocess.check_output(cmd).strip()

    def iter_tag_pairs(tags, heading_char='^'):
        """Iterate over 2-tuple tag pairs e.g. ``[(tag1, tag2), ]``

        Args:
            tags (list
        """
        tagdates = collections.OrderedDict()
        tagpairsiter = itertools.izip(tags,
                                      itertools.islice(tags, 1, None))
        tagpairs = list(tagpairsiter)
        logging.debug(('tagpairs', tagpairs))
        for (tag1, tag2) in tagpairs[::-1]:
            #tag1date = tagdates.setdefault(tag1, git_get_rev_date(tag1))
            tag2date = tagdates.setdefault(tag2, git_get_rev_date(tag2))
            # RST heading
            yield ''
            yield ''
            heading = rst_escape("%s (%s)" % (tag2, tag2date)) # TODO: date
            yield heading
            yield heading_char * len(heading)
            logpath = "%s..%s" % (tag1, tag2)
            changelog_cmd = ['log', '--reverse', '--pretty=format:* %s [%h]', logpath]
            changelog_cmdstr = "log --reverse --pretty=format:'* %s [%h]' " + logpath
            yield "::"
            yield ""
            yield "   git %s" % (changelog_cmdstr)
            yield ""
            cmd = git_cmd + changelog_cmd
            logging.debug(cmd)
            logging.debug(('cmdstr*', ' '.join(cmd)))
            output = subprocess.check_output(cmd)
            yield rst_escape(output)
            #
            tag1 = tag2

    for rstline in iter_tag_pairs(tags, heading_char=heading_char):
        yield rstline


import types
import unittest


class Test_git_changelog(unittest.TestCase):

    def setUp(self):
        pass

    def test_git_changelog(self):
        output = git_changelog()
        self.assertTrue(output)
        self.assertEqual(type(output), types.GeneratorType)
        self.assertTrue(hasattr(output, 'next'))
        for x in output:
            print(x)
        print(output)
        #raise NotImplementedError

    def tearDown(self):
        pass


def main(argv=None):
    """
    Main function

    Keyword Arguments:
        argv (list): commandline arguments (e.g. sys.argv[1:])
    Returns:
        int:
    """
    import logging
    import optparse
    import sys

    prs = optparse.OptionParser(usage="%prog : args")

    prs.add_option('--develop',
                   dest='append_tag_develop',
                   action='store_true')

    prs.add_option('-r', '--rev', '--revision',
                   dest='append_revision',
                   action='append')

    prs.add_option('--hdr', '--heading-character',
                   dest='heading_char',
                   action='store',
                   default='^')

    prs.add_option('-v', '--verbose',
                   dest='verbose',
                   action='store_true',)
    prs.add_option('-q', '--quiet',
                   dest='quiet',
                   action='store_true',)
    prs.add_option('-t', '--test',
                   dest='run_tests',
                   action='store_true',)

    (opts, args) = prs.parse_args(args=argv)
    loglevel = logging.INFO
    if opts.verbose:
        loglevel = logging.DEBUG
    elif opts.quiet:
        loglevel = logging.ERROR
    logging.basicConfig(level=loglevel)
    log = logging.getLogger()
    log.debug('opts: %r', opts)
    log.debug('args: %r', args)
    argv = list(argv) if argv else []
    log.debug('argv: %r', argv)

    if opts.run_tests:
        import sys
        sys.argv = [sys.argv[0]] + args
        import unittest
        return unittest.main()

    EX_OK = 0
    conf = {}
    append_tags = []
    if opts.append_tag_develop:
        append_tags.append('develop')
    if opts.append_revision:
        append_tags.extend(opts.append_revision)
    conf['append_tags'] = append_tags
    conf['heading_char'] = opts.heading_char
    logging.debug(('conf', conf))
    output = git_changelog(**conf)
    for x in output:
        print(x, file=sys.stdout)
    return EX_OK


if __name__ == "__main__":
    import sys
    sys.exit(main(argv=sys.argv[1:]))
