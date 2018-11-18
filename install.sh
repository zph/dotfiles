#!/usr/bin/env bash

set -x

UNAME="$(uname -a)"
REPOS="$HOME/.homesick/repos"
DOTFILES="$REPOS/dotfiles"
HOMESICK="$REPOS/homeshick/bin/homeshick"
REPO="git@github.com:zph/zph.git"

case "$UNAME" in
  Darwin)
    OS="osx";;
  Linux)
    OS="linux";;
  FreeBSD)
    OS="freebsd";;
esac

main() {
  if [[ ! -d "${DOTFILES}" ]];then
    git clone "${REPO}" "${DOTFILES}"
  fi

  if [[ ! -d "$HOME/.homesick/repos/homeshick" ]];then
    git clone git://github.com/andsens/homeshick.git "$HOME/.homesick/repos/homeshick"
  fi

  $HOMESICK link "${DOTFILES}"

  TO_LINK=(Library/KeyBindings/DefaultKeyBinding.dict \
           .config/brewfile \
           .config/karabiner \
           )

  (
    cd "$DOTFILES/home" || exit 1
    for link in "${TO_LINK[@]}"; do
      ln -s "$DOTFILES/$link" "$HOME/$link"
    done
  )

  bash "${DOTFILES}/linker.sh"

  case $OS in
    osx)
      brew bundle --file="${DOTFILES}/home/.config/brewfile/Brewfile"
      ;;
    *)
      echo "Unsupported OS for easy install, please review $DOTFILES/home/.config/brewfile/Brewfile"
  esac
}

main "$@"
