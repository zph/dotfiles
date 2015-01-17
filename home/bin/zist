#!/usr/bin/env bash

source ~/.zsh.d/chruby.zsh
set -eo pipefail

readonly FILE=$1
readonly STARTING_DIR=$(pwd)

cd ~/src/zist && \
  source .envrc && \
  bundle exec ruby bin/zist "$FILE" "$STARTING_DIR"
