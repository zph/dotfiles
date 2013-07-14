# Mac OS X
if [[ "$OSTYPE" == darwin* ]]; then
  alias o='open'
  alias get='curl --continue-at - --location --progress-bar --remote-name --remote-time'
else
  alias o='xdg-open'
  alias get='wget --continue --progress=bar --timestamping'
fi

if [[ "$OSTYPE" == darwin* ]]; then
  # OSX Hack for recompiling Ruby using gnu-gcc rather than clang
  # export CC=/usr/local/bin/gcc-4.2

  # OSX Specific Aliases
  alias pbc='pbcopy'
  alias pbp='pbpaste'

  alias trash_empty='rm -rf ~/.Trash/*'

  alias dsstore_rm='sudo find / -name ".DS_Store" -depth -exec rm {} \;'
  function system_urls(){
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -dump |
    egrep "(bindings.*\:$)" | sort
}

  function dash() {
    open dash://$@
}

fi
