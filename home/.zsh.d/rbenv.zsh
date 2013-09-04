if [[ -x `which rbenv` ]]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
  # Abbreviation for "gem install".
  gi() { gem install $@; rbenv rehash; rehash }

  alias rb=rbenv
fi
