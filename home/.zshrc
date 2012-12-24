# .zshrc
# Author: Piotr Karbowski <piotr.karbowski@gmail.com>
# License: beerware.
source /etc/profile

# Basic zsh config.
ZDOTDIR=${ZDOTDIR:-${HOME}}
ZSHDDIR="${HOME}/.config/zsh.d"
HISTFILE="${ZDOTDIR}/.zsh_history"
HISTSIZE='10000'
SAVEHIST="${HISTSIZE}"

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

# Functions

reload () {
          exec "${SHELL}" "$@"
}
prompt_char () {
    git branch >/dev/null 2>/dev/null && echo '±' && return
    hg root >/dev/null 2>/dev/null && echo '☿' && return
    echo '○'
}
confirm() {
	local answer
	echo -ne "zsh: sure you want to run '${YELLOW}$@${NC}' [yN]? "
	read -q answer
		echo
	if [[ "${answer}" =~ ^[Yy]$ ]]; then
		command "${=1}" "${=@:2}"
	else
		return 1
	fi
}

confirm_wrapper() {
	if [ "$1" = '--root' ]; then
		local as_root='true'
		shift
	fi

	local runcommand="$1"; shift

	if [ "${as_root}" = 'true' ] && [ "${USER}" != 'root' ]; then
		runcommand="sudo ${runcommand}"
	fi
	confirm "${runcommand}" "$@"
}

poweroff() { confirm_wrapper --root $0 "$@"; }
reboot() { confirm_wrapper --root $0 "$@"; }
hibernate() { confirm_wrapper --root $0 "$@"; }

detox() {
	if [ "$#" -ge 1 ]; then
		confirm detox "$@"
	else	
		command detox "$@"
	fi
}

has() {
	local string="${1}"
	shift
	local element=''
	for element in "$@"; do
		if [ "${string}" = "${element}" ]; then
			return 0
		fi
	done
	return 1
}

begin_with() {
	local string="${1}"
	shift
	local element=''
	for element in "$@"; do
		if [[ "${string}" =~ "^${element}" ]]; then
			return 0
		fi
	done
	return 1

}

termtitle() {
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
					# As I am unable to deal with all %, especialy
					# the nasted one, I will just strip this char.
					zsh_cmd_title="${zsh_cmd_title//\%/<percent>}"
          print -Pn "\e]0;${zsh_cmd_title} [%n@%m: %~]\a"
				;;
			esac
		;;
	esac
}



git_check_if_worktree() {
	# This function intend to be only executed in chpwd().
	# Check if the current path is in git repo.	

	# We would want stop this function, on some big git repos it can take some time to cd into.
	if [ -n "${skip_zsh_git}" ]; then
		git_pwd_is_worktree='false'
		return 1
	fi
	# The : separated list of paths where we will run check for git repo.
	# If not set, then we will do it only for /root and /home.
	if [ "${UID}" = '0' ]; then
		# running 'git' in repo changes owner of git's index files to root, skip prompt git magic if CWD=/home/*
		git_check_if_workdir_path="${git_check_if_workdir_path:-/root}"
	else
		git_check_if_workdir_path="${git_check_if_workdir_path:-/home}"
		git_check_if_workdir_path_exclude="${git_check_if_workdir_path_exclude:-${HOME}/_sshfs}"
	fi

	if begin_with "${PWD}" ${=git_check_if_workdir_path//:/ }; then
		if ! begin_with "${PWD}" ${=git_check_if_workdir_path_exclude//:/ }; then
			local git_pwd_is_worktree_match='true'
		else
			local git_pwd_is_worktree_match='false'
		fi
	fi

	if ! [ "${git_pwd_is_worktree_match}" = 'true' ]; then
		git_pwd_is_worktree='false'
		return 1
	fi

	# todo: Prevent checking for /.git or /home/.git, if PWD=/home or PWD=/ maybe...
	#	damn annoying RBAC messages about Access denied there.
	if [ -d '.git' ] || [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = 'true' ]; then
		git_pwd_is_worktree='true'
		git_worktree_is_bare="$(git config core.bare)"
	else
		unset git_branch git_worktree_is_bare
		git_pwd_is_worktree='false'
	fi
}

git_branch() {
	git_branch="$(git symbolic-ref HEAD 2>/dev/null)"
	git_branch="${git_branch##*/}"
	git_branch="${git_branch:-no branch}"
}

git_dirty() {
	if [ "${git_worktree_is_bare}" = 'false' ] && [ -n "$(git status --untracked-files='no' --porcelain)" ]; then
		git_dirty='%F{green}*'
	else
		unset git_dirty
	fi
}

precmd() {
	# Set terminal title.
	termtitle precmd

	if [ "${git_pwd_is_worktree}" = 'true' ]; then
		git_branch
		git_dirty
			
		git_prompt=" %F{blue}[%F{253}${git_branch}${git_dirty}%F{blue}]"
	else
		unset git_prompt
	fi
}

preexec() {
	# Set terminal title along with current executed command pass as second argument
	termtitle preexec "${(V)1}"
}

chpwd() {
	git_check_if_worktree
}

# Le features!
# extended globbing, awesome!
setopt extendedGlob

# zmv -  a command for renaming files by means of shell patterns.
autoload -U zmv

# zargs, as an alternative to find -exec and xargs.
autoload -U zargs

# Turn on command substitution in the prompt (and parameter expansion and arithmetic expansion).
setopt promptsubst
# Completion.
autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' menu select=2
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*:descriptions' format '%U%F{cyan}%d%f%u'

# If running as root and nice >0, renice to 0.
if [ "$USER" = 'root' ] && [ "$(cut -d ' ' -f 19 /proc/$$/stat)" -gt 0 ]; then
	renice -n 0 -p "$$" && echo "# Adjusted nice level for current shell to 0."
fi

# Fancy prompt.
if [ -n "${SSH_CLIENT}" ]; then
	prompt_is_ssh='%F{blue}[%F{253}SSH%F{blue}] '
else
	unset prompt_is_ssh
fi

case $USER in
	root)
		PROMPT='%B%F{cyan}%m%k %(?..%F{blue}[%F{253}%?%F{blue}] )${prompt_is_ssh}%B%F{blue}%1~${git_prompt}%F{blue} %# %b%f%k'
	;;

	*)	
    PROMPT='%B%F{blue}%n@%m%k %(?..%F{blue}[%F{253}%?%F{blue}] )${prompt_is_ssh}%B%F{cyan}%1~${git_prompt}%F{cyan} %# %b%f%k'

	;;
