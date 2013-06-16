function S(){

__choose_sack_implementation(){
  # If so, use prioritized wrapper
  if [[ -x `which ag` ]];then
    command=`which sag`;
  elif [[ -x `which ack` ]];then
    command=`which sack`;
  elif [[ -x `which ack-grep` ]];then
    command=`which sack`;
  fi
}

__choose_bare_bin_implementation(){
  if [[ -x `which ag` ]]; then
    command=`which ag`;
  elif [[ -x `which ack` ]]; then
    command=`which ack`;
  elif [[ -x `which ack-grep` ]]; then
    command=`which ack`;
  else
    echo "No search tool found... install ag or ack (ack-grep) and also sack"
  fi
}

# Check for sack scripts (ack wrapper)
if [[ -x `which sack` ]];then
  __choose_sack_implementation
else
  __choose_bare_bin_implementation
fi

$command "$*"

}

alias spry='S "binding.pry"'
#TODO: write rpry, a tool to sed out a full line of text ie, remove line 'binding.pry'
