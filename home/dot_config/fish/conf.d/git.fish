alias g 'git'
alias gcl 'git clone'
alias gg "git go"
alias gst 'git status -s'
alias gpr 'git pull --rebase'
alias gpo 'git push origin'
alias gp 'git push'
alias gup 'git fetch && git rebase'
alias gub 'git update-branch'
alias grc 'git rebase --continue'
alias gpu 'git push'
alias gc 'git commit -v'
alias gca 'git commit -v -a'
alias gci 'git commit -v'
alias gcim 'git commit -m'
alias gco 'git checkout'
alias gcof 'git checkout (gb)'
alias gcm 'git checkout master'
alias gba 'git branch -a'
alias gcount 'git shortlog -sn'
alias gcp 'git cherry-pick'
alias gll 'git log --pretty oneline --abbrev-commit'
alias glo "git log --pretty format:'%h %ad | %s%d [%an]' --date short --abbrev-commit"
alias glg 'git log --stat --max-count 5'
alias glgg 'git log --graph --max-count 5'
alias gs 'git status -s'
alias gss 'git status -s'
alias ga 'git add'
alias gaa 'git add --all'
alias gap 'git add -p'
alias gm 'git merge'
alias gmv 'git mv'
alias grm 'git rm'
alias gcop 'git commit && git push'
alias gitrm "git add -u"

function gd
  pushd (git root)
    set preview "git diff $argv --color=always -- {-1}"
    git diff $argv --name-only | fzf -m --ansi --preview $preview
  popd
end
