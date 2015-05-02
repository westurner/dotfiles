
Changelog
==========

.. code:: bash

    git log --graph v0.1.1..HEAD
    git log --format='* %s [%h]' v0.8.2..HEAD

0.8.3
------
* UBY: docs/_static/css/local.css: #sidebar-wrapper max-width:25% [d3e1408]
* BUG,ENH: editw completion, lsw(), findw(), grepw() [9f95863]
* REf: .gitignore: etc/vim -> etc/.vim [c1edfea]
* BLD,REF: scripts/bootstrap_dotfiles.sh: etc/vim -> etc/.vim (for grinw and grindw) [bc2b0ac]


0.8.2
------

* SEC,BUG: shell_escape_single in dotfiles_status() (ds())
* BUG: x-www-browser -> web (system lockup from xdg-open loop)
* BUG: css/leftnavbar.css: max-width: 25% to fix flicker
* DOC,BLD: conf.py: html_link_suffix = '' (see: pgs)
* DOC: scripts/usrlog.sh: docstrings
* ENH: etc/i3/config: Start gnome-settings-daemon (e.g. for anti-aliasing)
* ENH: scripts/osquery-all.sh: ``SELECT * from * > *.{html,json,csv}``; index.html
* REF,BUG: CONDA_ENVS_PATH, _setup_venv_prompt
* ENH: _virtualenvwrapper_get_step_num
* ENH: factor into _setup_virtualenvwrapper_dotfiles_config, _setup_virtualenvwrapper_dotfiles_config for (a start at) virtualenvwrapper compatability
* ENH,BUG: wec/workon_conda completion
* ENH,BUG: only load virtualenvwrapper once
* UBY,ENH: scripts/osquery-all.sh: Bootstrap CSS (table-striped table-hover)

0.01
-----

* Created dotfiles project

