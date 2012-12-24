[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function

function rvm_installation(){
  \curl -L https://get.rvm.io | bash -s stable --ruby
}
