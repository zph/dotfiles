if which pyenv > /dev/null; then
  eval "$(pyenv init -)";
  export PYENV_ROOT="$HOME/.pyenv"
fi
