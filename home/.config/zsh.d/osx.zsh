# Mac OS X
if [[ "$OSTYPE" == darwin* ]]; then
  alias o='open'
  alias get='curl --continue-at - --location --progress-bar --remote-name --remote-time'
else
  alias o='xdg-open'
  alias get='wget --continue --progress=bar --timestamping'
fi

alias pbc='pbcopy'
alias pbp='pbpaste'

alias trash_empty='rm -rf ~/.Trash/*'

alias dsstore_rm='sudo find / -name ".DS_Store" -depth -exec rm {} \;'
