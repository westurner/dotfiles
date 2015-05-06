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

LOG_TRACE = 6
logging.addLevelName('TRACE', LOG_TRACE)
log = logging.getLogger(__name__)

try:
    # import keyring (if it is available)
    import keyring
    keyring
    from keyring.backend import KeyringBackend
except Exception as e:
    log.exception(e)

    class KeyringBackend(object):
        pass


class DEFAULT:
    pass


class Store(object):
    pass


class KeyValueStore(Store):  # , KeyringBackend):

    KEYDELIM = u".."
    KEYDELIM_ESCAPE = u"\.."

    DEFAULT_PREFIX = '-p6'

    def __init__(self, prefix, data=None, conf=None):
        self.conf = collections.OrderedDict() if conf is None else conf
        self.set_prefix(prefix)
        self.data = collections.OrderedDict() if data is None else data
        if data:
            self.update(data)

    def set_prefix(self, prefix=None):
        if prefix is None:
            prefix = self.DEFAULT_PREFIX
        prefix = os.path.expanduser(os.path.expandvars(prefix))
        self.conf['prefix'] = prefix

    def escape_key_part(self, keystr):
        if not keystr:
            return keystr
        return keystr.replace(self.KEYDELIM, self.KEYDELIM_ESCAPE)

    def joinkey(self, args):
        parts = (self.escape_key_part(p) for p in args)
        return self.KEYDELIM.join(parts)

    # [parts[0]] + [_p.lstrip(os.path.sep) for _p in parts[1:]])

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
        log.log(LOG_TRACE, ' ? contains(%r) <%r>', key, self)
        retval = key in self.data
        if retval:
            log.log(LOG_TRACE, ' X contains(%r) <%r>', key, self)


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
        log.log(LOG_TRACE, 'getitem: %r', key)
        return self.get(key)

    def __setitem__(self, key, value):
        log.log(LOG_TRACE, 'setitem: %r, %r', key, value)
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
        if hasattr(self, 'extra_init'):
            self.extra_init(prefix, data=data, conf=conf)

    def __contains__(self, key):
        key = self.transform_key(key)
        path = os.path.join(self.conf['prefix'], key)
        log.log(LOG_TRACE, ' ? contains__(%r) <%r>', path, self)
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

def shell_escape(str_):
    """shell escape a string

    Args:
        str_ (basestring): string to 'qu\'ote and "escape"'
    Returns:
        unicode: str
    """
    return repr(unicode(str_))[1:]


def gpg_encrypt(filelike,
                homedir="~/.gnupg",
                trust_model="always",
                user='p6',
                secring='p6.sec',
                pubring='p6.pub',
                key_name=None):
    """
    Arguments:
        filelike (file-like or str): data to transform
                                    (if str: StringIO(str))

    Keyword Arguments:
        key_name (unicode): dest_user

    Returns:
        str: subprocess.check_output(cmd, shell=True, stdin=filelike)
    """
    cmd_tmpl = ("""cat | gpg --homedir={homedir} --trust-model={trust_model}"""
                """ --encrypt --armor"""
                """ --secret-keyring={secring} --keyring={pubring}"""
                """ -u {user} -r {key_name}""")
    cmd = cmd_tmpl.format(
        homedir=shell_escape(os.expanduser(homedir)),
        user=shell_escape(user),
        secring=shell_escape(secring),
        pubring=shell_escape(pubring),
        key_name=shell_escape(key_name),
        trust_model=shell_escape(trust_model))
    if isinstance(filelike, basestring):
        filelike = StringIO.StringIO(filelike)
    log.log(LOG_TRACE, 'subprocess.Popen(%r)', cmd)
    process = subprocess.Popen(cmd, shell=True,
                               stdin=subprocess.PIPE,
                               stdout=subprocess.PIPE)
    stdout, stderr = process.communicate(input=filelike.read())
    if (process.returncode != 0):
        raise subprocess.CalledProcessError(
            process.returncode, cmd, '%s\n\n## STDERR ##\n%s' % (stdout, stderr))
    return stdout


