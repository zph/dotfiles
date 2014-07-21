# Git Aliases -
# Taken from http://www.anujgakhar.com/2012/01/08/a-better-shell-with-oh-my-zsh/
# and oh-my-zsh
# grep for specific regex in git log 'git log -S "SITEMAP" --pretty=oneline --abbrev-commit'

if [[ -x `which gh` ]];then
  alias g=`which gh`;
elif [[ -x `which hub` ]]; then
  alias g=`which hub`;
else
  alias g='git'
fi
compdef g=git
alias gcl='git clone'

function _complete_git-go {
  reply=($(git branch -r | grep -v -- '->' | cut -d '/' -f 2))
}
compctl -K _complete_git-go git-go
alias gg="git go"
compctl -K _complete_git-go gg

#compdef _git gcl=git-clone
alias gst='git status -s'
#compdef _git gst=git-status
alias gpr='git pull --rebase'
alias gpo='git push origin'
#compdef _git gl=git-pull
alias gp='git push'
#compdef _git gl=git-pull
alias gup='git fetch && git rebase'
#compdef _git gup=git-fetch
alias grc='git rebase --continue'
#compdef _git gup=git-rebase
alias gpu='git push'
#compdef _git gp=git-push
gdv() { git diff -w "$@" | view - }
#compdef _git gdv=git-diff
alias gc='git commit -v'
#compdef _git gc=git-commit
alias gca='git commit -v -a'
#compdef _git gca=git-commit
alias gci='git commit -v'
#compdef _git gcom=git-commit
alias gcim='git commit -m'
#compdef _git gcom=git-commit
function gcimpu(){
  git commit -m $@;
  git push
}
#compdef _git gcom=git-commit
alias gco='git checkout'
#compdef _git gco=git-checkout
alias gcm='git checkout master'
alias gb='git branch'
#compdef _git gb=git-branch
alias gba='git branch -a'
#compdef _git gba=git-branch
alias gcount='git shortlog -sn'
#compdef gcount=git
alias gcp='git cherry-pick'
#compdef _git gcp=git-cherry-pick
alias gl='git log --pretty=oneline --abbrev-commit'
alias glo="git log --pretty=format:'%h %ad | %s%d [%an]' --date=short --abbrev-commit"
#compdef _git gll=git-log
alias gll="git log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short"
#compdef _git gll=git-log
alias glg='git log --stat --max-count=5'
#compdef _git glg=git-log
alias glgg='git log --graph --max-count=5'
#compdef _git glgg=git-log
alias gs='git status -s'
alias gss='git status -s'
#compdef _git gss=git-status
alias ga='git add'
#compdef _git ga=git-add
alias gaa='git add --all'
#compdef _git ga=git-add
# if [[ -x $(which ffind) ]];then
#   function gap(){
#   git add --patch "$(ffind $1)"
# }
# else
alias gap='git add -p'
# fi
#compdef _git ga=git-add
alias gm='git merge'
#compdef _git gm=git-merge
alias gmv='git mv'
#compdef _git gmv=mv
alias grm='git rm'
#compdef _git grm=rm
alias gcop='git commit && git push'
# alias gitrm="git status | grep deleted | awk '{print $3}' | xargs git rm"
alias gitrm="git add -u"
