# Setting filename to 00-fasd.zsh to help order
# the sourcing so that fasd doesn't overwrite
# my personal aliases
eval "$(fasd --init auto)"

alias v='f -e vim' # quick opening files with vim
alias m='f -e mplayerx' # quick opening files with mplayer
alias o='a -e xdg-open' # quick opening files with xdg-open
_FASD_BACKENDS="native viminfo"

