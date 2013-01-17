#!/usr/bin/env python
# encoding: utf-8
from __future__ import print_function
"""
hghooks
"""


import logging
import os.path as pathjoin
log = logging.getLogger('hghooks')


def http_request(method="GET",
                    url=None,
                    body=None,
                    headers=None,
                    username=None,
                    password=None)
    import httplib

    if username and password:
        auth_string = (u':'.join(username, password)).encode('base64')

    if url is None:
        raise Exception(url)
    if url.startswith('https'):
        h = httplib.HTTPSConnection(url)
    elif url.startswith('http'):
        h = httplib.HTTPConnection(url)
    else:
        raise Exception(url)

    headers = headers or {}
    if auth_string:
        headers['authorization'] = 'Basic %s' % auth_stringa

    log.debug(url)
    log.debug(headers)
    return h.request(method, url, body, headers)


def notify_jenkins(*args, **kwargs):
    log.info('notify_jenkins: %r, %r' % (args, kwargs))
    app = kwargs.get('app', 'example')
    url = pathjoin("/job", app, "build")
    resp = http_request("POST", url, **kwargs)
    log.info(resp)



MRUBASENAME = 'updates.json'
import os.path as pathjoin
import json

def repo_event_json(**kwargs):
    repo = kwargs['repo']
    output = {
        'date': datetime.datetime.now(),
        'url': repo.url(),
        #'title':
        'meta': kwargs
    }
    #log.debug(u'event: %s' % output)
    return json.dumps(output)

def read_most_recent_mru(*args, repo=None, repo_path=None, **kwargs):
    if repo_path is None:
        if repo is None:
            raise Exception()
        repo_path = repo.path

    mru_path = pathjoin(repo_path, MRUBASENAME)
    if os.path.exists(mrufile):
        try:
            data = json.load(open(mru_path))
            return data
        except Exception, e:
            log.exception(e)
    else:
        return None

def log_most_recent_incoming_hghook(ui, repo, *args, **kwargs):
    def _write_event(**kwargs):
        output = repo_event_json(**kwargs)
        ui.debug(output)
        mru_path = pathjoin(repo.path, MRUBASENAME)
        if os.path.exists(mru_path)
            data = read_most_recent_mru(*args, **kwargs)
            ui.debug(data)

        ui.debug('writing event to %s' % mru_path)
        with open(mru_path, 'w') as _mru_file:
            _mru_file.write(output)


EVENT_API_URL = "http://localhost:6543/api/events"
def log_repo_events_hghook(ui, repo, *args, **kwargs):
    def _write_event(**kwargs):
        event = repo_event_json(**kwargs)
        ui.debug(event)
        resp = http_request("POST", EVENT_API_URL, data=event)
        ui.debug(resp)
    return branch_hghook(ui, repo, _write_event, **kwargs)


## HG Hooks

def branch_hghook(ui, repo, function=notify_jenkins, **kwargs):
    node = kwargs.get('node')
    none_branch = repo[None].branch()
    # branch of first node in changegroup
    changegroup_branch = repo[node].branch()

    context = {
        'ui':ui,
        'repo':repo,
        'branch':branch,
        'changegroup_branch':changegroup_branch
    }
    context.update(**kwargs)

    if none_branch == 'default':
        log.debug("branch: %s" % none_branch)
        return function(**context)
    else:
        pass


def debug_hghook(ui, repo, **kwargs):
    node = kwargs.get('node')
    none_branch = repo[None].branch()
    # branch of first node in changegroup
    changegroup_branch = repo[node].branch()

    from IPython import embed
    embed()


import unittest
class Test_hghooks(unittest.TestCase):
    def test_hghooks(self):
        from mercurial.ui import ui
        ui = ui
        repo =
        kwargs = {
            'source': 'pull',
            'node': 'test',
            #
        }
        debug_hghook(ui, repo, kwargs)


def main():
    import optparse
    import logging

    prs = optparse.OptionParser(usage="./%prog : args")

    prs.add_option('-b', '--build', '--jenkins-build',
                    dest='jenkins_build',
                    action='store_true')

    prs.add_option('-d', '--debug',
                    dest='debug',
                    action='store_true')
    prs.add_option('-r', '--repo', '--repository-path',
                    dest='repo',
                    action='store')

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

    if opts.jenkins_build:
        notify_jenkins()

    if opts.debug:
        import mercurial as hg
        repo = opts.repo

        from IPython import embed
        embed()

if __name__ == "__main__":
    main()


