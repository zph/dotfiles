# Defined in /var/folders/tx/txv80n855sv10ztmg1yyhkjr0000gn/T//fish.YPiEvk/wkcd.fish @ line 2
function wkcd --description 'Create git worktree and move into that folder' --argument branch
	set project (basename $PWD)
  set output $HOME/src/worktree/$project/$branch
  mkdir -p $HOME/src/worktree/$project
  echo $output
  git worktree add $output $branch
  echo $output
  cd $output
end
