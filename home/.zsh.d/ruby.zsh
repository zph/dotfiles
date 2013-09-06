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
compdef R=rake

# Homesick symlinking on OSX
alias homesick_refresh='homesick symlink ~/Dropbox/dotfiles'
homesick_add(){
# Not sure how to do it yet, or if advisable to automate
}

export BUFFER_DEBUG=true

# https://gist.github.com/carols10cents/6445611
# I found I was typing these commands wayyy too much:
alias rt="rake test TEST="
# I often use the tab completion on the filename, though.
# The following lets me do:
# $ rti some_integration_test.rb
# $ rtu example_unit_test.rb
# With tab completion on the filenames.
# This guide was awesome in figuring this out: http://devmanual.gentoo.org/tasks-reference/completion/index.html

_integration(){
  local cur=${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( $(compgen -W "$(find spec/**/*.rb)" -- $cur) )
}
complete -F _integration rt
