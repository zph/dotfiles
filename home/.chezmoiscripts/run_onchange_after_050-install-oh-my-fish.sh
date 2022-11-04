#!/usr/bin/env bash

set -eou pipefail

if [[ ! -d "$HOME/.local/share/omf" ]];then
  curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
fi
