# DIRSTACKFILE="$HOME/.cache/zsh_dirs"
# if [[ -f $DIRSTACKFILE ]] && [[ $#dirstack -eq 0 ]]; then
#   dirstack=( ${(f)"$(< $DIRSTACKFILE)"} )
#   [[ -d $dirstack[1] ]] && cd $dirstack[1]
# fi
# chpwd() {
#   print -l $PWD ${(u)dirstack} >$DIRSTACKFILE
# }

# DIRSTACKSIZE=20

# setopt autopushd pushdsilent pushdtohome

# ## Remove duplicate entries
# setopt pushdignoredups

# ## This reverts the +/- operators.
# setopt pushdminus
