# Path to Oh My Fish install.
set -q XDG_DATA_HOME
  and set -gx OMF_PATH "$XDG_DATA_HOME/omf"
  or set -gx OMF_PATH "$HOME/.local/share/omf"

# Lazy-load Oh My Fish - only initialize when omf command is used
# This significantly improves startup time
function omf --description "Oh My Fish - lazy loaded"
  # Remove this function to avoid recursion
  functions -e omf

  # Load Oh My Fish configuration
  source $OMF_PATH/init.fish

  # Call omf with original arguments
  omf $argv
end
