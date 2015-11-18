
## ~/.i3/config/Makefile

## A makefile for working with i3wm

I3CONFIG="config"
#I3CONFIG="config-mb1"

default: test

help:
	@echo "## i3 Makefile"
	@echo "help_i3	-- print commented configured i3 shortcuts"
	@echo "status 	-- show i3 current status (with i3-msg)"
	@echo "test		-- reload and restart i3 with current ~/.i3/config"
	@echo ""


help_i3:
	@#cat "${I3CONFIG}" | egrep '(^(\s*)?##+ |^(\s*)?#  )'
	"$${__DOTFILES}/scripts/dotfiles-i3.sh"

test:
	i3-msg 'reload'
	i3-msg 'restart'

status:
	which i3
	which i3bar
	which i3status
	which i3lock
	which i3-msg
	which i3-nagbar
	i3 -v
	i3-msg -t get_version | python -mjson.tool
	i3-msg -t get_outputs | python -mjson.tool
	i3-msg -t get_workspaces | python -mjson.tool
	i3-msg -t get_tree | python -mjson.tool
	i3-msg -t get_marks | python -mjson.tool
	i3-msg -t get_bar_config | python -mjson.tool

