hghooks
=========

A collection of mercurial repository hooks

- Debugging
- Jenkins Build

What is a mercurial repository hook?
---------------------------------------
- http://www.selenic.com/mercurial/hgrc.5.html#hooks (``man hgrc``)
- http://hgbook.red-bean.com/read/handling-repository-events-with-hooks.html
- http://mercurial.selenic.com/wiki/Hook

A shell script or Python callable that is executed when a repository
event occurs.


Usage
-------
in ``~/.hgrc`` or ``<repository/.hg/hgrc``
::

    # ...
    [hooks]
    changegroup.debug = <abs/path/to>debug.py:debug_main

    #commit =
    #incoming =
    #outgoing =
    #post-<command> =
    #pre-<command> =
    #prechangegroup =
    #precommit =
    #prelistkeys =
    #preoutgoing =
    #prepushkey =
    #pretag =
    #pretxnchangegroup =
    #pretxncommit =
    #preupdate =
    #listkeys =
    #pushkey =
    #tag =
    #update =

