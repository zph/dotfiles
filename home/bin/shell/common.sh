#!/usr/bin/env bash

# Indent and Darwin sedf taken from:
# https://github.com/paxan/heroku-buildpack-gb/blob/master/bin/compile#L4-L18
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

