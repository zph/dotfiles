# Disable fish greeting
set fish_greeting

# Environment variables - optimized to avoid external command overhead
# Replaces zsh dependency and diff-env caching with direct definitions

## Editor and pager
if type -q nvim
  set -gx EDITOR (which nvim)
else if type -q vim
  set -gx EDITOR (which vim)
end

if type -q bat
  set -gx PAGER (which bat)
end

## Homebrew
set -gx HOMEBREW_BUNDLE_NO_LOCK 1
set -gx HOMEBREW_MAKE_JOBS 1
set -gx HOMEBREW_NO_ANALYTICS 1
set -gx HOMEBREW_NO_AUTO_UPDATE 1
set -gx HOMEBREW_CASK_OPTS "--appdir=~/Applications"

## Elixir
set -gx ELIXIR_ERL_OPTS "+P 5000000"
set -gx ERL_AFLAGS "-kernel shell_history enabled"

## FZF
set -gx FZF_DEFAULT_COMMAND 'rg --files --no-ignore --hidden --follow -g "!{_build,.git,node_modules}/*" 2> /dev/null'

## Python
set -gx PYTHONSTARTUP "$HOME/.pythonrc"

## Deno
set -gx DENO_NO_UPDATE_CHECK 1

## Direnv - for 1p integration
set -gx DIRENV_WARN_TIMEOUT 1m
