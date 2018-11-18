if [[ $commands[fzf] && $commands[fasd] ]]; then
	cd-fzf-widget() {
		local dir
		dir="$(fasd -Rdl "$1" | fzf-tmux -1 -0 --no-sort --height=16 --reverse --toggle-sort=ctrl-r)" && cd "${dir}"
		local ret=$?
		zle reset-prompt
  		typeset -f zle-line-init >/dev/null && zle zle-line-init
		return $ret
	}
	zle -N cd-fzf-widget
	bindkey '^j' cd-fzf-widget
fi
