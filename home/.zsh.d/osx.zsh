# Mac OS
if [[ "$OSTYPE" == darwin* ]]; then
  # OSX Hack for recompiling Ruby using gnu-gcc rather than clang
  # export CC=/usr/local/bin/gcc-4.2

  # OSX Specific Aliases
  # if [[ -e `which mvim` ]]; then
  #   # Use macvim if installed due to prefering those compilation options
  #   alias vim="mvim -v"
  # fi

  # turn off Startup sound
  # sudo nvram SystemAudioVolume=" "
  #
  alias pbc='pbcopy'
  alias pbp='pbpaste'

  alias trash_empty='rm -rf ~/.Trash/*'

  alias dsstore_rm='sudo find / -name ".DS_Store" -depth -exec rm {} \;'

  function system_urls(){
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -dump | \
      egrep "(bindings.*\:$)" | sort
}

  function dash() {
    open dash://$@
}

  alias o='open'
  alias get='curl --continue-at - --location --progress-bar --remote-name --remote-time'
  alias slimit='pbpaste| html2slim | pbcopy'
  export PATH=$HOME/Library/Python/2.7/bin:$PATH
else
  alias o='xdg-open'
  alias get='wget --continue --progress=bar --timestamping'
fi
