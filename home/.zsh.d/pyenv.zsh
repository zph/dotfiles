lazyload_init_pyenv(){
  eval "$(pyenv init -)";
  export PYENV_ROOT="$HOME/.pyenv"
}