esac

# Ignore duplicate in history.
setopt hist_ignore_dups

# Prevent record in history entry if preceding them with at least one space
setopt hist_ignore_space

# History Append - Because we like keeping all the historiez
setopt inc_append_history

# Nobody need flow control anymore. Troublesome feature.
#stty -ixon
setopt noflowcontrol
umask
# Shell config.
umask 077
if ! [[ "${PATH}" =~ "^${HOME}/bin" ]]; then
	export PATH="${HOME}/bin:${PATH}"
fi

export EDITOR=`which vim`
export TMP="$HOME/tmp"
export TEMP="$TMP"
export TMPDIR="$TMP"
export TMPDIRVIM="$TMP/vim" # dir for vim backup files

if [ ! -d "${TMP}" ]; then mkdir "${TMP}"; fi
if [ ! -d "${TMPDIRVIM}" ]; then mkdir "${TMPDIRVIM}"; fi

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
# More Vi keybinds for searching
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward 

if [ -f ~/.alert ]; then cat ~/.alert; fi

# Include user-specified configs.
if [ ! -d "${ZSHDDIR}" ]; then
	mkdir -p "${ZSHDDIR}" && echo "# Put your user-specified config here." > "${ZSHDDIR}/example.zsh"
fi


export TERM=xterm-256color

# Autocd without using CD
setopt autocd

# Automatically add directories to stack so they can
# be referenced by 'dirs -v' or cd ~+<number>
setopt AUTO_PUSHD

todo_count(){
  # # if $(which todo.sh &> /dev/null)
  # if $(which task &> /dev/null)
  # then
  #   # num=$(echo $(todo.sh ls | grep "^[0-9]" | wc -l))
  #   num=$(echo $(task status:pending proj:INBOX count))
  #   let todos=num
  #   if [ $todos != 0 ]
  #   then
  #     echo "$todos"
  #   else
  #     echo ""
  #   fi
  # else
  #   echo ""
  # fi
}
todo_count2(){
  # if $(which todo.sh &> /dev/null)
  # if $(which task &> /dev/null)
  # then
  #   # num=$(echo $(todo.sh ls | grep "^[0-9]" | wc -l))
  #   num=$(echo $(task status:pending count))
  #   let todos=num
  #   if [ $todos != 0 ]
  #   then
  #     echo "$todos"
  #   else
  #     echo ""
  #   fi
  # else
  #   echo ""
  # fi
}

function zle-line-init zle-keymap-select {
RPS1="${${KEYMAP/vicmd/>○<I:$(todo_count) T:$(todo_count2)>}/(main|viins)/±<I:$(todo_count) T:$(todo_count2)>}"
    RPS2=$RPS1
    zle reset-prompt
}
  zle -N zle-line-init
  zle -N zle-keymap-select

# Set Vi Mode
bindkey -v

# Function to add nocorrect for certain commands, one per line in .zsh_nocorrect
# It fails if any line is a blankline
if [ -f ~/.config/zsh.d/.zsh_nocorrect ]; then
    while read -r COMMAND; do
        alias $COMMAND="nocorrect $COMMAND"
    done < ~/.config/zsh.d/.zsh_nocorrect
fi

# for zsh-completions
fpath=(/usr/local/share/zsh-completions $fpath)

clear

# Finally, source all the files in zsh.d
# executed in alpha order
for zshd in $(ls -A ${HOME}/.config/zsh.d/^*.(z)sh$); do
	. "${zshd}"
done
