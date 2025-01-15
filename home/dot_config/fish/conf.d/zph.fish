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

alias vim='nvim'

starship init fish | source

alias c='chezmoi'

# https://docs.atuin.sh/configuration/key-binding/
set -gx ATUIN_NOBIND "false"
atuin init fish | source

# bind to ctrl-r in normal and insert mode, add any other bindings you want here too
bind \cr _atuin_search
bind -M insert \cr _atuin_search

bind \cv edit_command_buffer

# Git worktree add + cd
function gwa -d "Git worktree add and then cd into folder"
  git worktree-add $argv
  # Expecting the folder name to be first, may be brittle
  cd $argv[1]
end

mise activate fish | source
