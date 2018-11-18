png() {
  pngcrush -brute "$1"{,.} && ll "$1"{,.}
}
gif() {
  gifsicle -O "$1" -o "$1." && ll "$1"{,.}
}
jpeg() {
  jpegtran "$1" > "$1." && ll "$1"{,.}
}
