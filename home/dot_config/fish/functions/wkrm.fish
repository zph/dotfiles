# Defined in /var/folders/tx/txv80n855sv10ztmg1yyhkjr0000gn/T//fish.hywiHw/wkrm.fish @ line 1
function wkrm --description 'Worktree removal' --argument dir
	if test -n $dir
    set dir $PWD
  end

  git worktree remove $dir
end
