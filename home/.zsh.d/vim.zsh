# from http://connermcd.wordpress.com/2012/05/20/updating-vim-pathogen-plugins/
#   modified from a vimscript back to straight shell
function vim_plugin_update() {
  ls -d ~/.vim/bundle/* |
     while read line; do
        # echo `basename "$line"`;
        cd "$line" && git pull; cd -;
     done
}

