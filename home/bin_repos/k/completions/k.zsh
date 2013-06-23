if [[ ! -o interactive ]]; then
    return
fi

compctl -K _k k

_k() {
  local word words completions
  read -cA words
  word="${words[2]}"

  if [ "${#words}" -eq 2 ]; then
    completions="$(k commands)"
  else
    completions="$(k completions "${word}")"
  fi

  reply=("${(ps:\n:)completions}")
}
