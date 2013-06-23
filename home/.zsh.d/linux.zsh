if [[ "$OSTYPE" != darwin* ]]; then
  # Linux Specific Aliases
  if [[ -x xclip ]]; then
    alias pbc='xclip'
    alias pbp='xsel'
  fi
fi
