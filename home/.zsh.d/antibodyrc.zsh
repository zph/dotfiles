if [[ -x antibody ]];then
  source <(antibody init)

  #  set -x
  IFS=$'\n'

  plugins=(
    zsh-users/zsh-syntax-highlighting
    zsh-users/zsh-history-substring-search
    mosh
    urltools
    ael-code/zsh-plugin-fasd-fzf
  )

  for cmd in $plugins; do
    antibody bundle "$cmd"
  done

  # antibody bundle zsh-users/zsh-completions src

  # For SSH, starting ssh-agent is annoying
  antibody bundle ssh-agent

  # Node Plugins
  # antibody bundle node
  # antibody bundle npm

  # OS specific plugins
  if [[ $CURRENT_OS == 'OS X' ]]; then
      antibody bundle brew
      antibody bundle brew-cask
      antibody bundle gem
      antibody bundle osx
  elif [[ $CURRENT_OS == 'Linux' ]]; then
      # None so far...
      if [[ $DISTRO == 'CentOS' ]]; then
          antibody bundle centos
      fi
  elif [[ $CURRENT_OS == 'Cygwin' ]]; then
      antibody bundle cygwin
  fi

  # Secret info
  # TODO: add feature
  # antibody bundle git@github.com:jdavis/secret.git

  antibody apply

  # # history-substring-search
  # zmodload zsh/terminfo
  # bindkey "$terminfo[kcuu1]" history-substring-search-up
  # bindkey "$terminfo[kcud1]" history-substring-search-down

  # # bind P and N for EMACS mode
  # bindkey -M emacs '^P' history-substring-search-up
  # bindkey -M emacs '^N' history-substring-search-down

  # # bind k and j for VI mode
  # bindkey -M vicmd 'k' history-substring-search-up
  # bindkey -M vicmd 'j' history-substring-search-down
fi
