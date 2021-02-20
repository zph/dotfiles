#!/usr/bin/env bash

set -CEeuo pipefail
IFS=$'\n\t'
shopt -s extdebug

REPOS="$HOME/.homesick/repos"
DOTFILES="$REPOS/dotfiles"
HOMESICK="$REPOS/homeshick/bin/homeshick"
REPO="git@github.com:zph/zph.git"
OPT_FOLDER="$DOTFILES/home/opt"

OS="$(uname -a | awk '{print tolower($1)}')"

install_gifwit(){
  # No longer on app store and dev was non-responsive when I emailed :(.
  # Happy to replace this with official mechanism.
  APPS=(http://data.xargs.io/gifwit.tgz https://blog.timac.org/2018/0719-vpnstatus/VPNStatus.app.zip)
  for app in "${APPS[@]}";do
    tmpdir="$(mktemp -d)"
    remove_temp() {
      rm -rf "$tmpdir"
    }
    trap remove_temp EXIT

    (
      cd $"tmpdir "|| exit 1
      wget "$app"
      case "$app" in
        *.zip)
          unzip ./*.zip ;;
        *.tgz)
          tar -xvf ./*.tgz ;;
          *) exit 1
      esac
      rm -rf ./*.tgz ./*.zip
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
  TO_LINK=(Library/KeyBindings/DefaultKeyBinding.dict \
           .config/brewfile \
           .config/karabiner \
           )

  (
    cd "$DOTFILES/home" || exit 1
    for link in "${TO_LINK[@]}"; do
      ln -fsi "$DOTFILES/$link" "$HOME/$link"
    done
  )

  if [[ ! -x "$(command -v brew)" ]];then
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

  BINARY_INSTALLS=(sharkdp/bat github/hub stedolan/jq)

# TODO: Requires wget and kit
#  for b in "${BINARY_INSTALLS[@]}"; do
#    "$HOME/bin_local/kit" --install "$b" --output "$HOME/bin_local"
#  done

  if [[ ! -d "$HOME/.homesick/repos/homeshick" ]];then
    git clone git://github.com/andsens/homeshick.git "$HOME/.homesick/repos/homeshick"
  fi

  $HOMESICK link "dotfiles"

  # For neovim location
  # --symlink --interactive to prompt in case of conflict
  ln -si ~/.vim ~/.config/nvim

  case $OS in
    darwin)
      install_osx_packages
      ;;
    *)
      echo "Unsupported OS for easy install, please review $DOTFILES/home/.config/brewfile/Brewfile"
  esac

  setup_opt_using_stow
}

main "$@"
