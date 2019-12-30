lazyload_init_pyenv(){
  eval "$(pyenv init -)";
  export PYENV_ROOT="$HOME/.pyenv"
}

export SDKROOT="/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
