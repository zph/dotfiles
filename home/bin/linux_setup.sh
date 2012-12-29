#!/bin/sh


prepare_dir_for_vim(){
  mkdir ~/.tmp
  cd ~/.tmp
}

install_basics(){
  sudo apt-get -y install aptitude ruby tmux exuberant-ctags zsh vim-nox curl
}

install_fasd(){
  if [[ -x $(which fasd) ]]; then
    echo "FASD already installed"
  else
    git clone https://github.com/clvv/fasd.git
    cd fasd && sudo make install
    cd .. && rm -rf fasd/
  fi
}

install_rvm(){
  sudo apt-get -y install build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion pkg-config \
  && curl -L https://get.rvm.io | bash -s stable --ruby
}

setup_zsh(){
  if [[ $SHELL =~ 'zsh' ]]; then
    echo "ZSH already set"
  else
    chsh -s /bin/zsh
    /bin/zsh
  fi
}

prepare_dir_for_vim
install_basics
install_rvm
install_fasd
setup_zsh
