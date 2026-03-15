#!/usr/bin/env bash
# Linter: ensure chezmoi scripts that use `brew` have the brew PATH guard clause.
# The install script (000) is exempt since it installs brew itself.

set -eou pipefail

SCRIPTS_DIR="home/.chezmoiscripts"
GUARD_PATTERN='opt/homebrew/bin/brew.*shellenv'
EXEMPT_PATTERN='000-install-homebrew'
failed=0

for script in "$SCRIPTS_DIR"/*; do
  [[ "$script" == *"$EXEMPT_PATTERN"* ]] && continue

  # Check if script references brew (ignoring comments)
  if grep -v '^\s*#' "$script" | grep -q '\bbrew\b'; then
    if ! grep -q "$GUARD_PATTERN" "$script"; then
      echo "FAIL: $script uses 'brew' but missing brew PATH guard clause"
      failed=1
    fi
  fi
done

if [[ $failed -eq 1 ]]; then
  echo ""
  echo "Add this guard to scripts that use brew:"
  echo '  if ! command -v brew &>/dev/null; then'
  echo '    if [[ -x /opt/homebrew/bin/brew ]]; then'
  echo '      eval "$(/opt/homebrew/bin/brew shellenv)"'
  echo '    elif [[ -x /usr/local/bin/brew ]]; then'
  echo '      eval "$(/usr/local/bin/brew shellenv)"'
  echo '    fi'
  echo '  fi'
  exit 1
fi
