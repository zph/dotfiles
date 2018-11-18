# Issue, does not move ASDF to front of $PATH
# so /usr/local/bin/erl will be used despite the asdf shim
source $HOME/.asdf/asdf.sh
source $HOME/.asdf/completions/asdf.bash

zph/prepend_to_path "$HOME/.asdf/bin"
zph/prepend_to_path "$HOME/.asdf/shims"
