#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function
"""
prompt6
"""

import sys
IS_PYTHON2 = (sys.version_info[0] == 2)
IS_PYTHON3 = (sys.version_info[0] == 3)
if IS_PYTHON2:
    import StringIO

    def iteritems2(obj):
        return obj.iteritems()
    iteritems = iteritems2
elif IS_PYTHON3:
    import stringio as StringIO

    def iteritems3(obj):
        return obj.items()
    iteritems = iteritems3

import codecs
import collections
import logging
import os
import subprocess

# logging.basicConfig(level=logging.DEBUG)
log = logging.getLogger()

try:
    # import keyring (if it is available)
    import keyring
    keyring
    from keyring.backend import KeyringBackend
except Exception as e:
    log.debug(e)

    class KeyringBackend(object):
        pass


class DEFAULT:
    pass


class Store(object):
    pass


class KeyValueStore(Store):  # , KeyringBackend):

    KEYDELIM = u".."
    KEYDELIM_ESCAPE = u"\.."

    def __init__(self, prefix, data=None, conf=None):
        self.conf = collections.OrderedDict() if conf is None else conf
        self.set_prefix(prefix)
        self.data = collections.OrderedDict() if data is None else data
        if data:
            self.update(data)

    def set_prefix(self, prefix=None):
        if prefix is None:
            prefix = os.path.expanduser(os.path.expandvars(self.DEFAULT_PREFIX))
        self.conf['prefix'] = prefix

    def escape_key_part(self, keystr):
        if not keystr:
            return keystr
        return keystr.replace(self.KEYDELIM, self.KEYDELIM_ESCAPE)

    def joinkey(self, args):
        parts = (self.escape_key_part(p) for p in args)
        return self.KEYDELIM.join(parts)

    def path_to_key(self, path):
        return str(path).replace(os.path.sep, self.KEYDELIM)

    def key_to_path(self, key):
        return key.replace(self.KEYDELIM, os.path.sep)

    def transform_key(self, key):
        return key.lstrip('/')
        parsed_key = self.path_to_key(key)
        components = []
        if self.conf['prefix']:
            components.append(self.conf['prefix'])
        components.append(parsed_key)
        joined_key = self.joinkey(components)
        return joined_key

    def __contains__(self, key):
        key = self.transform_key(key)
        return key in self.data

    def get(self, key, default=DEFAULT):
        key = self.transform_key(key)
        if default is not DEFAULT:
            return self.data.get(key, default)
        else:
            return self.data[key]

    def get_password(self, servicename, username, password):
        key = self.joinkey((servicename, username))
        return self.get(key, default=None)

    def __getitem__(self, key):
        return self.get(key)

    def __setitem__(self, key, value):
        log.debug('setitem: %r, %r', key, value)
        # key = self.transform_key(key)
        # log.debug('transform_key: %r, %r', key, value)
        self.set(key, value)

    def set(self, key, value):
        self.data[key] = value

    def update(self, data):
        if hasattr(data, 'items'):
            kv_iterable = iteritems(data)
        else:
            kv_iterable = data
        for (key, value) in list(kv_iterable):
            self.data[key] = value

# what do i think the problem is?


class OnDiskKeyValueStore(KeyValueStore):

    def __init__(self, prefix, data=None, conf=None):
        self.conf = collections.OrderedDict() if conf is None else conf
        self.set_prefix(prefix)
        if data:
            self.update(data)

    def __contains__(self, key):
        key = self.transform_key(key)
        path = os.path.join(self.conf['prefix'], key)
        log.debug('in: %r', path)
        return (os.path.exists(path) and os.path.isfile(path))

    def get(self, key, default=DEFAULT):
        key = self.transform_key(key)
        path = os.path.join(self.conf['prefix'], key)
        log.debug('get: %r', path)
        if not (os.path.exists(path) and os.path.isfile(path)):
            if default is not DEFAULT:
                return default
            raise KeyError(key)
        with codecs.open(path, 'r', encoding='utf-8') as f:
            return f.read()

    def set(self, key, value):
        key = self.transform_key(key)
        path = os.path.join(self.conf['prefix'], key)
        path_dir = os.path.dirname(path)
        if not os.path.exists(path_dir):
            # TODO XXX umask
            os.makedirs(path_dir)
        log.debug('path: %r', path)
        with codecs.open(path, 'w', encoding='utf-8') as f:
            f.write(value)


def gpg_encrypt(filelike, key_name=None):
    """
    Arguments:
        filelike (file-like): file to read (a str will be wrapped in StringIO)
    """
    cmd_tmpl = """cat | gpg --homedir ~/.gnupg --armor --encrypt -r {0}"""
    cmd = cmd_tmpl.format(repr(key_name))
    if isinstance(filelike, basestring):
        filelike = StringIO.StringIO(filelike)
    output = subprocess.check_output(cmd, stdin=filelike)
    return output


def gpg_decrypt(filelike, key_name=None):
    """
    Arguments:
        filelike (file-like): file to read (a str will be wrapped in StringIO)
    """
    cmd_tmpl = """cat | gpg --homedir ~/.gnupg --armor --encrypt -r {0}"""
    cmd = cmd_tmpl.format(repr(key_name))
    if isinstance(filelike, basestring):
        filelike = StringIO.StringIO(filelike)
    output = subprocess.check_output(cmd, stdin=filelike)
    return output


