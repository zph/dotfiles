alias bi='bundle install'
alias be='bundle exec'
alias ri='ri -f ansi'
alias gemu='gem uninstall'
function gemul(){
  gem uninstall --executables $1
  rake install
}
function gem_reinstall(){
  gem uninstall $1
  gem install $1
}

# Rails
alias r='rails'
alias rake='noglob rake'
alias R='noglob rake'

# Homesick symlinking on OSX
alias homesick_refresh='homesick symlink ~/Dropbox/dotfiles'
homesick_add(){
# Not sure how to do it yet, or if advisable to automate
}

export BUFFER_DEBUG=true
