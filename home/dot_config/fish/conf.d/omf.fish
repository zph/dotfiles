# Path to Oh My Fish install.
set -q XDG_DATA_HOME
  and set -gx OMF_PATH "$XDG_DATA_HOME/omf"
  or set -gx OMF_PATH "$HOME/.local/share/omf"

# Lazy-load Oh My Fish - only initialize when omf command is used
# This significantly improves startup time
function omf --description "Oh My Fish - lazy loaded"
  # Load Oh My Fish configuration (this defines the real omf function,
  # replacing this wrapper). We avoid `functions -e omf` because fish
  # caches the erasure and won't autoload the real omf afterward.
  source $OMF_PATH/init.fish
  source $OMF_PATH/pkg/omf/functions/omf.fish

  # Call omf with original arguments
  omf $argv
end
