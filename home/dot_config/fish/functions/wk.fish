# Delegate to ~/bin/wk. Keeping this function prevents an old generated fish
# function from shadowing the real helper.
function wk --description 'safe git worktree helper'
	command wk $argv
end
