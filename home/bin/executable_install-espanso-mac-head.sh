#!/usr/bin/env bash

set -eou pipefail

set -x

# https://espanso.org/docs/install/mac/
# Note: these instructions changed from v0.7.0 to v2.x
# Docs on 20211212 reflect the v0.7.0.
VERSION="v2.1.1-alpha"
WORKSPACE="$(mktemp -d)"

trap "rm -rf $WORKSPACE" EXIT

(
  # Install espanso via homebrew, then overwrite it.
  # Reasoning: we need modulo dependency binaries installed
  curl -sOL "https://github.com/federico-terzi/espanso/releases/download/$VERSION/Espanso-Mac-Intel.zip"
  tar -xzvf Espanso-Mac-Intel.zip -C "$WORKSPACE"
  mv "$WORKSPACE/Espanso.app" "$HOME/Applications/"
)
