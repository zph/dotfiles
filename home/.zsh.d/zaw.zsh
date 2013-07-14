source ${HOME}/bin_repos/zaw/zaw.zsh
bindkey '^R' zaw-history
# bindkey -M filterselect '^R' down-line-or-history
# bindkey -M filterselect '^S' up-line-or-history
# bindkey -M filterselect '^E' accept-search

zstyle ':filter-select:highlight' matched fg=green
zstyle ':filter-select' max-lines 6
zstyle ':filter-select' case-insensitive yes # enable case-insensitive
zstyle ':filter-select' extended-search yes # see below
