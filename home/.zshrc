# .zshrc
# Assembled, refactored and modified by: ZPH <zander@xargs.io>
# License on modifications and original code: Bourbonware.
# Credits: Piotr Karbowski <piotr.karbowski@gmail.com> (Licensed as Beerware)
# Gary Bernhardt, Wunjo, Others...
#    Wunjo
#    -http://www.wunjo.org/zsh-git
#    Gary Bernhardt
#    -https://github.com/garybernhardt/dotfiles
#
# If you're not listed and see original code of yours, please notify me, ZPH,
#   at email listed above.  I've pieced together this zshrc over time and it has
#   undergone significant revisions.
#############
# Private Functions
_zshrc_pre_init(){
  # TODO
  # -force symlinking of primary directories
  # -force run of homesick, i.e. this doesn't work without homesick being run
  # -add pre-sourcing?, ie a before hook
  _set_zshddir(){
    __dotfile_warning(){
      echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
      echo "Please symlink dotfiles/home/.zsh.d into standard location"
      echo "ie ln -s ~/Dropbox/dotfiles/home/.zsh.d ~/.zsh.d"
      echo "Or run homesick symlink [dotfile/home location]"
      echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
    }

    if [[ -d "${HOME}/.zsh.d" ]]; then
      ZSHDDIR="${HOME}/.zsh.d"
    elif [[ -d "${HOME}/dotfiles/home/.zsh.d" ]]; then
      # ln -s "${HOME}/dotfiles/home/.zsh.d" "${HOME}/.zsh.d"
      __dotfile_warning
      ZSHDDIR="${HOME}/dotfiles/home/.zsh.d"
    elif [[ -d "${HOME}/Dropbox/dotfiles/home/.zsh.d" ]]; then
      # ln -s "${HOME}/dotfiles/home/.zsh.d" "${HOME}/.zsh.d"
      __dotfile_warning
      ZSHDDIR="${HOME}/Dropbox/dotfiles/home/.zsh.d"
    else
      __dotfile_warning
    fi
  }
  #################################
  # Executed commands
  source /etc/profile
  # Shell config. Safety feature for multiuser envs
  # umask 077

  # Completion.
  autoload -Uz compinit
  compinit
  setopt completealiases
  zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
  zstyle ':completion:*' completer _expand _complete _ignored _approximate
  zstyle -e ':completion:*:approximate:*' \
        max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3))numeric)'
  zstyle ':completion:*' menu select=2
  zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
  zstyle ':completion:*:descriptions' format '%U%F{cyan}%d%f%u'
  zstyle ':completion:*:*:kill:*' menu yes select
  zstyle ':completion:*:kill:*'   force-list always
  # Basic zsh config.
  ZDOTDIR=${ZDOTDIR:-${HOME}}
  _set_zshddir
  HISTFILE="${ZDOTDIR}/.zsh_history"
  HISTSIZE='1000000000'
  SAVEHIST="${HISTSIZE}"
  # for zsh-completions and prompt
  fpath=(/usr/local/share/zsh-completions $fpath ${ZSHDDIR}/func)
  export TERM=xterm-256color
}

_set_zsh_settings(){
  # Le features!
  # Set Vi Mode
  bindkey -v
  bindkey -M viins 'jk' vi-cmd-mode

  # ctrl-p ctrl-n history navigation
  bindkey '^P' up-history
  bindkey '^N' down-history

  # backspace and ^h working even after returning from command mode
  bindkey '^?' backward-delete-char
  bindkey '^h' backward-delete-char

  # ctrl-w removed word backwards
  bindkey '^w' backward-kill-word

  # ctrl-r starts searching history backward
  bindkey '^r' history-incremental-search-backward

  #############################
  # extended globbing, awesome!
  setopt extendedGlob

  # zmv -  a command for renaming files by means of shell patterns.
  autoload -U zmv

  # zargs, as an alternative to find -exec and xargs.
  autoload -U zargs

  # hooks
  autoload -U add-zsh-hook

  # Turn on command substitution in the prompt (and parameter expansion and arithmetic expansion).
  setopt promptsubst

  # Ignore duplicate in history.
  setopt hist_ignore_dups

  # Prevent record in history entry if preceding them with at least one space
  setopt hist_ignore_space

  # History Append - Because we like keeping all the historiez
  setopt inc_append_history

  # Nobody need flow control anymore. Troublesome feature.
  #stty -ixon
  setopt noflowcontrol
  # Autocd without using CD
  setopt autocd

  # Automatically add directories to stack so they can
  # be referenced by 'dirs -v' or cd ~+<number>
  # setopt AUTO_PUSHD Set in other location

  # try to avoid the 'zsh: no matches found...'
  setopt nonomatch
  # Provide more processes in completion of programs like killall:
  zstyle ':completion:*:processes-names' command 'ps c -u ${USER} -o command | uniq'

  # insert all expansions for expand completer
  zstyle ':completion:*:expand:*'        tag-order all-expansions
  zstyle ':completion:*:history-words'   list false

  # Very helpful for pasting in URLs that would otherwise be disastrous:
  autoload -U url-quote-magic
  zle -N self-insert url-quote-magic
}

