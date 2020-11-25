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
import sys

IS_PYTHON2 = sys.version_info.major == 2

if IS_PYTHON2:
    from itertools import izip
else:
    izip = zip

# !pip install semantic_version
# | PyPI: https://pypi.python.org/pypi/semantic_version
# | Src : https://github.com/rbarrois/python-semanticversion
import semantic_version

TAGRGX_VER_NUM = r"v\d+.*"
TAGRGX_VERSION_OPTION_NUM = r"v?\d+.*"
TAGRGX_VER = r"v.*"
TAGRGX_DEFAULT = TAGRGX_VERSION_OPTION_NUM

BOLCHARSTOESCAPE = ["*", ".. ", ">>> "]
CHARSTOESCAPE = [
    # ('\\', u'⧹'),  #TODO double-escaping
    ("`", r"\`"),
    ("|", r"\|"),
    ("[", r"\["),
    ("]", r"\]"),
]

log = logging.getLogger()


def rst_escape(_str, encoding="utf-8"):
    """XXX TODO

    References:
    - http://docutils.sourceforge.net/docs/user/rst/quickref.html#escaping
    - http://docutils.sourceforge.net/docs/ref/rst/restructuredtext.html#escaping-mechanism

    .. warning:: There are not yet any test cases for this function.
    """
    lines = _str.splitlines()
    output_lines = []
    for line in lines:
        line = line.decode(encoding) if hasattr(line, "decode") else line
        # *      -> \*
        # '.. '  -> '\.. '
        # '>>> ' -> '\>>> '
        for c in BOLCHARSTOESCAPE:
            r = "\\" + c
            try:
                matchcount = line.count(c)
            except Exception:
                raise
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
        if line.startswith("__ ") and line.endswith("_"):
            # indirect hyperlink target
            line = "\\%s" % line
        # TODO: header lines
        # TODO: footnotes, citations
        output_lines.append(line)
    return "\n".join(output_lines)

    # TODO: "EXAMPLE: this test_\*that"


def git_list_tags(
    *,
    git_cmd,
    tags=None,
    tagrgx=TAGRGX_DEFAULT,
    append_tags=None,
    all_tags=None
):
    r"""List git tag pairs which match a regex

    Keyword Arguments:
        tags (list): empty list of addition tags
        tagrgx (``rawstr``): default: ``'v?\d+.*'``
        append_tags (list or None): additional tags to append
        git_cmd (list): list of command strings

    Yields:
        str: tag name
    """
    git_list_tags_cmd = git_cmd[:] + ["tag", "-l"]

    if tags is None:

        if True:
            git_get_first_rev_cmd = [
                "rev-list",
                "--all",
                "--reverse",
                "--abbrev-commit",
            ]  # |head -n 1
            cmd = git_cmd + git_get_first_rev_cmd
            first_rev_output = subprocess.check_output(cmd).splitlines()
            if not first_rev_output:
                raise Exception(
                    (
                        "no first revision found:",
                        ("cmd", cmd),
                        ("output", first_rev_output),
                    )
                )
            else:
                yield first_rev_output[0].rstrip()

        tag_output = subprocess.check_output(git_list_tags_cmd).splitlines()
        log.debug(("tag_output", tag_output))

        # import semantic_version
        versiontags = []
        for tagstr in tag_output:
            tagstr = str(tagstr) if IS_PYTHON2 else tagstr.decode("utf8")
            log.debug(("tag", tagstr))
            if re.match(tagrgx, tagstr):
                log.debug(("tagmatchedrgx", tagstr))
                if tagstr.startswith("v"):
                    _tagstr = tagstr[1:]
                elif tagstr.startswith("release/"):
                    _tagstr = tagstr[7:]
                else:
                    _tagstr = tagstr
                ver = semantic_version.Version(_tagstr.rstrip())
                versiontags.append((ver, tagstr))
            else:
                log.debug(("tag didn't match rgtagstr", tagstr))
        for version, tagstr in sorted(versiontags):
            yield tagstr
    if append_tags:
        for tag in append_tags:
            yield tag


def git_get_rev_date(revstr, *, git_cmd):
    git_get_rev_date_cmd = ["log", "-n1", revstr, "--format=%ci"]
    cmd = git_cmd + git_get_rev_date_cmd
    return subprocess.check_output(cmd).strip()