class OnDiskGPGKeyValueStore(KeyValueStore):

    def get(self, key, default=DEFAULT):
        data = KeyValueStore.get(self, key, default=default)
        _value = gpg_decrypt(data, key_name=self.conf['key_name'])
        return _value

    def set(self, key, value):
        key = self.transform_key(key)
        path = os.path.join(self.conf['prefix'], key)
        _value = gpg_encrypt(value, key_name=self.conf['key_name'])
        with codecs.open(path, 'w', encoding='utf-8') as f:
            f.write(_value)


class KeyringValueStore(KeyValueStore):

    def __init__(self, prefix, data=None, conf=None):
        self.conf = collections.OrderedDict() if conf is None else conf
        self.set_prefix(prefix)
        if data:
            self.update(data)
        import keyring
        # [... ]
        self.keyring = keyring

    def get(self, key, default=DEFAULT):
        try:
            return self.keyring.get_password(self.conf['prefix'], key)
        except Exception as e:
            e
            if default != DEFAULT:
                return default
            raise

    def __setitem__(self, key, value):
        self.keyring.set_password(self.conf['prefix'], key, value)


class Prompt6(KeyValueStore):

    DEFAULT_PREFIX = '${__DOTFILES}/etc/keys'

    def __init__(self, prefix=None, data=None, conf=None, stores=None):
        self.conf = collections.OrderedDict() if conf is None else conf
        self.set_prefix(prefix)
        self.stores = self.configure_stores(prefix=prefix,
                                            data=data,
                                            stores=stores)

    def configure_stores(self, prefix=None, data=None, stores=None):
        if stores is None:
            stores = collections.OrderedDict()
            stores['mem'] = KeyValueStore(prefix, data=data)
            stores['disk'] = OnDiskKeyValueStore(prefix)
            stores['ring'] = KeyringValueStore(prefix)
        return stores

    def get(self, key, default=DEFAULT, get_iter=False):
        output = self._get(key, default=default, get_iter=get_iter)
        if get_iter:
            return output
        return next(iter(output))

    def _get(self, key, default=DEFAULT, get_iter=False):
        value = DEFAULT
        if key.endswith('@@'):
            key = key[:-2]
            store = self.stores.get('ring')
            if store is None:
                raise Exception('ring not configured')
            value = store.get(key)
            yield value
        else:
            for (name, store) in iteritems(self.stores):
                log.debug(('%r %r' % (name, store)))
                if key in store:
                    value = store.get(key, default=default)
                    if get_iter:
                        yield (store, value)
                    else:
                        if value != DEFAULT:
                            yield value
                            return
        return

    def get_all(self, key, default=DEFAULT, get_iter=True):
        return list(self.get(key, default=default, get_iter=get_iter))

    def set(self, key, value):
        if key.endswith('@@'):
            key = key[:-2]
            store = self.stores.get('ring')
            if store is None:
                raise Exception('ring not configured')
        else:
            store = self.stores.get('disk')
        log.debug('store: %r', store)
        store[key] = value

    def transform_key(self, keystr):
        key = self.path_to_key(keystr)
        return key


def prompt6():
    """
    mainfunc
    """


import unittest


class Test_prompt6(unittest.TestCase):

    def test_prompt6(self):
        TEST_KEY = 'test1'
        TEST_VALUE = TEST_KEY + '#.#'
        TEST_DATA = {TEST_KEY: TEST_VALUE}
        p6 = Prompt6(prefix='./prefix', data=TEST_DATA)
        self.assertTrue(p6)
        value = p6[TEST_KEY]
        self.assertTrue(value, TEST_VALUE)

        TEST_KEY2 = 'test2'
        TEST_VALUE2 = TEST_KEY2 + '###'
        p6[TEST_KEY2] = TEST_VALUE2
        value2 = p6[TEST_KEY2]
        self.assertEqual(value2, TEST_VALUE2)


def main(argv=None):
    import logging
    import optparse
    import sys

    prs = optparse.OptionParser(usage="%prog [-g|--get] [-s|--set]")

    prs.add_option('-S', '--store',
                   dest='store',
                   action='store')

    prs.add_option('-g', '--get',
                   dest='get',
                   action='store')
    prs.add_option('-s', '--set',
                   dest='set',
                   nargs=2,
                   action='store')

    prs.add_option('-p', '--prefix',
                   dest='prefix',
                   action='store',
                   default='./prefix')

    prs.add_option('-d', '--data',
                   nargs=2,
                   action='append')

    prs.add_option('-a', '--all',
                   dest='all',
                   action='store_true')

    prs.add_option('-v', '--verbose',
                   dest='verbose',
                   action='store_true',)
    prs.add_option('-q', '--quiet',
                   dest='quiet',
                   action='store_true',)
    prs.add_option('-t', '--test',
                   dest='run_tests',
                   action='store_true',)
    args = argv if argv is not None else []
    (opts, args) = prs.parse_args(args=args)

    if not opts.quiet:
        logging.basicConfig()

        if opts.verbose:
            logging.getLogger().setLevel(logging.DEBUG)

    if opts.run_tests:
        sys.argv = [sys.argv[0]] + args
        import unittest
        exit(unittest.main())

    stdout = codecs.getwriter('utf-8')(sys.stdout)

    def write(a):
        print(a, file=stdout)

    data = None
    if opts.data:
        data = dict(opts.data)
    p6 = Prompt6(prefix=opts.prefix, data=data)

    if opts.get:
        if opts.all:
            write(p6.get_all(opts.get))
            return 0
        else:
            write(p6.get(opts.get))
            return 0
    elif opts.set:
        p6.set(*opts.set)

if __name__ == "__main__":
    import sys
    sys.exit(main(argv=sys.argv[1:]))
