#!/usr/bin/env bash

set -CEeuo pipefail
IFS=$'\n\t'
shopt -s extdebug

REPOS="$HOME/.homesick/repos"
DOTFILES="$REPOS/dotfiles"
HOMESICK="$REPOS/homeshick/bin/homeshick"
# Use the https version to avoid needing git key at install stage
REPO="https://github.com/zph/zph.git"
OPT_FOLDER="$DOTFILES/home/opt"

OS="$(uname -a | awk '{print tolower($1)}')"

install_gifwit(){
  # No longer on app store and dev was non-responsive when I emailed :(.
  # Happy to replace this with official mechanism.
  APPS=(https://data.xargs.io/gifwit.tgz)
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
  # TODO: Experimental exclusion to see if I need to still manually symlink
  # these.
  # TO_LINK=(Library/KeyBindings/DefaultKeyBinding.dict \
  #          .config/brewfile \
  #          .config/karabiner \
  #          )

  # (
  #   cd "$DOTFILES/home" || exit 1
  #   for link in "${TO_LINK[@]}"; do
  #     ln -fs "$DOTFILES/$link" "$HOME/$link"
  #   done
  # )

  if [[ ! -x "$(command -v brew)" ]];then
    # TODO: no longer works on non-interactive tty
    # Perhaps I can fix with running bash interactive?
    # Workaround, execute the brew install separately and then continue install
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  brew bundle --file="${DOTFILES}/home/.config/brewfile/Brewfile"
  # install_gifwit
  sudo "${DOTFILES}/home/.config/tmutil/setup-exclusions"
  # Install Tmux Package Manager
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  sudo bash "${DOTFILES}/home/.osx"

  if [[ ! -x "$(command -v asdf)" ]];then
    # Setup ASDF Plugins
    asdf plugin-add golang https://github.com/kennyp/asdf-golang.git
    asdf plugin-add terraform https://github.com/Banno/asdf-hashicorp.git
  fi
}

main() {
  if [[ ! -d "$HOME/.homesick/repos/homeshick" ]];then
    git clone https://github.com/andsens/homeshick.git "$HOME/.homesick/repos/homeshick"
  fi

  if [[ ! -d "${DOTFILES}" ]];then
    git clone "${REPO}" "${DOTFILES}"
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
