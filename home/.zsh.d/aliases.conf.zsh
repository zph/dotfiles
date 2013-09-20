alias c='\cd'
# alias cd='echo "DONT USE CD use c" && cd'
# alias git='echo "DONT USE GIT use g" && git'
alias rsync='rsync -v --progress --partial'
alias dstamp='date +%Y-%m-%d'
alias ack='noglob ack -i --nogroup'
alias less="less -R"
alias qlf='qlmanage -p "$@" >& /dev/null'
alias q='exit'
alias pgrep='pgrep -f'
alias zgrep='zgrep -Ein --with-filename --colour=auto'
# alias mkdir='mkdir -p' # Make mkdir recursive
alias cdd='cd - '                     # goto last dir cd'ed from
alias cd-='cd - '
alias df='df -kH'
alias xt='extract'
# alias cv='cdargs'
# alias cva='cdargs -a "$@"; cd $_'
alias mntcd='mount -t iso9660 -o loop'
alias targz="tar cvzf" # then filename.tar.gz dir_to_compress

#cd by .. or ... or ... or mv file ..../.
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

# Because swapping to fg, bg, etc should be seamless
alias j="jobs"
alias f="fg"
alias b='bg'
alias cp='cp -iv'
alias rcp='rsync -v --progress'
alias rmv='rsync -v --progress --remove-source-files'
alias mv='mv -iv'
alias rm='rm -iv'
alias re="reload"
# alias d="dirs -v"
alias cl="clear"
alias v-='view -'
# alias dcd="cd ~+"
if which colordiff > /dev/null 2>&1; then
	alias diff="colordiff -Nuar"
else
	alias diff="diff -Nuar"
fi

alias grep='grep -Ei --line-number --with-filename --colour=auto'
alias egrep='egrep --color=auto'
alias curl='curl -L'
# alias ls='ls --color=auto --human-readable --group-directories-first --classify'
alias g="bundle exec guard $*"
alias x="exit"
alias ll="ls -lah"

# Mac Specific
# alias lock="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
alias gcomp='g++ -g -Wall -o'
alias h='history'
alias l='less -30'

# Set sz as a function for sourcing base shell dotfile
sz(){
case $(echo $SHELL) in
  "/bin/zsh")
    source ~/.zshrc
    ;;
  "/bin/bash")
    source ~/.bashrc
    ;;
  *)
    echo "Unknown Shell"
    ;;
esac
}

alias set_time="dpkg-reconfigure tzdata"
# alias jist='jist -p --copy_js'
alias jistc='jist -p -c'
alias jist='jist -c'
alias :q='exit'