def gpg_decrypt(filelike,
                homedir='~/.gnupg',
                user='p6',
                secring='p6.sec',
                pubring='p6.pub'):
    """
    Arguments:
        filelike (file-like or str): data to transform
                                     (if str: StringIO(str))

    Keyword Arguments:
        user (unicode): user to decrypt as

    Returns:
        str: subprocess.check_output(cmd, shell=True, stdin=filelike)
    """
    cmd_tmpl = (
        """cat | gpg"""
        """ --homedir {homedir}"""
        """ --decrypt"""
        """ --secret-keyring={secring}"""
        """ --keyring={pubring}"""
        """ -u {user}""")
    cmd = cmd_tmpl.format(
        homedir=shell_escape(os.expanduser(homedir)),
        user=shell_escape(user),
        secring=shell_escape(secring),
        pubring=shell_escape(pubring))
    if isinstance(filelike, basestring):
        filelike = StringIO.StringIO(filelike)
    log.log(LOG_TRACE, 'subprocess.Popen(%r)', cmd)
    process = subprocess.Popen(cmd, shell=True,
                               stdin=subprocess.PIPE,
                               stdout=subprocess.PIPE)
    stdout, stderr = process.communicate(input=filelike.read())
    if (process.returncode != 0):
        raise subprocess.CalledProcessError(
            process.returncode, cmd, '%s\n\n## STDERR ##\n%s' % (stdout, stderr))
    return stdout


class OnDiskGPGKeyValueStore(OnDiskKeyValueStore):

    def extra_init(self, prefix, data=None, conf=None, mountpt='@@@'):
        self.mountpt = mountpt
        self.path = os.path.join(self.conf['prefix'], self.mountpt)
        self.disk_store = OnDiskKeyValueStore(self.path, data=data, conf=conf)

    def get(self, key, default=DEFAULT):
        key = self.transform_key(key)
        data = self.disk_store.get(key, default=default)
        _value = gpg_decrypt(data, key_name=self.conf['key_name'])
        return _value

    def set(self, key, value):
        key = self.transform_key(key)
        _value = gpg_encrypt(value, key_name=self.conf['key_name'])
        return self.disk_store.set(key, _value)


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

    def __contains__(self, key):
        key = self.transform_key(key)
        log.log(LOG_TRACE, ' ? contains(%r) <%r>', key, self)
        retval = self.get(key, default=DEFAULT) != DEFAULT
        if retval:
            log.log(LOG_TRACE, ' X contains(%r) <%r>', key, self)

    def __setitem__(self, key, value):
        self.keyring.set_password(self.conf['prefix'], key, value)


