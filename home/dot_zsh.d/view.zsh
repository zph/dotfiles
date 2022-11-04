## Thanks to @fnichols
# Launch view using input from STDIN initialized with a desired filetype.
#
# @param [String] vim/view filetype, such as `json`, `yaml`, etc.
viewin() {
  view -c "set ft=$1" -
}
