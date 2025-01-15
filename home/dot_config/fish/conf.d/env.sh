# This file is sourced by diff-env to update the environment variables
export PAGER=$(which bat)
export EDITOR=$(which nvim || which vim)

## Homebrew
export HOMEBREW_BUNDLE_NO_LOCK=1
export HOMEBREW_MAKE_JOBS=1
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_CASK_OPTS="--appdir=~/Applications"

## Elixir
export ELIXIR_ERL_OPTS="+P 5000000"
export ERL_AFLAGS="-kernel shell_history enabled"

export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{_build,.git,node_modules}/*" 2> /dev/null'

export PYTHONSTARTUP="$HOME/.pythonrc"

## Deno
export DENO_NO_UPDATE_CHECK=1

## Direnv - for 1p integration
export DIRENV_WARN_TIMEOUT=1m
