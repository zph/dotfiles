[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# [ -f $FZF_ZSH_CONFIG ] && source $FZF_ZSH_CONFIG
# fe [FUZZY PATTERN] - Open the selected file with the default editor
# #   - Bypass fuzzy finder if there's only one match (--select-1)
# #   - Exit if there's no match (--exit-0)
# Copy the original fzf function to __fzf

export FZF_TMUX="~/.fzf/bin/fzf-tmux"
export FZF_DEFAULT_COMMAND='ag -l -g ""'

alias fz="fzf"
# declare -f __fzf > /dev/null ||
#   eval "$(echo "__fzf() {"; declare -f fzf | \grep -v '^{' | tail -n +2)"

# Use git ls-tree when possible
# fzf() {
#   if [ -n "$(git rev-parse HEAD 2> /dev/null)" ]; then
#     FZF_DEFAULT_COMMAND="git ls-tree -r --name-only HEAD" __fzf "$@"
#   else
#     __fzf "$@"
#   fi
# }

fe() {
  local file
  file=$(fzf --query="$1" --select-1 --exit-0)
  [ -n "$file" ] && ${EDITOR:-vim} "$file"
}

# fd - cd to selected directory
fd() {
  local dir
  dir=$(find ${1:-*} -path '*/\.*' -prune \
    -o -type d -print 2> /dev/null | fzf +m) &&
    cd "$dir"
}

# fh - repeat history
fh() {
  eval $(([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s | sed 's/ *[0-9]* *//')
}

# fkill - kill process
fkill() {
  ps -ef | sed 1d | fzf -m | awk '{print $2}' | xargs kill -${1:-9}
}
