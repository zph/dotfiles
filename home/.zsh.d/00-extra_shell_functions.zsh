# Source: http://stackoverflow.com/a/14106707 by Keith Thompson
# ============
# Example:
# fileName="$(cond "$useDefault" "$defaultName" "$customName").txt"
# ============
# Instead of
# ============
# if [ $useDefault ]; then
#   tmpname="$defaultName"
# else
#   tmpname="$customName"
# fi
# fileName="$dirName/$tmpname.txt"
#
# Or the ugly alternate
# a=$([[ $b = 5 ]] && echo "$c" || echo "$d"])

cond(){
  if [ "$1" ]; then
    echo "$2"
  else
    echo "$3"
  fi
}
