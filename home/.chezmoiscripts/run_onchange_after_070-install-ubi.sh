#!/usr/bin/env bash

set -eou pipefail
set -x

curl --silent --location \
    https://raw.githubusercontent.com/houseabsolute/ubi/master/bootstrap/bootstrap-ubi.sh |
    sh

mv ~/bin/ubi ~/bin_local/

export PATH=~/bin_local:$PATH

declare -a BINARIES=()

for bin in "${BINARIES[@]}"; do
  ubi -p "$bin" --in ~/bin_local
done

# Special case
ubi -p therootcompany/pathman -d -i ~/bin_local --tag v0.6.0 --exe pathman-v0.6.0-darwin-arm64
# Workaround because of naming of binary inside tgz
mv ~/bin_local/pathman-v0.6.0-darwin-arm64 ~/bin_local/pathman
