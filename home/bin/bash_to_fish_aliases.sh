#!/usr/bin/env bash

set -CEeuo pipefail
IFS=$'\n\t'
shopt -s extdebug

main() {
  local filename="$1"

  # Convert aliases from bash to fish using quick and dirty methods
  # shellcheck disable=SC2016
  grep alias "$filename" | grep -v "__" | grep -v "^#" | tr "=" " " | sed 's/\$(/(/g'
}

main "$1"