def iter_release_data(tagpairs, git_cmd, tagdates, encoding):
    for (tag1, tag2) in tagpairs[::-1]:
        data = {}
        tag1 = tag1.decode(encoding) if hasattr(tag1, "decode") else tag1
        # tag1date = tagdates.setdefault(tag1, git_get_rev_date(tag1))
        tag2date = tagdates.setdefault(
            tag2, git_get_rev_date(tag2, git_cmd=git_cmd)
        )
        data["tag2date"] = tag2date
        heading = rst_escape(
            "%s (%s)" % (tag2, tag2date.decode(encoding))
        )  # TODO: date
        data["heading"] = heading
        logpath = "%s..%s" % (tag1, tag2)
        data["logpath"] = logpath
        changelog_cmd = [
            "log",
            "--reverse",
            "--pretty=format:* %s [%h]",
            logpath,
        ]
        data["changelog_cmd"] = changelog_cmd
        changelog_cmdstr = (
            "log --reverse --pretty=format:'* %s [%h]' " + logpath
        )
        data["changelog_cmdstr"] = changelog_cmdstr
        cmd = git_cmd + changelog_cmd
        data["cmd"] = cmd
        log.debug(cmd)
        log.debug(("cmdstr*", " ".join(cmd)))
        output = subprocess.check_output(cmd)
        data["_output"] = output
        data["output_rst"] = rst_escape(output)
        yield data

        #
        tag1 = tag2


def template_as_rst(
    tagpairs, git_cmd, *, tagdates, encoding, heading_char, include_cmd=True
):
    for data in iter_release_data(
        tagpairs, git_cmd, tagdates, encoding=encoding
    ):
        # RST heading
        yield ""
        yield ""
        yield data["heading"]
        yield heading_char * len(data["heading"])
        if include_cmd:
            yield "::"
            yield ""
            yield "   git %s" % (data["changelog_cmdstr"])
            yield ""
        yield data["output_rst"]


def template_as_md(
    tagpairs,
    git_cmd,
    *,
    tagdates,
    encoding,
    heading_char="#",
    heading_level=2,
    include_cmd=True,
):
    for data in iter_release_data(
        tagpairs, git_cmd, tagdates, encoding=encoding
    ):
        # RST heading
        yield ""
        yield ""
        if heading_level:
            yield "%s %s" % ((heading_level * heading_char), data["heading"])
        if include_cmd:
            yield "```bash"
            yield "$ git %s" % (data["changelog_cmdstr"])
            yield "```"
            yield ""
        yield data["output_rst"]


def iter_tag_pairs(
    tags,
    *,
    git_cmd,
    format="rst",
    heading_char="^",
    heading_level=2,
    include_cmd=True,
    encoding="utf-8",
):
    """Iterate over 2-tuple tag pairs e.g. ``[(tag1, tag2), ]``

    Args:
        tags (list
    """
    tagdates = collections.OrderedDict()
    tagpairsiter = izip(tags, itertools.islice(tags, 1, None))
    tagpairs = list(tagpairsiter)
    log.debug(("tagpairs", tagpairs))

    _format = format.lower()
    if _format not in {"rst", "md"}:
        raise ValueError(("format unsupported", _format))

    if _format == "rst":
        return template_as_rst(
            tagpairs,
            git_cmd,
            encoding=encoding,
            tagdates=tagdates,
            heading_char=heading_char,
            include_cmd=include_cmd,
        )
    elif _format == "md":
        return template_as_md(
            tagpairs,
            git_cmd,
            encoding=encoding,
            tagdates=tagdates,
            heading_char=heading_char,
            heading_level=heading_level,
            include_cmd=include_cmd,
        )


def git_changelog(
    *,
    path=None,
    tags=None,
    append_tags=None,
    all_tags=None,
    git_bin=None,
    format="rst",
    heading_char=None,
    heading_level=2,
    include_cmd=True,
):
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
        distutils.spawn.find_executable("git") if git_bin is None else git_bin
    )
    git_cmd = [git_bin]
    if path:
        git_cmd.extend(["-R", path])

    _format = format.lower()
    if heading_char is None:
        if _format == "rst":
            heading_char = "^"
        elif _format == "md":
            heading_char = "#"

    tagsiter = git_list_tags(
        git_cmd=git_cmd, tags=tags, append_tags=append_tags, all_tags=all_tags
    )
    tags = list(tagsiter)
    log.debug(("tags", tags))

    for line in iter_tag_pairs(
        tags,
        git_cmd=git_cmd,
        format=format,
        heading_char=heading_char,
        heading_level=heading_level,
        include_cmd=include_cmd,
    ):
        yield line


