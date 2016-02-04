
### ~/.i3/Makefile
## A makefile for working with i3wm

I3CONFIG="config"
#I3CONFIG="config-mb1"

SCREENSHOTSDIR="${HOME}/Pictures/screenshots"

default: test

help:
	@echo "## i3 Makefile"
	@echo "setup    -- setup i3 (SCREENSHOTSDIR)"
	@echo "help_i3  -- print commented configured i3 shortcuts"
	@echo "status   -- show i3 current status (with i3-msg)"
	@echo "test     -- reload and restart i3 with current ~/.i3/config"
	@echo ""

setup:
	mkdir -p $(SCREENSHOTSDIR)
	which dnf     && sudo dnf     install -y \
		xfce4-screenshooter feh \
		gnome-screensaver network-manager-applet
	which apt-get && sudo apt-get install -y \
		xfce4-screenshooter feh \
		gnome-screensaver

help_i3:
	@#cat "${I3CONFIG}" | egrep '(^(\s*)?##+ |^(\s*)?#  )'
	"$${__DOTFILES}/scripts/dotfiles-i3.sh"

test:
	i3-msg 'reload'
	i3-msg 'restart'

check:
	which i3
	which i3bar
	which i3status
	which i3lock
	which i3-msg
	which i3-nagbar
	i3 -v
	i3-msg -t get_version | python -mjson.tool

status:
	$(MAKE) check
	i3-msg -t get_outputs | python -mjson.tool
	i3-msg -t get_workspaces | python -mjson.tool
	i3-msg -t get_tree | python -mjson.tool
	i3-msg -t get_marks | python -mjson.tool
	i3-msg -t get_bar_config | python -mjson.tool

checkpkgs:
	@(test -f ~/-dotfiles/scripts/websh.py \
		&& echo ~/-dotfiles/scripts/websh.py \
		&& echo '- [x] websh.py') \
		|| echo '- [ ] websh.py'
	@
	@(test -f ~/-dotfiles/scripts/xlck.sh \
		&& echo '- [x] xlck.sh') \
		|| echo '- [ ] xlck.sh'
	@
	@(which xautolock \
		&& echo '- [x] xautolock') \
		|| echo '- [ ] xautolock'
	@(which i3lock \
		&& echo '- [x] i3lock') \
		|| echo '- [ ] i3lock'
	@(which gnome-screensaver \
		&& echo '- [x] gnome-screensaver') \
		|| echo '- [ ] gnome-screensaver'
	@(which gnome-screensaver-command \
		&& echo '- [x] gnome-screensaver-command') \
		|| echo '- [ ] gnome-screensaver-command'
	@
	@(which xfce4-screenshooter \
		&& echo '- [x] xfce4-screenshooter') \
		|| echo '- [ ] xfce4-screenshooter'
	@(which feh \
		&& echo '- [x] feh') \
		|| echo '- [ ] feh'
	@(which nm-applet \
		&& echo '- [x] nm-applet') \
		|| echo '- [ ] nm-applet'
	@(which i3-sensible-editor \
		&& echo '- [x] i3-sensible-editor') \
		|| echo '- [ ] i3-sensible-editor'
	@(which xbacklight \
		&& echo '- [x] xbacklight') \
		|| echo '- [ ] xbacklight'
	@(which xgamma \
		&& echo '- [x] xgamma') \
		|| echo '- [ ] xgamma'
	@(which fluxgui \
		&& echo '- [x] fluxgui') \
		|| echo '- [ ] fluxgui'
