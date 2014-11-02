source "${HOME}/.zsh.d/antigen/antigen.zsh"

# set -x
IFS=$'\n'

plugins=(
  zsh-users/zsh-syntax-highlighting
  zsh-users/zsh-history-substring-search
  mosh
  urltools
  # rake-fast
)

for cmd in $plugins; do
  antigen bundle "$cmd"
done

antigen bundle zsh-users/zsh-completions src

# For SSH, starting ssh-agent is annoying
antigen bundle ssh-agent

# Node Plugins
antigen bundle coffee
# antigen bundle node
# antigen bundle npm

# OS specific plugins
if [[ $CURRENT_OS == 'OS X' ]]; then
    antigen bundle brew
    antigen bundle brew-cask
    antigen bundle gem
    antigen bundle osx
elif [[ $CURRENT_OS == 'Linux' ]]; then
    # None so far...
    if [[ $DISTRO == 'CentOS' ]]; then
        antigen bundle centos
    fi
elif [[ $CURRENT_OS == 'Cygwin' ]]; then
    antigen bundle cygwin
fi

# Secret info
# TODO: add feature
# antigen bundle git@github.com:jdavis/secret.git

antigen apply

# history-substring-search
zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

# bind P and N for EMACS mode
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down

# bind k and j for VI mode
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
