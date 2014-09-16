# DEFAULT BEHAVIORS
# ```
#   v def conf       =>     vim /some/awkward/path/to/type/default.conf
#   j abc            =>     cd /hell/of/a/awkward/path/to/get/to/abcdef
#   m movie          =>     mplayer /whatever/whatever/whatever/awesome_movie.mp4
#   o eng paper      =>     xdg-open /you/dont/remember/where/english_paper.pdf
#   vim `f rc lo`    =>     vim /etc/rc.local
#   vim `f rc conf`  =>     vim /etc/rc.conf
# ```

# Fasd comes with some useful aliases by default:

# ```sh
# alias a='fasd -a'        # any
# alias s='fasd -si'       # show / search / select
# alias d='fasd -d'        # directory
# alias f='fasd -f'        # file
# alias sd='fasd -sid'     # interactive directory selection
# alias sf='fasd -sif'     # interactive file selection
# alias z='fasd_cd -d'     # cd, same functionality as j in autojump
# alias zz='fasd_cd -d -i' # cd with interactive selection
# ```#
# Setting filename to 00-fasd.zsh to help order
# the sourcing so that fasd doesn't overwrite
# my personal aliases

eval "$(fasd --init auto)"


unset zz
alias a='fasd -laR'        # any
function a1(){
  fasd -laR "$1" | head -1
}

alias zi='fasd_cd -d -i' # cd with interactive selection
alias ai='$(fasd -sia)'        # any
alias v='fasd -e vim' # quick opening files with vim
# alias gf='fasd -a git'
# alias m='fasd -e mplayerx' # quick opening files with mplayer
alias o='fasd -a -e xdg-open' # quick opening files with xdg-open
bindkey '^X^A' fasd-complete    # C-x C-a to do fasd-complete (fils and directories)
bindkey '^X^F' fasd-complete-f  # C-x C-f to do fasd-complete-f (only files)
bindkey '^X^D' fasd-complete-d  # C-x C-d to do fasd-complete-d (only directories)
_FASD_BACKENDS="native viminfo"
