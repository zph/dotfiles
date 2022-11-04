# Prepend Brew Bin (/usr/local/bin/) to PATH
export PATH=/usr/local/bin:/usr/local/sbin:$PATH

export HOMEBREW_BUNDLE_NO_LOCK=1
export HOMEBREW_MAKE_JOBS=1

alias brew='VERBOSE=1 brew'
alias buu='brew update && brew upgrade'
function brew.info {
  grep desc $(brew --prefix)/Library/Formula/*.rb | perl -ne 'm{^.*/(.*?)\.rb.*?\"(.*)"$} and print "$1|$2\n"' | column -t -s '|' | fzf --reverse
}
