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

# Read ~/.zsh_env ONCE for performance (was 111ms, now ~10ms)
set -l zsh_env_content (cat ~/.zsh_env)

# Extract vars matching patterns using pure fish string matching
set ENVVARS EDITOR "DIRENV_" "HOMEBREW_" "DENO_"
set MANPATH ""

for var in $ENVVARS
  # Use string match instead of grep, parse in fish instead of xargs
  for line in (string match -r "^$var.*" -- $zsh_env_content)
    set -l kv (string split -m 1 = $line)
    if test (count $kv) -eq 2
      set -gx $kv[1] $kv[2]
    end
  end
end

# Extract PATH using string match instead of cat|grep|awk
set -l zsh_path_line (string match -r "^PATH=.*" -- $zsh_env_content)
if test -n "$zsh_path_line"
  set -l ZSH_PATH (string sub -s 6 -- $zsh_path_line[1])  # Skip "PATH="
  # Note reverse to make this apply older ones first (keeps useful order)
  for path in (string split ':' $ZSH_PATH)[-1..1]
    set PATH $path $PATH
  end
end

set -l env_file "$HOME/.config/fish/conf.d/env.sh"
set -l cache_file "$HOME/tmp/env_cache"
set -l cache_file_sha "$HOME/tmp/env_cache.sha"
set -l current_sha (string split ' ' (sha256sum $env_file))[1]

# Check cache validity (optimized: avoid unnecessary subprocesses)
set -l needs_refresh 1
if test -f $cache_file_sha
  set -l cached_sha (head -n1 $cache_file_sha)
  if test "$cached_sha" = "$current_sha"
    set needs_refresh 0
  end
end

if test $needs_refresh -eq 1
  echo $current_sha > $cache_file_sha
  diff-env "source $env_file" > $cache_file
end

# Load cached env vars (optimized: read once, parse in fish)
if test -f $cache_file
  set -l cache_lines (cat $cache_file)
  for line in $cache_lines[2..-1]  # Skip first line
    if test -n "$line"
      set -l kv (string split -m 1 = $line)
      if test (count $kv) -eq 2
        set -gx $kv[1] $kv[2]
      end
    end
  end
end
