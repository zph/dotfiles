# Quick jumping to n-th arguments by pressing Alt-number
# taken from https://github.com/clvv/dotfiles/blob/master/.zsh/bindkey.zsh
bindkey '^[1' beginning-of-line
bindkey -s '^[2' '^A^[f'
bindkey -s '^[3' '^A^[f^[f'
bindkey -s '^[4' '^A^[f^[f^[f'
bindkey -s '^[5' '^A^[f^[f^[f^[f'
bindkey -s '^[6' '^A^[f^[f^[f^[f^[f'
bindkey -s '^[7' '^A^[f^[f^[f^[f^[f^[f'
bindkey -s '^[8' '^A^[f^[f^[f^[f^[f^[f^[f'
bindkey -s '^[9' '^A^[f^[f^[f^[f^[f^[f^[f^[f'

bindkey -s '^[S' '^Asudo ^E' # Alt-S-s add sudo
