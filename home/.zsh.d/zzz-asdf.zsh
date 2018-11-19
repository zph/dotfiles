# Issue, does not move ASDF to front of $PATH
# so /usr/local/bin/erl will be used despite the asdf shim

if [[ -d $HOME/.asdf ]];then
  ASDF_DIR="$HOME/.asdf"
elif [[ -d /usr/local/opt/asdf ]];then
  ASDF_DIR="/usr/local/opt/asdf"
fi

if [[ -f  $ASDF_DIR/asdf.sh ]]; then
  source $ASDF_DIR/asdf.sh
fi

if [[ -f  $ASDF_DIR/completions/asdf.bash ]]; then
  source $ASDF_DIR/completions/asdf.bash
fi

zph/prepend_to_path "$ASDF_DIR/bin"
zph/prepend_to_path "$ASDF_DIR/shims"
