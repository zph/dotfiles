source /usr/local/share/chruby/chruby.sh
# RUBIES+=(~/.rvm/rubies/*)
source /usr/local/share/chruby/auto.sh

# Credit: https://github.com/postmodern/chruby/wiki/Implementing-an-'after-use'-hook
save_function()
{
  local ORIG_FUNC="$(declare -f $1)"
  local NEWNAME_FUNC="$2${ORIG_FUNC#$1}"
  eval "$NEWNAME_FUNC"
}

save_function chruby old_chruby

chruby() {
  old_chruby $*
  readonly PATHS_TO_PREFIX_BEFORE_CHRUBY="./.bundle/.binstubs"
  local modified_path=$(echo $PATH | sed 's/:.\/.bundle\/.binstubs//')
  export PATH=${PATHS_TO_PREFIX_BEFORE_CHRUBY}:$modified_path
}

chruby 2.1.2
