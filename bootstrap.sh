#!/usr/bin/env bash
# Bootstrap script for fresh macOS machines.
# Run this BEFORE chezmoi init to ensure Xcode CLT and git are available.
#
# Usage:
#   curl -fsLS https://raw.githubusercontent.com/zph/dotfiles/master/bootstrap.sh | bash

set -eou pipefail

echo "==> Checking for Xcode Command Line Tools..."

if ! xcode-select -p &>/dev/null; then
  echo "==> Installing Xcode Command Line Tools..."

  # Trigger the install-on-demand mechanism (same approach as Homebrew)
  sudo /usr/bin/touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress

  PROD=$(/usr/sbin/softwareupdate -l \
    | grep "\*.*Command Line" \
    | head -n 1 \
    | awk -F"*" '{print $2}' \
    | sed -e 's/^ *//' \
    | tr -d '\n')

  if [[ -n "$PROD" ]]; then
    echo "==> Installing: $PROD"
    sudo /usr/sbin/softwareupdate -i "$PROD" --verbose
  else
    echo "==> Falling back to xcode-select --install (follow the GUI prompt)..."
    xcode-select --install
    echo "==> Waiting for installation to complete..."
    until xcode-select -p &>/dev/null; do
      sleep 5
    done
  fi

  sudo rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
fi

# Accept Xcode license non-interactively
if /usr/bin/xcrun clang 2>&1 | grep -q "license"; then
  echo "==> Accepting Xcode license..."
  sudo xcodebuild -license accept
fi

echo "==> Xcode CLT ready. Installing chezmoi..."
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply zph
