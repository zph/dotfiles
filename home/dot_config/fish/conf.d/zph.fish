alias vim $EDITOR
alias edit $EDITOR
alias gs 'git status -s'
alias wk 'cd ~/src/worktree'
alias dc 'docker-compose'
alias vim='nvim'
alias c='chezmoi'

if not functions -q fisher
  set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
  curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
  fish -c fisher
end

# Cache helper for *init commands (saves ~150ms on startup)
function __cached_init -a cmd_name cmd_path
  set -l cache_dir "$HOME/tmp/fish_init_cache"
  test -d $cache_dir; or mkdir -p $cache_dir

  set -l cache_file "$cache_dir/$cmd_name.fish"
  set -l needs_refresh 0

  # Check if binary changed or cache missing
  if not test -f $cache_file
    set needs_refresh 1
  else if test $cmd_path -nt $cache_file
    set needs_refresh 1
  end

  if test $needs_refresh -eq 1
    # Special handling for starship which uses --print-full-init
    if string match -q "*starship*" $cmd_name
      $cmd_path init fish --print-full-init > $cache_file 2>/dev/null
    else
      $argv[3..-1] > $cache_file 2>/dev/null
    end
  end

  test -f $cache_file; and source $cache_file
end

# Cached init commands (was ~150ms, now ~5ms)
__cached_init zoxide /opt/homebrew/bin/zoxide zoxide init fish
__cached_init sack $HOME/bin/sack $HOME/bin/sack init_fish
__cached_init direnv /Users/zhill/bin/vendor/direnv direnv hook fish
__cached_init starship /opt/homebrew/bin/starship starship init fish

# https://docs.atuin.sh/configuration/key-binding/
set -gx ATUIN_NOBIND "false"
__cached_init atuin /opt/homebrew/bin/atuin atuin init fish

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

__cached_init mise /opt/homebrew/bin/mise mise activate fish
