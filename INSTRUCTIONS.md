# Instructions

[ ] Log into ICloud
[ ] Update commandline tools for xcode-select --install in System Updates
[ ] Install dotfiles via chezmoi and install packages
```
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply zph
```

[ ] Install virtualization
```
tart clone ghcr.io/cirruslabs/macos-ventura-base:latest ventura-base
tart run ventura-base
```

[ ] Remove all apps from dock

- TODO - Setup security
    - Turn on Full disk encryption
    - Set “Security & Privacy” to “Require Password `immediately`” upon sleep
    - Find cheap app that instructs me to fix my security defaults
  - Set full disk access in “Security & Privacy”, click “Full Disk Access” and “+” and “Terminal”
      - In order to run tmutil settings

- Install omf
    - curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
- Move to fish shell
    - https://hackercodex.com/guide/install-fish-shell-mac-ubuntu/
- On m1, symlink /opt/local/bin/nvim into /usr/local/bin/nvim for viscode compatibility
[ ] Install setapp for many apps

- Change dock preferences to small, autohide and no animation
- Setup 3 finger drag in Accessibility > Pointer Control > Trackpad Options

## If programs won't start on mac from Brew Cask
- Select in finder
- Cmd-click > "Open"
- Approve non-signed binary

## References
- https://github.com/geerlingguy/mac-dev-playbook/blob/master/full-mac-setup.md
