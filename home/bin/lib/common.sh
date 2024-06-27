#!/usr/bin/env bash

readonly BIN_LIB_DIR="$HOME/bin/lib"

source $BIN_LIB_DIR/colors

if [[ $(uname) == "Darwin" ]]; then
    sedf() { command sed -l "$@"; }
else
    sedf() { command sed -u "$@"; }
fi

# Thanks AWS for using \r instead of the canonical linux/macism of \n!
indent() {
  tr "\r" "\n" | sedf "s/^/       /"
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

success(){
  echo -e "${green}${*}${coloroff}"
}

# Credit LunarVim install script
function msg() {
  local text="$1"
  local div_width="80"
  printf "%${div_width}s\n" ' ' | tr ' ' -
  printf "%s\n" "$text"
}

# Credit LunarVim install script
function confirm() {
  local question="$1"
  while true; do
    msg "$question"
    read -p "[y]es or [n]o (default: no) : " -r answer
    case "$answer" in
      y | Y | yes | YES | Yes)
        return 0
        ;;
      n | N | no | NO | No | *[[:blank:]]* | "")
        return 1
        ;;
      *)
        msg "Please answer [y]es or [n]o."
        ;;
    esac
  done
}
