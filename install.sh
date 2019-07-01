#!/usr/bin/env bash

set -eou pipefail
set -x

UNAME="$(uname -a)"
REPOS="$HOME/.homesick/repos"
DOTFILES="$REPOS/dotfiles"
HOMESICK="$REPOS/homeshick/bin/homeshick"
REPO="git@github.com:zph/zph.git"
OPT_FOLDER="$DOTFILES/home/opt"

case "$(uname)" in
  Darwin)
    OS="osx";;
  Linux)
    OS="linux";;
  FreeBSD)
    OS="freebsd";;
esac

install_gifwit(){
  # No longer on app store and dev was non-responsive when I emailed :(.
  # Happy to replace this with official mechanism.
  APPS=(http://data.xargs.io/gifwit.tgz)
  for app in "${APPS[@]}";do
    tmpdir="$(mktemp -d)"
    remove_temp() {
      rm -rf "$tmpdir"
    }
    trap remove_temp EXIT

    (
      cd $"tmpdir "|| exit 1
      wget "$app"
      rm -rf ./*.tgz
      mv ./* ~/Applications/
    )

  done
}

setup_opt_using_stow(){
  for full_path in $(find "${OPT_FOLDER}" -type d -maxdepth 1 | grep -v "/opt$");do
    local folder
    folder="$(basename "$full_path")"
    stow --verbose=3 -d "$OPT_FOLDER" --target "$HOME" "$folder"
  done
}

install_osx_packages(){
  # TODO: check if brew is installed, if not, install it.
  if [[ ! -x "$(which brew)" ]];then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi

  brew bundle --file="${DOTFILES}/home/.config/brewfile/Brewfile"
  install_gifwit
  sudo "${DOTFILES}/home/.config/tmutil/setup-exclusions"
  # Install Tmux Package Manager
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

main() {
  if [[ ! -d "${DOTFILES}" ]];then
    git clone "${REPO}" "${DOTFILES}"
  fi

  wget --content-disposition https://bin.suyash.io/zph/kit -O ~/bin_local/kit && \
    chmod +x ~/bin_local/kit

  if [[ ! -d "$HOME/.homesick/repos/homeshick" ]];then
    git clone git://github.com/andsens/homeshick.git "$HOME/.homesick/repos/homeshick"
  fi

  $HOMESICK link "dotfiles"

  TO_LINK=(Library/KeyBindings/DefaultKeyBinding.dict \
           .config/brewfile \
           .config/karabiner \
           )

  # For neovim location
  # --symlink --interactive to prompt in case of conflict
  ln -si ~/.vim ~/.config/nvim

  (
    cd "$DOTFILES/home" || exit 1
    for link in "${TO_LINK[@]}"; do
      ln -si "$DOTFILES/$link" "$HOME/$link"
    done
  )

  case $OS in
    osx)
      install_osx_packages
      ;;
    *)
      echo "Unsupported OS for easy install, please review $DOTFILES/home/.config/brewfile/Brewfile"
  esac

  setup_opt_using_stow
}

main "$@"
