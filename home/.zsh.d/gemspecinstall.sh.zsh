# Source: https://gist.github.com/ed6423a598b2c0c2a0e9
# Mike, 

# I hope that you find the following useful as it 
# sounds like this is a common task for you.

# Place this in your ~/.bash_profile or shell 'dotfiles' 
# Or simply paste it into the terminal you want to use it in

gemspecinstall() {
  # Install Bundler, w00t!!!
  gem install bundler --pre
  # Create a Gemfile to build the gem from the gemspec.
  printf "source :rubygems\ngemspec :path => '.'\n" > Gemfile
  # Install Z gem!
  bundle install
}

# or gembundle or whatever name makes sense :)
sandboxbundle() {
  # Create a gemset for the current directory (gem) name 
  # under the currently selected (RVM) Ruby, optional.
  rvm --create use "${rvm_ruby_string}@$(basename $(pwd))"
  gemspecinstall
  # Scratch that itch!
  rake
}


# Then to use it from the directory you cloned a gem into:
# sandboxbundle

# If you only want to install the gem to the current 
# environment istead of sandboxed, from the cloned gem root:
# gemspecinstall


# Enjoy!!!
#   ~Wayne Sequin
