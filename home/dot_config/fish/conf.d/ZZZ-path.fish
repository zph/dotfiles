# Depends on pather from zph/pather (deno variant)
if type -sq pather
  set PATH (\
    pather \
      /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:1 \
      /var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:1 \
      /opt/homebrew/opt/asdf/libexec/bin:-1 \
      /usr/local/opt/mongodb@3.2/bin:-1 \
      /Applications/Wireshark.app/Contents/MacOS:-1 \
      /opt/homebrew/opt/ruby/bin:-1 \
      /Users/zph/.asdf/shims:-1 \
      /Users/zph/Library/Python/2.7/bin:-1
    )
end
