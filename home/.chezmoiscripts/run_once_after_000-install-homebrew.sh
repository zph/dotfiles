#!/usr/bin/env bash

set -eou pipefail

if [[ ! -x "$(command -v brew)" ]];then
  # TODO: no longer works on non-interactive tty
  # Perhaps I can fix with running bash interactive?
  # Workaround, execute the brew install separately and then continue install
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
