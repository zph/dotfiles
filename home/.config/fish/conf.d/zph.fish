# Probably super slow :P
# TODO: cache this
# set PATH (zsh -c 'source ~/.zshrc && echo $PATH | tr ":" " "') $PATH
# if true # TODO older than 1 hour
# if find $HOME -iname ".*" -mtime +0h01m -maxdepth 1 | grep $HOME/.zsh_env > /dev/null
#   set zsh_env (zsh -c 'source ~/.zshrc && env > ~/.zsh_env')
# end

function update_zsh_vars
  zsh -c 'source ~/.zshrc && env > ~/.zsh_env'
end

# if not -f $HOME/.zsh_env
#   update_zsh_vars
# end

set ENVVARS EDITOR
set MANPATH ""

for var in $ENVVARS
  set value (cat ~/.zsh_env  | grep "^$var" | xargs)
  export "$value"
end

set ZSH_PATH (cat ~/.zsh_env | grep "^PATH=" | awk -F= '{print $2}')
# Note reverse to make this apply older ones first (keeps useful order)
for path in (string split ':' $ZSH_PATH | tail -r)
  set PATH $path $PATH
end

# Rust
set PATH $HOME/.cargo/bin $PATH
set PAGER /usr/local/bin/bat

set EDITOR "/usr/local/bin/nvim"
alias vim $EDITOR
alias gs 'git status -s'
alias wk 'cd ~/src/worktree'
alias dc 'docker-compose'

if not functions -q fisher
  set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
  curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
  fish -c fisher
end

$HOME/bin/sack init_fish | source
direnv hook fish | source

# Requires chruby-fish from brew
source  /usr/local/opt/chruby-fish/share/chruby/chruby.fish
source  /usr/local/opt/chruby-fish/share/chruby/auto.fish
# Ruby

function run_bundler_cmd
  if test -e ./Gemfile
    bundle exec $argv;
  else
    $argv;
  end
end

if test -x (command -v mmake)
  alias make='mmake'
end

alias vim='nvim'
# __bash_to_fish
# if ! string split ',' (functions) | grep __bash_to_fish
#   aliases_bash_to_fish "$HOME/.zsh.d" | source
# end

# If having complaints about bashdb-main.inc
# Create the base dir
# mkdir /usr/local/Cellar/bash/5.0.7/share/bashdb
# touch /usr/local/Cellar/bash/5.0.7/share/bashdb/bashdb-main.inc
set -g fish_user_paths "/usr/local/opt/ruby/bin" $fish_user_paths
source (brew --prefix asdf)/asdf.fish

starship init fish | source
