

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
