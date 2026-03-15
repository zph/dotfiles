" Load main config from ~/.vim/init.vim
" This bridges the XDG config path (~/.config/nvim/) to the shared
" vim config at ~/.vim/init.vim managed by chezmoi.
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vim/init.vim
