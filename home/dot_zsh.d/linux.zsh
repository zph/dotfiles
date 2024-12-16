if [[ "$OSTYPE" != darwin* ]]; then
  # Linux Specific Aliases
  if ! command -v pbcopy >/dev/null; then
    if command -v xsel >/dev/null; then
      alias pbcopy='xsel --clipboard --input'
      alias pbpaste='xsel --clipboard --output'
    fi
  fi
fi
