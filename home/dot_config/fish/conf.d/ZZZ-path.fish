# Optimized path management with caching to avoid external command overhead
# Depends on pather from zph/pather (deno variant)
if type -sq pather
  set -l cache_file "$HOME/tmp/pather_cache"
  set -l cache_age_limit 86400  # 24 hours in seconds
  set -l needs_refresh 0

  # Check if cache exists and is recent
  if test -f $cache_file
    set -l cache_age (math (date +%s) - (stat -f %m $cache_file 2>/dev/null || echo 0))
    if test $cache_age -gt $cache_age_limit
      set needs_refresh 1
    end
  else
    set needs_refresh 1
  end

  # Refresh cache if needed
  if test $needs_refresh -eq 1
    pather \
      /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:1 \
      /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:1 \
      /opt/homebrew/opt/asdf/libexec/bin:-1 \
      /usr/local/opt/mongodb@3.2/bin:-1 \
      /Applications/Wireshark.app/Contents/MacOS:-1 \
      /opt/homebrew/opt/ruby/bin:-1 \
      /Users/zph/.asdf/shims:-1 \
      /Users/zph/Library/Python/2.7/bin:-1 > $cache_file
  end

  # Load from cache
  set PATH (cat $cache_file)
end
