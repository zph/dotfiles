# Re-executes prior command and loads it into pbcopy buffer
# Credit: https://raw.github.com/skwp/dotfiles/master/zsh/last-command.zsh
# Use Ctrl-x,Ctrl-l to get the output of the last command
# zmodload -i zsh/parameter
# insert-last-command-output() {
# LBUFFER+="$(eval $history[$((HISTCMD-1))])"
# }
# zle -N insert-last-command-output
# bindkey "^X^L" insert-last-command-output
# in progress
#
# zmodload -i zsh/parameter
# copy-last-command-output() {
#   result=$(eval $history[$((HISTCMD-1))] \
#     2> ( sed 's/^/STDERR: /g' >> pbcopy ) \
#      > ( sed 's/^/STDOUT: /g' >> pbcopy ))
#   echo $result
#   LBUFFER+="pbpaste | "
# }
zmodload -i zsh/parameter
copy-last-command-output() {
  result=$(eval $history[$((HISTCMD-1))] 2>&1 | pbcopy)
  echo $result
  LBUFFER+="pbpaste | "
}
zle -N copy-last-command-output
bindkey "^X^L" copy-last-command-output

paste-output() {
  LBUFFER+="pbpaste | "
}
zle -N paste-output
bindkey "^X^Y" paste-output

# zmodload -i zsh/parameter
# last-command-error() {
#   result=$(eval $history[$((HISTCMD-1))] 2>| pbcopy)
#   echo $result
#   LBUFFER+="pbpaste | "
# }
# zle -N copy-last-command-output
# bindkey "^X^L" copy-last-command-output