_source_zshd(){
  # Finally, source all the files in zsh.d (ALPHA order)
  for zshd in $(find ${ZSHDDIR}/*.zsh | sort ); do
    source "${zshd}"
  done
}

_ignore_listed_zshd_commands(){
  # Function to add nocorrect for certain commands, one per line in .zsh_nocorrect
  # It fails if any line is a blankline
  ZSHNOCORRECT="${ZSHDDIR}/.zsh_nocorrect"
  if [ -f ${ZSHNOCORRECT} ]; then
    while read -r COMMAND; do
        alias $COMMAND="nocorrect $COMMAND"
    done < ${ZSHNOCORRECT}
  fi
  unset ZSHNOCORRECT
}

_set_colors(){
  # Colors.
  red='\e[0;31m'
  RED='\e[1;31m'
  green='\e[0;32m'
  GREEN='\e[1;32m'
  yellow='\e[0;33m'
  YELLOW='\e[1;33m'
  blue='\e[0;34m'
  BLUE='\e[1;34m'
  purple='\e[0;35m'
  PURPLE='\e[1;35m'
  cyan='\e[0;36m'
  CYAN='\e[1;36m'
  NC='\e[0m'
}

_confirm() {
  local answer
  echo -ne "zsh: sure you want to run '${yellow}$@${nc}' [yN]? "
  read -q answer
    echo
  if [[ "${answer}" =~ ^[Yy]$ ]]; then
    command "${=1}" "${=@:2}"
  else
    return 1
  fi
}

_confirm_wrapper() {
  if [ "$1" = '--root' ]; then
    local as_root='true'
    shift
  fi

  local runcommand="$1"; shift

  if [ "${as_root}" = 'true' ] && [ "${USER}" != 'root' ]; then
    runcommand="sudo ${runcommand}"
  fi
  _confirm "${runcommand}" "$@"
}

_termtitle() {
  case "$TERM" in
    rxvt*|xterm|nxterm|gnome|screen|screen-*)
      case "$1" in
        precmd)
          print -Pn "\e]0;%n@%m: %~\a"
        ;;
        preexec)
          zsh_cmd_title="$2"
          # Escape '\' char.
          zsh_cmd_title="${zsh_cmd_title//\\/\\\\}"
          # Escape '$' char.
          zsh_cmd_title="${zsh_cmd_title//\$/\\\\\$}"
          # Escape '%' char.
          #zsh_cmd_title="${zsh_cmd_title//%/\%\%}"
          # As I am unable to deal with all %, especially
          # the nasted one, I will just strip this char.
          zsh_cmd_title="${zsh_cmd_title//\%/<percent>}"
          print -Pn "\e]0;${zsh_cmd_title} [%n@%m: %~]\a"
        ;;
      esac
    ;;
  esac
}

_add_homebin_to_dir(){
  if ! [[ "${PATH}" =~ "^${HOME}/bin" ]]; then
    export PATH="${HOME}/bin:${PATH}"
  fi

  # Add subdirs under bin to path. Used to keep contributions organized
  # export PATH="${PATH}$(find ~/${HOME}/bin -name '.*' -prune -o -type d -printf ':%p')"
  PATH=${PATH}:$(find ~/bin -type d | tr '\n' ':' | sed 's/:$//')
}

_export_editor_and_tmp_dirs(){
  export EDITOR="/usr/local/bin/vim"
  export TMP="$HOME/tmp"
  export TEMP="$TMP"
  export TMPDIR="$TMP"
  export TMPDIRVIM="$TMP/vim" # dir for vim backup files

  if [ ! -d "${TMP}" ]; then mkdir "${TMP}"; fi
  if [ ! -d "${TMPDIRVIM}" ]; then mkdir "${TMPDIRVIM}"; fi
}

_normalize_keys(){
  # Keys.
  case $TERM in
    rxvt*)
      bindkey "^[[7~" beginning-of-line #Home key
      bindkey "^[[8~" end-of-line #End key
      bindkey "^[[3~" delete-char #Del key
      bindkey "^[[A" history-beginning-search-backward #Up Arrow
      bindkey "^[[B" history-beginning-search-forward #Down Arrow
      bindkey "^[Oc" forward-word # control + right arrow
      bindkey "^[Od" backward-word # control + left arrow
      bindkey "^H" backward-kill-word # control + backspace
      bindkey "^[[3^" kill-word # control + delete
    ;;

    linux)
      bindkey "^[[1~" beginning-of-line #Home key
      bindkey "^[[4~" end-of-line #End key
      bindkey "^[[3~" delete-char #Del key
      bindkey "^[[A" history-beginning-search-backward
      bindkey "^[[B" history-beginning-search-forward
    ;;

    screen|screen-*)
      bindkey "^[[1~" beginning-of-line #Home key
      bindkey "^[[4~" end-of-line #End key
      bindkey "^[[3~" delete-char #Del key
      bindkey "^[[A" history-beginning-search-backward #Up Arrow
      bindkey "^[[B" history-beginning-search-forward #Down Arrow
      bindkey "^[Oc" forward-word # control + right arrow
      bindkey "^[Od" backward-word # control + left arrow
      bindkey "^H" backward-kill-word # control + backspace
      bindkey "^[[3^" kill-word # control + delete
    ;;
  esac

  # Keybinds for history searching
  bindkey "^R" history-incremental-pattern-search-backward 
  bindkey "^S" history-incremental-pattern-search-forward
  # Keybinds for vi-mode history searching
  # Source: http://superuser.com/questions/328026/can-i-use-vim-editing-mode-on-the-command-line-without-losing-recursive-history
  bindkey -M viins '^R' history-incremental-search-backward
  bindkey -M vicmd '^R' history-incremental-search-backward
  # # More Vi keybinds for searching
  # bindkey '^P' history-search-backward
  # bindkey '^N' history-search-forward 
  # Keybind for opening command in full editor
  #
  autoload -z edit-command-line
  zle -N edit-command-line
  bindkey "^X^E" edit-command-line
  #
  # only works in newer zsh
  zmodload -a pcre

}

_set_prompt(){
  # Setup prompt
  setopt PROMPT_SUBST
  autoload -U promptinit
  promptinit
  prompt zph
  _right_prompt
}

_right_prompt(){
  if [[ -n $EMACS ]];then
  else
    source $HOME/.zsh.d/git-prompt/git-prompt.zsh
  fi
}

### Main function
_local_configs(){
  if [[ -f "${ZSHDDIR}/configs.local" ]]; then
    source "${ZSHDDIR}/configs.local"
  fi
}

_remove_from_path(){
  local item="$1"
  cleansed_path=$(echo -n $PATH | tr ':' "\n" | grep -v "^${item}$" | grep -v '^$' | tr "\n" ':')
  export PATH=$cleansed_path
}

_add_to_path(){
  local item="$1"
  export PATH=${item}:$PATH
}

_prepend_to_path(){
  local item="$1"
  _remove_from_path "$item"
  _add_to_path "$item"
}

_set_zsh_hooks(){
  add-zsh-hook chpwd _set_prompt
  add-zsh-hook precmd _set_prompt
}

_zshrc_main(){
  ############
  # Execute Functions
  _zshrc_pre_init
  _local_configs
  _set_zsh_settings
  _ignore_listed_zshd_commands
  _termtitle
  _export_editor_and_tmp_dirs
  _normalize_keys
  _set_colors
  _add_homebin_to_dir
  _source_zshd
  _set_prompt
  _prepend_to_path "${HOME}/bin"
  _remove_from_path "~/bin"

  PROMPT="$PROMPT"'$([ -n "$TMUX" ] && tmux setenv TMUXPWD_$(tmux display -p "#D" | tr -d %) "$PWD")'
  _set_zsh_hooks

}

_zshrc_main

eval "$(direnv hook zsh)"