class Prompt6(KeyValueStore):

    DEFAULT_PREFIX = '-p6'  #  ${VIRTUAL_ENV}/etc/p6'

    def __init__(self, prefix=None, data=None, conf=None, stores=None):
        self.conf = collections.OrderedDict() if conf is None else conf
        prefix = prefix if prefix is not None else self.DEFAULT_PREFIX
        self.set_prefix(prefix)
        self.stores = self.configure_stores(prefix=prefix,
                                            data=data,
                                            stores=stores)

    def configure_stores(self, prefix=None, data=None, stores=None):
        if stores is None:
            stores = collections.OrderedDict()
            stores['mem'] = KeyValueStore(prefix, data=data)
            # stores['disk'] = OnDiskKeyValueStore(prefix)
            stores['diskg'] = OnDiskGPGKeyValueStore(prefix, conf=dict(key_name='p6'))
            stores['ring'] = KeyringValueStore(prefix)
        return stores

    def get(self, key, default=DEFAULT, get_iter=False):
        log.log(LOG_TRACE, 'get(%r)', key)
        output = self._get(key, default=default, get_iter=get_iter)
        if get_iter:
            return output
        if not output:
            raise KeyError(key)
        try:
            return next(iter(output))
        except StopIteration:
            raise KeyError(key)

    def _get(self, key, default=DEFAULT, get_iter=False):
        value = DEFAULT
        key, store = self.get_store_for_key(key)
        if store:
            yield store.get(key)
        else:
            for (name, store) in iteritems(self.stores):
                log.debug(('%r %r' % (name, store)))
                if key in store:
                    value = store.get(key, default=default)
                    if get_iter:
                        yield (store, value)
                    else:
                        if value != default:
                            yield value
                            return
        return

    def get_all(self, key, default=DEFAULT, get_iter=True):
        return list(self.get(key, default=default, get_iter=get_iter))

    def get_store_for_key(self, key):
        """

        ::

            <key>@@@ | <key>@@diskg -> stores['diskg']
            <key>@@  | <key>@@ring  -> stores['ring']
        """
        store = None
        if key.endswith('@@@'):
            key = key[:-3]
            store = self.stores.get('diskg')
            if store is None:
                raise Exception('diskg not configured')
        elif key.endswith('@@diskg'):
            key = key[:-7]
            store = self.stores.get('diskg')
            if store is None:
                raise Exception('diskg not configured')
        elif key.endswith('@@'):
            key = key[:-2]
            store = self.stores.get('ring')
            if store is None:
                raise Exception('ring not configured')
        elif key.endswith('@@ring'):
            key = key[:-6]
            store = self.store.get('ring')
            if store is None:
                raise Exception('ring not configured')
        return (key, store)

    def set(self, key, value):
        key, store = self.get_store_for_key(key)
        if store is None:
            store = self.stores.get('diskg')
        log.debug('store: %r', store)
        store[key] = value

    def transform_key(self, keystr):
        key = self.path_to_key(keystr)
        return key


import pprint
import unittest


class ConfigObj(object):
    """Config object w/ attr access to __dict__

    """
    def __init__(self, data=None):
        """
        Arguments:
            data (dict): ~self.__dict__.update(data)
        """
        self._reserved_keys_ = dict.fromkeys(self.__dict__.keys())
        if data is not None:
            self.update(data)

    def update(self, dict_):
        return self.__dict__.update(
            {k:v for k, v in dict_.items() if k not in self._reserved_keys_})

    def __str__(self):
        return pprint.pformat(self.__dict__)


class Test_prompt6(unittest.TestCase):

    def build_conf(self, **kwargs):
        conf = ConfigObj()
        conf.prefix = '-p6'
        conf.TEST_KEY='test_xyz'
        conf.TEST_VALUE=conf.TEST_KEY + '#.#'
        conf.TEST_DATA={conf.TEST_KEY: conf.TEST_VALUE}
        conf.update(kwargs)
        return conf

    def test_002_build_conf(self):
        conf = self.build_conf()
        self.assertTrue(conf)
        self.assertEqual(conf.TEST_VALUE, conf.TEST_DATA[conf.TEST_KEY])

    def test_010_prompt6(self):
        p6 = Prompt6()
        self.assertTrue(p6)
        self.assertTrue(isinstance(p6, Prompt6))
        conf = self.build_conf()
        p6[conf.TEST_KEY] = conf.TEST_VALUE
        value = p6[conf.TEST_KEY]
        self.assertEqual(value, conf.TEST_VALUE)

    def test_020_prompt6(self):
        conf = self.build_conf()
        p6 = Prompt6(prefix=conf.prefix, data=conf.TEST_DATA)
        self.assertTrue(p6)
        value = p6[conf.TEST_KEY]
        self.assertTrue(value)
        self.assertEqual(value, conf.TEST_VALUE)

    def test_021(self):
        conf = self.build_conf()
        p6 = Prompt6(prefix=conf.prefix, data=conf.TEST_DATA)
        TEST_KEY2 = 'test2'
        TEST_VALUE2 = TEST_KEY2 + '###'
        p6[TEST_KEY2] = TEST_VALUE2
        value2 = p6[TEST_KEY2]
        self.assertEqual(value2, TEST_VALUE2)

    def test_022_atat(self):
        conf = self.build_conf()
        p6 = Prompt6(prefix=conf.prefix, data=conf.TEST_DATA)
        TEST_KEY2 = 'test2@@'
        TEST_VALUE2 = TEST_KEY2 + '###@@'
        p6[TEST_KEY2] = TEST_VALUE2
        value2 = p6[TEST_KEY2]
        self.assertEqual(value2, TEST_VALUE2)


