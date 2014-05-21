#!/bin/zsh
# bash_source -- load bash scripts with zsh options

emulate -R zsh -c 'autoload -Uz is-at-least'
if is-at-least 5.0.0; then
	emulate -R sh -o kshglob +o shglob +o ignorebraces -o bash_rematch -c '
		function bash_source {
			source "$@"
		}
	'
else
	emulate -R sh -c '
		function bash_source {
			# Do note that functions about to be defined will not be set
			# with these options when run
			setopt kshglob noshglob braceexpand bash_rematch
			source "$@"
		}
	'
fi

# usage::
#   bash_source "$@"
