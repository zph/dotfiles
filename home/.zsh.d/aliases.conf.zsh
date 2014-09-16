
# reminders
# Delete a line from specific file
# sed -i 8d ~/.ssh/known_hosts
#
# Because swapping to fg, bg, etc should be seamless
# Mac Specific
# alias cd='echo "DONT USE CD use c" && cd'
# alias cv='cdargs'
# alias cva='cdargs -a "$@"; cd $_'
# alias d="dirs -v"
# alias dcd="cd ~+"
# alias g="bundle exec guard $*"
# alias git='echo "DONT USE GIT use g" && git'
# alias jist='jist -p --copy_js'
# alias lock="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
# alias ls='ls --color=auto --human-readable --group-directories-first --classify'
# alias mkdir='mkdir -p' # Make mkdir recursive
# alias tree='tree -L 2 -fi'

alias -g ST='2>&1 | sit'
alias ......="cd ../../../../.."
alias .....="cd ../../../.."
alias ....="cd ../../.."
alias ...="cd ../.."
alias ..="cd .."
alias :q='exit'
alias S='sack'
alias ack='noglob ack -i --nogroup'
alias b='bg'
alias bn='branch-name'
#cd by .. or ... or ... or mv file ..../.
alias c='\cd'
alias cd-='cd - '
alias cdd='cd - '                     # goto last dir cd'ed from
alias cl="clear"
alias cp='cp -iv'
alias curl='curl -L'
alias df='df -kH'
alias dstamp='date +%Y-%m-%d'
alias egrep='egrep --color=auto'
alias f='fg'
alias find_recent="find . -type f -mmin -60"  # Find files below the current directory that have changed within the last 60 minutes.
alias gcomp='g++ -g -Wall -o'
alias grep='grep -Ei --colour=auto'
alias h='history'
alias j="jobs"
alias jist='gist -c'
alias jistc='gist -p -c'
alias l='less -30'
alias less="less -R"
alias ll="ls -lahtr"
alias m='monit'
alias mntcd='mount -t iso9660 -o loop'
alias mv='mv -iv'
alias pgrep='pgrep -f'
alias pkill='pkill -f -I'
alias q='exit'
alias qlf='qlmanage -p "$@" >& /dev/null'
alias r='fc'
alias rcp='rsync -v --progress'
alias re="reload"
alias recd='cd .. && cd -'
alias resit='!! 2>&1 | sit'
alias rm='rm -iv'
alias rmv='rsync -v --progress --remove-source-files'
alias rsync='rsync -v --progress --partial'
alias set_time="dpkg-reconfigure tzdata"
alias targz="tar -cvzf" # then filename.tar.gz dir_to_compress
alias v-='view -'
alias vlast='vim `!! | tail -1`'
alias x="exit"
alias xt='extract'
alias zgrep='zgrep -Ein --with-filename --colour=auto'
