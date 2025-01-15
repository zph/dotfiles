# Manual export and generation of zsh settings via env var
# To refresh, delete $HOME/.zsh_env
function update_zsh_vars
  zsh -c 'source ~/.zshrc && env > ~/.zsh_env'
end

# Disable fish greeting
set fish_greeting

if test ! -f $HOME/.zsh_env
  update_zsh_vars
end

# Use zsh for declaring some env vars
# it's messy and confusing but I want fish to inherit some settings from zsh
# for consistency over the two shells
set ENVVARS EDITOR "DIRENV_" "HOMEBREW_" "DENO_"
set MANPATH ""

for var in $ENVVARS
  set value (cat ~/.zsh_env  | grep "^$var" | xargs)
  export "$value"
end

# Will break on equal sign but the oneliners to handle that edge case are excessively complicated
set ZSH_PATH (cat ~/.zsh_env | grep "^PATH=" | awk -F'=' '{print $2}')
# Note reverse to make this apply older ones first (keeps useful order)
for path in (string split ':' $ZSH_PATH | tail -r)
  set PATH $path $PATH
end

set -l env_file "$HOME/.config/fish/conf.d/env.sh"
set -l cache_file "$HOME/tmp/env_cache"
set -l cache_file_sha "$HOME/tmp/env_cache.sha"
set -l current_sha (sha256sum $env_file | cut -d' ' -f1)

if test ! -f $cache_file_sha; or test (cat $cache_file_sha | head -n1) != $current_sha
  echo $current_sha > $cache_file_sha
  diff-env "source $env_file" > $cache_file
end

# Load cached env vars
tail -n +2 $cache_file | while read -l line
  set -l kv (string split -m 1 = $line)
  set -gx $kv[1] $kv[2]
end
