# Mac OS
if [[ "$OSTYPE" == darwin* ]]; then
  alias pbc='pbcopy'
  alias pbp='pbpaste'

  alias trash_empty='\rm -irf ~/.Trash/*'

  alias dsstore_rm='sudo find / -name ".DS_Store" -depth -exec rm {} \;'

  function system_urls(){
    /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -dump | \
      egrep "(bindings.*\:$)" | sort
}

  function dash() {
    open dash://$@
}

  alias o='open'
  alias get='curl --continue-at - --location --progress-bar --remote-name --remote-time'
  alias slimit='pbpaste| html2slim | pbcopy'

  alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
  alias chrome-canary="/Applications/Google\ Chrome\ Canary.app/Contents/MacOS/Google\ Chrome\ Canary"
  alias chromium="/Applications/Chromium.app/Contents/MacOS/Chromium"
else
  alias o='xdg-open'
  alias get='wget --continue --progress=bar --timestamping'
fi
