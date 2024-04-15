#!/usr/bin/env bash

set -eou pipefail

curl --silent --location \
    https://raw.githubusercontent.com/houseabsolute/ubi/master/bootstrap/bootstrap-ubi.sh |
    sh

mv ~/bin/ubi ~/bin_local/

export PATH=~/bin_local:$PATH

declare -a BINARIES=(
  therootcompany/pathman
)

for bin in "${BINARIES[@]}"; do
  ubi -p "$bin" --in ~/bin_local
done
