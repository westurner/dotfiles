#!/bin/zsh
# A wrapper around all the lesspipe implementations.

zmodload -F zsh/parameter +p:commands
zmodload -F zsh/zutil +b:zparseopts

function lesspipe {
	emulate -L zsh
	setopt err_return no_unset warn_create_global
	#setopt xtrace

	typeset -A args
	zparseopts -E -D -K -A args x

	if (( $+commands[lesspipe] )); then
		local lesspipe="$commands[lesspipe]"
	elif (( $+commands[lesspipe.sh] )); then
		local lesspipe="$commands[lesspipe.sh]"
	fi

	if (( $+lesspipe )); then
		if (( $+args[-x] )); then
			emulate -R zsh -c "$($lesspipe)" 2>/dev/null || :
			if ! (( $+LESSOPEN )); then
				typeset -gx LESSOPEN="|$lesspipe %s"
			fi
		else
			local LESSOPEN LESSCLOSE
			local lesspipe_output="$($lesspipe)"
			emulate -R zsh -c "$lesspipe_output" 2>/dev/null || :
			[[ -n $LESSOPEN ]] && local lesspipe_exports_var
			if (( $+lesspipe_exports_var )); then
				print "$lesspipe_output"
			else
				print "typeset -gx LESSOPEN=\"\|$lesspipe %s\""
			fi
		fi
	fi
}

lesspipe "$@"
