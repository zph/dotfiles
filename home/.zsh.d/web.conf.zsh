alias hdr="curl -I "
alias ccurl="curl -H Pragma:"

# Open things

web(){
  case $1 in
  "g" | "google")
    shift 1
    o "http://www.google.com/search?q=$@"
    ;;
  "t" | "thesaurus")
    shift 1
    o "http://thesaurus.com/browse/$@?s=t"
    ;;
  "d" | "define")
    shift 1
    o "http://www.onelook.com/?w=$@"
    ;;
  *)
    return 1
    ;;
  esac

}

# google() {
#   open "http://www.google.com/search?q=$1"
# }
