#!/bin/bash

add_to_hosts(){
  if [[ $(cat /etc/hosts | grep xen1) ]]; then
    echo "Hosts has already been modified"
  else
    sudo bash -c 'echo "38.109.219.145 xen1 # nrserver" >> /etc/hosts'
  fi
}
prepare_dir_for_vim(){
  if [[ -d "${HOME}/tmp" ]]; then
    echo "TEMPDIR Setup"
  else
    mkdir ~/tmp
    cd ~/tmp
  fi
  }

install_basics(){
  sudo apt-get -y install aptitude ruby tmux exuberant-ctags zsh vim-nox curl mosh
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
  sudo aptitude -y install build-essential openssl libreadline6 libreadline6-dev curl \ 
  git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev \ 
  libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion pkg-config;
  if [[ -d "${HOME}/.rvm" ]]; then
    echo "RVM already installed"
  else
    curl -L https://get.rvm.io | bash -s stable --ruby --gems=homesick,pry
  fi

  source ${HOME}/.rvm/scripts/rvm
}

download_dotfiles(){
  cd ~
  if [[ -d ~/dotfiles ]]; then
    git clone ssh://zander@xen1/home/zander/repos/dotfiles ~/dotfiles
    homesick symlink ~/dotfiles
    ln -s ~/dotfiles/home/bin ~/bin
  fi
}

download_private_dotfiles(){
  cd ~
  if [[ -d "~/dotfiles_private" ]]; then
    git clone ssh://zander@xen1/home/zander/repos/dotfiles_private ~/dotfiles_private
    homesick symlink ~/dotfiles_private
  fi
}

resource_zshrc(){
  source ~/.zshrc
}

setup_zsh(){
  # if [[ $SHELL =~ '/bin/zsh' ]]; then
  #   echo "ZSH already set"
  # else
    chsh -s /bin/zsh
    /bin/zsh
  # fi
}

prepare_dir_for_vim
install_basics
setup_zsh
download_dotfiles
resource_zshrc
install_rvm
install_fasd
resource_zshrc



