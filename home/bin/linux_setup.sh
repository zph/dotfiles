#!/bin/sh


prepare_dir_for_vim(){
  mkdir ~/.tmp
  cd ~/.tmp
}

install_basics(){
  sudo apt-get install ruby tmux exuberant-ctags zsh vim-nox curl
}

install_fasd(){
  git clone https://github.com/clvv/fasd.git
  cd fasd && sudo make install
  cd .. && rm -rf fasd/
}

install_rvm(){
  sudo apt-get install build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion pkg-config \
  && curl -L https://get.rvm.io | bash -s stable --ruby
}

setup_zsh(){
  chsh -s /bin/zsh
  /bin/zsh
}

prepare_dir_for_vim
install_basics
install_rvm
install_fasd
setup_zsh
