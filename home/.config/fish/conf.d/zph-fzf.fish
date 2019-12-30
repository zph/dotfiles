# Setting fd as the default source for fzf
set -gx FZF_DEFAULT_COMMAND 'fd --type f'

# To apply the command to CTRL-T as well
set -gx FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
