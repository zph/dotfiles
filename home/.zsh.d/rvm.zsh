[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"

# Fix for Tmux and RVM not playing nicely
cd .. && cd - && clear # THANKS TMUX! http://stackoverflow.com/a/18659068

function rvm_installation(){
  \curl -L https://get.rvm.io | bash -s stable --ruby
}

# Not sure if it's a good idea, but...
# PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