class TestPrompt6__main(unittest.TestCase):

    def test_040_main(self):
        x = main()
        self.assertEqual(x, 0)

    def test_041_main_help(self):
        self.assertRaises(SystemExit, main, ['-h'])
        self.assertRaises(SystemExit, main, ['--help'])
        self.assertRaises(SystemExit, main, ['--set', '1', '2', '-h'])

    def test_042_main_get(self):
        key = '_nonexistant_key' + str(id(self))
        args = ['--get', key]
        ret = main(args)
        self.assertEqual(ret, 1)


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
                   nargs=1,
                   action='append')
    prs.add_option('-s', '--set',
                   dest='set',
                   nargs=2,
                   action='append')
    prs.add_option('--pw', '--set-password',
                   dest='set_password',
                   nargs=1,
                   action='append')

    prs.add_option('-p', '--prefix',
                   dest='prefix',
                   action='store',
                   default='${VIRTUAL_ENV}/etc/p6')

    prs.add_option('-d', '--data',
                   nargs=2,
                   action='append')

    prs.add_option('-a', '--all',
                   dest='all',
                   action='store_true')

    prs.add_option('-v', '--verbose',
                   dest='verbose',
                   action='count')
    prs.add_option('-q', '--quiet',
                   dest='quiet',
                   action='store_true',)
    prs.add_option('-t', '--test',
                   dest='run_tests',
                   action='store_true',)
    args = argv if argv is not None else []
    (opts, args) = prs.parse_args(args=args)

    loglevel = logging.INFO
    if opts.quiet:
        loglevel = logging.WARNING
    if opts.verbose == 1:
        loglevel = logging.DEBUG
    elif opts.verbose > 1:
        loglevel = LOG_TRACE
    logfmtstr = '%(asctime)s\t%(levelname)-6s\t%(message)s'
    logging.basicConfig(
        level=loglevel,
        format=logfmtstr)
    log.setLevel(loglevel)
    log.info('opts: %r', opts)
    # log.info('args: %r', args)
    # if not opts.quiet:
    #    import logging.handlers
    #    handler = logging.handlers.SysLogHandler(
    #        facility=logging.handlers.SysLogHandler.LOG_DAEMON)
    #    log.addHandler(handler)

    if opts.run_tests:
        sys.argv = [sys.argv[0]] + args
        import unittest
        return unittest.main()

    stdout = codecs.getwriter('utf-8')(sys.stdout)

    def write(a):
        print(a, file=stdout)

    data = None
    if opts.data:
        data = dict(opts.data)
    p6 = Prompt6(prefix=opts.prefix, data=data)

    if opts.get:
        try:
            for key in opts.get:
                if opts.all:
                    output = p6.get_all(key)
                else:
                    output = p6.get(key)
                write(output)
            return 0
        except KeyError as e:
            log.exception(e)
            return 1
    elif opts.set:
        for (key, value) in opts.set:
            p6.set(key, value)
        return 0
    elif opts.set_password:
        import getpass
        for key in opts.set_password:
            value = getpass.getpass("%r: " % key)
            p6.set(key, value)
    return 0

if __name__ == "__main__":
    import sys
    sys.exit(main(argv=sys.argv[1:]))
