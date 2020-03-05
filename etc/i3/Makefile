
### ~/.i3/Makefile
## A makefile for working with i3wm

I3CONFIG="config"
#I3CONFIG="config-mb1"

SCREENSHOTSDIR='${HOME}/Pictures/screenshots'

default: test

help:
	@echo "## i3 Makefile"
	@echo "setup    -- setup i3 (SCREENSHOTSDIR)"
	@echo "help_i3  -- print commented configured i3 shortcuts"
	@echo "status   -- show i3 current status (with i3-msg)"
	@echo "test     -- reload and restart i3 with current ~/.i3/config"
	@echo ""

setup:
	$(MAKE) setuppictures
	$(MAKE) setuppkgs

setuppictures:
	test -d $(SCREENSHOTSDIR) || mkdir -p $(SCREENSHOTSDIR)
	test -f ~/wallpaper.png || echo '[ ] ~/wallpaper.png not found'

setuppkgs:
	which dnf && $(MAKE) setuppkgs_dnf
	which apt-get && $(MAKE) setuppkgs_apt

setuppkgs_dnf:
	## setuppkgs_dnf:   ## install packages with dnf, apt-get
	sudo dnf install -y \
		xautolock \
		i3 \
		i3status \
		gnome-screensaver \
		i3lock \
		network-manager-applet \
		xbacklight \
		xgamma \
		xfce4-screenshooter \
		feh \
		gphotoframe \
		gphotoframe-gss \
		pulseaudio-utils

setuppkgs_apt:
	## setuppkgs_apt:   ## install packages with apt-get
	sudo apt-get install -y \
		xautolock \
		i3 \
		i3status \
		gnome-screensaver \
		i3lock \
		network-manager-gnome \
		xbacklight \
		xgamma \
		xfce4-screenshooter \
		feh \
		pulseaudio-utils

__DOTFILES?=${HOME}/-dotfiles

help_i3:
	@## help_i3     ## print commentlines from i3 w/ [dotfileshelp,dhelp,dh)
	$(__DOTFILES)/scripts/dhelp i3

helpi3: help_i3

test:
	## test         ## test i3: i3-msg reload ; i3-msg restart
	i3-msg 'reload'
	i3-msg 'restart'

check:
	## check        ## check for i3 (see also: checkpkgs TODO)
	which i3
	which i3bar
	which i3status
	which i3lock
	which i3-msg
	which i3-nagbar
	which i3-sensible-editor
	i3 -v
	i3-msg -t get_version | python -mjson.tool

status:
	@## status:     ## check i3 status w/ i3-msg -t get_ | python -mjson.tool
	$(MAKE) check
	i3-msg -t get_outputs | python -mjson.tool
	i3-msg -t get_workspaces | python -mjson.tool
	i3-msg -t get_tree | python -mjson.tool
	i3-msg -t get_marks | python -mjson.tool
	i3-msg -t get_bar_config | python -mjson.tool

WEBSH=$(__DOTFILES)/scripts/websh.py
XLCKSH=$(__DOTFILES)/scripts/xlck.sh

checkpkgs:
	## checkpkgs:   ## check for scripts and packages
	@(test -f $(WEBSH) \
		&& echo '[x] websh.py: $(WEBSH)') \
		|| echo '[ ] websh.py: $(WEBSH)'
	# i3         ## i3 window manager (e.g. called by [gdm, lightdm,])
	@(which i3 \
		&& echo '[x] i3') \
		|| echo '[ ] i3'
	# i3-msg     ## i3 i3-msg
	@(which i3-msg \
		&& echo '[x] i3-msg') \
		|| echo '[ ] i3-msg'
	# i3bar     ## i3 i3bar
	@(which i3bar \
		&& echo '[x] i3bar') \
		|| echo '[ ] i3bar'
	# i3-nagbar  ## i3 notifications
	@(which i3-nagbar \
		&& echo '[x] i3-nagbar') \
		|| echo '[ ] i3-nagbar'
	# i3-sensible-editor  ## i3 launch an $$EDITOR
	@(which i3-sensible-editor \
		&& echo '[x] i3-sensible-editor') \
		|| echo '[ ] i3-sensible-editor'
	###
	## xlck.sh             ## check,start,stop screensaver
	@(test -f '$(XLCKSH)' \
	&& echo '[x] xlck.sh: $(XLCKSH)') \
		|| echo '[ ] xlck.sh: $(XLCKSH)'
	## xautolock           ## screensaver wrapper daemon
	@(which xautolock \
		&& echo '[x] xautolock') \
		|| echo '[ ] xautolock'
	###
	## gnome-screensaver   ## gnome-screensaver / screenlocker
	@(which gnome-screensaver \
		&& echo '[x] gnome-screensaver') \
		|| echo '[ ] gnome-screensaver'
	## gnome-screensaver-command  ## [dnf,]
	@(which gnome-screensaver-command \
		&& echo '[x] gnome-screensaver-command') \
		|| echo '[ ] gnome-screensaver-command'
	## i3lock              ## i3 screenlocker
	@(which i3lock \
		&& echo '[x] i3lock') \
		|| echo '[ ] i3lock'
	###
	## nm-applet           ## NetworkManager applet (taskbar WiFi icon, menu)
	@(which nm-applet \
		&& echo '[x] nm-applet') \
		|| echo '[ ] nm-applet'
	###
	## xbacklight          ## adjust monitor backlight
	@(which xbacklight \
		&& echo '[x] xbacklight') \
		|| echo '[ ] xbacklight'
	## xgamma              ## adjust X gamma settings
	@(which xgamma \
		&& echo '[x] xgamma') \
		|| echo '[ ] xgamma'
	## fluxgui             ## flux https://justgetflux.com
	@(which fluxgui \
		&& echo '[x] fluxgui') \
		|| echo '[ ] fluxgui'
	###
	## xfce4-screenshooter ## screenshots w/ a save dialog
	@(which xfce4-screenshooter \
		&& echo '[x] xfce4-screenshooter') \
		|| echo '[ ] xfce4-screenshooter'
	###
	## feh                 ## set the X background (e.g. to ~/wallpaper.png)
	@(which feh \
		&& echo '[x] feh') \
		|| echo '[ ] feh'
	## gphotoframe         ## display photos: desktop, gnome-screensaver
	@(which gphotoframe \
		&& echo '[x] gphotoframe') \
		|| echo '[ ] gphotoframe'
	## pactl               ## set the volume with pactl [pulseaudio-utils]
	@(which pactl \
		&& echo '[x] pactl') \
		|| echo '[ ] pactl'
	###
