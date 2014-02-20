if [[ "$OSTYPE" != darwin* ]]; then
  # Linux Specific Aliases
  if ! which pbcopy >/dev/null && which xsel >/dev/null; then
    alias pbcopy='xsel --clipboard --input'
    alias pbpaste='xsel --clipboard --output'
  fi
  # if [[ -x xclip ]]; then

  #   alias pbc='xclip'
  #   alias pbp='xsel'
  # fi
fi
