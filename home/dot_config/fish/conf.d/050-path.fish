# https://fishshell.com/docs/current/cmds/fish_add_path.html
# prepend, move if currently in path, -g is like export
fish_add_path -g -m -p $HOMEBREW_PATH/bin
fish_add_path -g -m -p '/usr/local/bin'
fish_add_path -g -m -p /nix/var/nix/profiles/default/bin
fish_add_path -g -m -p $HOME/.nix-profile/bin
fish_add_path -g -m -p $HOME/.deno/bin
fish_add_path -g -m -p $HOME/.cargo/bin
fish_add_path -g -m -p $HOME/.local/bin
fish_add_path -g -m -p $HOME/.hermit/bin
fish_add_path -g -m -p $HOME/bin
fish_add_path -g -m -p $HOME/bin/git
fish_add_path -g -m -p $HOME/bin/vendor