import types


def test_git_changelog_rst():
    output = git_changelog()
    assert output
    assert isinstance(output, types.GeneratorType)
    lines = list(output)
    for line in lines:
        print(line)
    print(output)


def test_git_changelog_md():
    output = git_changelog(format="md")
    assert output
    assert isinstance(output, types.GeneratorType)
    lines = list(output)
    for line in lines:
        print(line)
    print(output)


def main(argv=None):
    """
    git-changelog main() function

    Keyword Arguments:
        argv (list): commandline arguments (e.g. sys.argv[1:])
    Returns:
        int:
    """
    import logging
    import optparse
    import sys

    prs = optparse.OptionParser(
        usage="%prog [-v] --fmt=<rst|md> [--develop] [-a] [-r <tag|rev>] [-r <>]",
        description=(
            "Print commits between tags (e.g. tagged releases)"
            " as ReStructuredText or Markdown (beta)"
        ),
    )

    prs.add_option(
        "--develop",
        dest="append_tag_develop",
        action="store_true",
        help="Include the develop branch",
    )

    prs.add_option(
        "-r", "--rev", "--revision", dest="append_revision", action="append"
    )

    prs.add_option(
        "-a", "--all", "--all-tags", dest="all_tags", action="store_true"
    )

    # prs.add_option('--reverse',
    #               dest='reverse',
    #               action='store_true',
    #               help='Order revisions by oldest first')

    prs.add_option(
        "--fmt",
        "--format",
        dest="format",
        action="store",
        help="Output format ('rst' || 'md')",
    )
    prs.add_option(
        "--hdr",
        "--heading-character",
        dest="heading_char",
        action="store",
        help="Heading character (defaults: rst: '^', md: '#')",
    )
    prs.add_option(
        "--heading-level",
        dest="heading_level",
        action="store",
        default=2,
        help="Heading level for md format (2 => '##')",
    )
    prs.add_option(
        "--no-include-cmd",
        dest="include_cmd",
        action="store_false",
        default=True,
        help=(
            "Do not include the git command"
            " used to generate the log section"
        ),
    )

    prs.add_option(
        "-v",
        "--verbose",
        dest="verbose",
        action="store_true",
    )
    prs.add_option(
        "-q",
        "--quiet",
        dest="quiet",
        action="store_true",
    )
    prs.add_option(
        "-t",
        "--test",
        dest="run_tests",
        action="store_true",
    )

    if '-t' in argv:
        argv.remove('-t')
        cmd = ["pytest", "-v"] + argv + [__file__]
        import subprocess

        return subprocess.call(cmd)


    (opts, args) = prs.parse_args(args=argv)
    loglevel = logging.INFO
    if opts.verbose:
        loglevel = logging.DEBUG
    elif opts.quiet:
        loglevel = logging.ERROR
    logging.basicConfig(level=loglevel)
    global log
    log = logging.getLogger()
    log.debug("opts: %r", opts)
    log.debug("args: %r", args)
    argv = list(argv) if argv else []
    log.debug("argv: %r", argv)

    EX_OK = 0
    conf = {}
    append_tags = []
    if opts.append_tag_develop:
        append_tags.append("develop")
    if opts.append_revision:
        append_tags.extend(opts.append_revision)
    conf["append_tags"] = append_tags
    # conf['reverse'] = opts.reverse

    conf["all_tags"] = opts.all_tags

    conf["heading_char"] = opts.heading_char
    conf["heading_level"] = opts.heading_level
    conf["include_cmd"] = opts.include_cmd

    format_ = opts.format.lower() if opts.format else None
    if format_ is None:
        prs.print_help()
        prs.error("--fmt must be specified")

    if format_ not in ["rst", "md"]:
        prs.print_help()
        prs.error("--fmt=%r is not supported" % (opts.format))

    conf["format"] = format_
    if conf["heading_char"] is None:
        if _format == "rst":
            conf["heading_char"] = "^"
        elif _format == "md":
            conf["heading_char"] = "#"

    log.debug(("conf", conf))
    output = git_changelog(**conf)
    for line in output:
        print(line, file=sys.stdout)
    return EX_OK


if __name__ == "__main__":
    import sys

    sys.exit(main(argv=sys.argv[1:]))
