#!/usr/bin/env bash

readonly BIN_LIB_DIR="$HOME/bin/lib"

source $BIN_LIB_DIR/colors

if [[ $(uname) == "Darwin" ]]; then
    sedf() { command sed -l "$@"; }
else
    sedf() { command sed -u "$@"; }
fi

indent() {
  sedf "s/^/       /"
}

tolower() {
    echo "$@" | tr "[:upper:]" "[:lower:]"
}

header(){
  echo "-----> $1"
}

warn(){
  echo -e "${red}${*}${coloroff}"
}
