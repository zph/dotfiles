#!/usr/bin/env bash

set -x

REPO="$HOME/dotfiles"
echo "Linking specific files"

TO_LINK=(Library/KeyBindings/DefaultKeyBinding.dict \
         .config/brewfile \
         .config/karabiner \
         )

(
  cd "$REPO/home" || exit 1
  for link in "${TO_LINK[@]}"; do
    ln -s "$REPO/$link" "$HOME/$link"
  done
)
