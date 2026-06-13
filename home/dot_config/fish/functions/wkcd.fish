function wkcd --description 'Create or open a wk worktree and move into it'
  if test (count $argv) -eq 0
    command wk help
    return 1
  end

  set -l args $argv
  switch $args[1]
    case new open ro read-only clone
    case '*'
      set args new $args
  end

  set -l output (command wk $args 2>&1)
  set -l code $status
  printf "%s\n" $output

  if test $code -ne 0
    return $code
  end

  set -l previous
  set -l target
  for line in $output
    switch $previous
      case 'Created worktree:' 'Created detached update-only view:' 'Created detached worktree:' 'Created local clone:'
        set target $line
        break
    end
    set previous $line
  end

  if test -n "$target"; and test -d "$target"
    cd "$target"
  else
    echo "wkcd: could not find created worktree path in wk output" >&2
    return 1
  end
end
