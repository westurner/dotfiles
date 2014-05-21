### bashrc.readline.sh

#  vi-mode: vi(m) keyboard shortcuts
set -o vi

if [ -n "$BASH_VERSION" ]; then
    #  .         -- insert last argument (command mode)
    bind -m vi-command ".":insert-last-argument

    ## emulate default bash
    #  <ctrl> l  -- clear screen
    bind -m vi-insert "\C-l.":clear-screen
    #  <ctrl> a  -- move to beginning of line (^)
    bind -m vi-insert "\C-a.":beginning-of-line
    #  <ctrl> e  -- move to end of line ($)
    bind -m vi-insert "\C-e.":end-of-line
    #  <ctrl> w  -- delete last word
    bind -m vi-insert "\C-w.":backward-kill-word
fi
