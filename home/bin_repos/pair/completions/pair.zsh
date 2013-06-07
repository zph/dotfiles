if [[ ! -o interactive ]]; then
    return
fi

compctl -K _pair pair

_pair() {
  local word words completions
  read -cA words
  word="${words[2]}"

  if [ "${#words}" -eq 2 ]; then
    completions="$(pair commands)"
  else
    completions="$(pair completions "${word}")"
  fi

  reply=("${(ps:\n:)completions}")
}
