#!/usr/bin/env python
"""
dotfiles setup.py
===================
If ``paver.tasks`` does not exist,
``setup.py`` loads ``paver-minilib.zip``,
which contains a minimal version of `paver`_
containing ``paver.tasks``.

``paver.tasks`` enumerates and executes tasks defined in ``pavement.py``.

see: ``pavement.py``.

.. _paver: http://pypi.python.org/pypi/paver
"""

try:
    import paver.tasks
except ImportError:
    import os
    HERE = os.path.dirname( os.path.abspath(__file__) )
    PAVER_MINILIB = os.path.join(HERE, "paver-minilib.zip")
    if os.path.exists(PAVER_MINILIB):
        import sys
        sys.path.insert(0, PAVER_MINILIB)
    import paver.tasks

paver.tasks.main()
