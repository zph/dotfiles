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

# Disable fish greeting
set fish_greeting

if test ! -f $HOME/.zsh_env
  update_zsh_vars
end

set ENVVARS EDITOR
set MANPATH ""

for var in $ENVVARS
  set value (cat ~/.zsh_env  | grep "^$var" | xargs)
  export "$value"
end

# Will break on equal sign
set ZSH_PATH (cat ~/.zsh_env | grep "^PATH=" | awk -F'=' '{print $2}')
# Note reverse to make this apply older ones first (keeps useful order)
for path in (string split ':' $ZSH_PATH | tail -r)
  set PATH $path $PATH
end

set PAGER (which bat)

set EDITOR (which nvim)
alias vim $EDITOR
alias edit $EDITOR
alias gs 'git status -s'
zoxide init fish | source
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
# source  /usr/local/opt/chruby-fish/share/chruby/chruby.fish
# source  /usr/local/opt/chruby-fish/share/chruby/auto.fish
# Ruby

function run_bundler_cmd
  if test -e ./Gemfile
    bundle exec $argv;
  else
    $argv;
  end
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
# set -g fish_user_paths "/usr/local/opt/ruby/bin" $fish_user_paths
# source (brew --prefix asdf)/libexec/asdf.fish

starship init fish | source

# https://fishshell.com/docs/current/cmds/fish_add_path.html
# prepend, move if currently in path, -g is like export
fish_add_path -g -m -p (brew --prefix)/bin
fish_add_path -g -m -p '/usr/local/bin'
fish_add_path -g -m -p /nix/var/nix/profiles/default/bin
fish_add_path -g -m -p $HOME/.nix-profile/bin
fish_add_path -g -m -p $HOME/.deno/bin
fish_add_path -g -m -p $HOME/.cargo/bin
fish_add_path -g -m -p $HOME/.local/bin
fish_add_path -g -m -p $HOME/.hermit/bin
fish_add_path -g -m -p $HOME/bin
alias c='chezmoi'

# https://docs.atuin.sh/configuration/key-binding/
set -gx ATUIN_NOBIND "false"
atuin init fish | source

# bind to ctrl-r in normal and insert mode, add any other bindings you want here too
bind \cr _atuin_search
bind -M insert \cr _atuin_search

bind \cv edit_command_buffer

~/.local/bin/mise activate fish | source
