#!/usr/bin/env bash
# Ensure Xcode CLT is installed and license is accepted.
# Must run before homebrew install since brew depends on CLT.

set -eou pipefail

if ! xcode-select -p &>/dev/null; then
  echo "==> Installing Xcode Command Line Tools..."

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
    echo "==> Falling back to xcode-select --install..."
    xcode-select --install
    echo "==> Waiting for installation to complete..."
    until xcode-select -p &>/dev/null; do
      sleep 5
    done
  fi

  sudo rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
fi

# Accept Xcode/CLT license non-interactively if needed
if /usr/bin/xcrun clang 2>&1 | grep -q "license"; then
  echo "==> Accepting Xcode license..."
  sudo xcodebuild -license accept
fi
