# Credit: https://github.com/benvan/sandboxd/blob/master/sandboxd
# Adapted to use ZSH-isms by @ZPH
# holds all hook descriptions in "cmd:hook" format
lazyload_hooks=()

# deletes all hooks associated with cmd
function lazyload_delete_hooks(){
  local cmd=$1
  for i in "${lazyload_hooks[@]}";
  do
    if [[ $i == "${cmd}:"* ]]; then
     local hook=$(echo $i | sed "s/.*://")
     unset -f "$hook"
    fi
  done
}

# prepares environment and removes hooks
function lazyload(){
  local cmd=$1

  (>&2 echo "lazyloading initialization for $cmd ...")
  lazyload_delete_hooks $cmd
  lazyload_init_$cmd
}

function lazyload_hook(){
  local cmd=$1
  local hook=$2

  lazyload_hooks+=( "${cmd}:${hook}" )
  eval "$hook(){ lazyload $cmd; $hook \$@ ; }"
}

# create hooks for the sandbox names themselves
function lazyload_initialize(){
  # call it as "lazyload_initialize "${(ok)functions}
  local funcs=($(echo "$@" | tr " " "\n" | grep lazyload_init_+ ))
  for f in ${funcs[@]};do
    local cmd=$(echo $f | sed s/lazyload_init_//)
    lazyload_hook $cmd $cmd;
  done
}
