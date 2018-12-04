FILENAME=$HOME/.nix-profile/etc/profile.d/nix.sh
if [[ -f $FILENAME ]];then
  source "$FILENAME"
fi
