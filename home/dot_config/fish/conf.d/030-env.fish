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

set PAGER (which bat)

set EDITOR (which nvim)
