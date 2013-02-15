#!/bin/sh

# From Destroy All Software's Async Test Running
# Credits to Gary Bernhardt
pipe="test-commands"

trap "rm -f $pipe" EXIT

if [ ! -p $pipe ]; then
  mkfifo $pipe
fi

while true; do
  sh -c "$(cat $pipe)"
done
