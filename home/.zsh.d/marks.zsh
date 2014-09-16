# Easily jump around the file system by manually adding marks
# marks are stored as symbolic links in the directory $MARKPATH (default $HOME/.marks)
#
# jump FOO: jump to a mark named FOO
# mark FOO: create a mark named FOO
# unmark FOO: delete a mark
# marks: lists all marks
#
export MARKPATH=$HOME/.marks

jump() {
  cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"
}

mark() {
  if (( $# == 0 )); then
    MARK=$(basename "$(pwd)")
  else
    MARK="$1"
  fi
  if read -q \?"Mark $(pwd) as ${MARK}? (y/n) "; then
    mkdir -p "$MARKPATH"; ln -s "$(pwd)" "$MARKPATH/$MARK"
  fi
}

unmark() {
  rm -i "$MARKPATH/$1"
}

autoload colors
marks() {
  for link in $MARKPATH/*(@); do
    local markname="$fg[cyan]${link:t}$reset_color"
    local markpath="$fg[blue]$(readlink $link)$reset_color"
    printf "%s\t" $markname
    printf "-> %s \t\n" $markpath
  done
}

_completemarks() {
  if [[ $(ls "${MARKPATH}" | wc -l) -gt 1 ]]; then
    reply=($(ls $MARKPATH/**/*(-) | grep : | sed -E 's/(.*)\/([_a-zA-Z0-9\.\-]*):$/\2/g'))
  else
    if readlink -e "${MARKPATH}"/* &>/dev/null; then
      reply=($(ls "${MARKPATH}"))
    fi
  fi
}
compctl -K _completemarks jump
compctl -K _completemarks unmark

_mark_expansion() {
  setopt extendedglob
  autoload -U modify-current-argument
  modify-current-argument '$(readlink "$MARKPATH/$ARG")'
}
zle -N _mark_expansion
bindkey "^g" _mark_expansion

# readonly MARKDIR="$HOME/.marks"

# if [[ ! -d $MARKDIR ]];then
#   mkdir $MARKDIR
# fi

# export MARKPATH=$MARKDIR

# function jump {
#   cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"
# }

# function mark {
#   mkdir -p "$MARKPATH"; ln -s "$(pwd)" "$MARKPATH/$1"
# }

# function unmark {
#   rm -i "$MARKPATH/$1"
# }

# autoload colors
# function marks {
#   for link in $MARKPATH/*(@); do
#     local markname="$fg[cyan]${link:t}$reset_color"
#     local markpath="$fg[blue]$(readlink $link)$reset_color"
#     printf "%s\t" $markname
#     printf "-> %s \t\n" $markpath
#   done
# }

# # if [[ "$OSTYPE" == darwin* ]];then
# #   autoload colors
# #   function marks {
# #     for link in $MARKPATH/*(@); do
# #       local markname="$fg[cyan]${link:t}$reset_color"
# #       local markpath="$fg[blue]$(readlink $link)$reset_color"
# #       printf "%s\t" $markname
# #       printf "-> %s \t\n" $markpath
# #     done
# #   }
# #     # \ls -ln "$MARKPATH" | tail -n +2 | sed 's/ / /g' | cut -d' ' -f9- | awk -F ' -> ' '{printf "%-10s -> %s\n", $1, $2}'
# #   # }
# # else
# #   # Linux
# #   function marks {
# #     \ls -l "$MARKPATH" | sed 's/  / /g' | cut -d' ' -f9- | sed 's/ -/\t-/g' && echo
# #   }
# # fi

# # completion
# function _completemarks {
#   reply=($(ls $MARKPATH))
# }

compctl -K _completemarks jump
compctl -K _completemarks unmark
compctl -K _completemarks j

## Aliases
alias m="mark"
alias ms="marks"
alias j="jump"
