lazyload_init_asdf(){

  local CONFIGS=(/usr/local/opt/asdf $HOME/.asdf)
  for c in "${CONFIGS[@]}";do
    if [[ -d "$c" ]];then
      ASDF_DIR="$c"
    fi
  done

  local FILEPATHS=("$ASDF_DIR/asdf.sh" "$ASDF_DIR/completions/asdf.bash")

  for f in "${FILEPATHS[@]}";do
    if [[ -f "$f"  ]]; then
      source "$f"
    fi
  done

  zph/prepend_to_path "$ASDF_DIR/bin"
  zph/prepend_to_path "$ASDF_DIR/shims"
}
