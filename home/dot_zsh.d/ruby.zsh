alias bpr='bundle exec pry-remote'
alias approve='bundle exec approvals verify -d vimdiff -a'
##############################
# Courtesy of http://ryan.mcgeary.org/2011/02/09/vendor-everything-still-applies/
# alias bi="b install --path vendor"
# alias bi="nocorrect bundle install --binstubs=./.bundle/.binstubs --path vendor"
alias bi="nocorrect bundle install --binstubs=./.bundle/.binstubs"
# alias b="b"
# alias bundle="bu"
# alias bil="bi --local"
alias bu="bundle update"
alias be="bundle exec"
alias binit="bi && b package && echo 'vendor/ruby' >> .gitignore"
##############################
# alias rake="run_bundler_cmd rake"
# alias rspec="run_bundler_cmd rspec"
alias rspecc="run_bundler_cmd \rspec $CURRENT_SPEC"
alias rspc=rspecc

alias ruby="run_bundler_cmd ruby"

function run_bundler_cmd (){
  if [ -e ./Gemfile ]; then
    # echo "bundle exec $@";
    bundle exec $@;
  else
    # echo "$@";
    $@;
  fi
}

function gem_reinstall(){
  gem uninstall $1
  gem install $1
}

# Rails
alias r='rails'
# alias rake='noglob rake'
# alias R='noglob rake'
compdef R=rake

# http://samsaffron.com/archive/2013/05/03/eliminating-my-trivial-inconveniences
export RUBY_GC_MALLOC_LIMIT=1000000000
export RUBY_HEAP_SLOTS_GROWTH_FACTOR=1.25
# https://gist.github.com/carols10cents/6445611
# I found I was typing these commands wayyy too much:
alias rt="bundle exec rake test TEST="
alias pry_console="bundle exec pry --gem"

# I often use the tab completion on the filename, though.
# The following lets me do:
# $ rti some_integration_test.rb
# $ rtu example_unit_test.rb
# With tab completion on the filenames.
# This guide was awesome in figuring this out: http://devmanual.gentoo.org/tasks-reference/completion/index.html

# _integration(){
#   local cur=${COMP_WORDS[COMP_CWORD]}
#   COMPREPLY=( $(compgen -W "$(find spec/**/*.rb)" -- $cur) )
# }
# complete -F _integration rt
