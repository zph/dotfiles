function mkdircd () { 
	mkdir -p "$@" && eval cd "\"\$$#\"";
}
# move up in dir structure by typing up + #_of_levels
# up() { [ $(( $1 + 0 )) -gt 0 ] && cd $(eval "printf '../'%.0s {1..$1}"); }
up () { if [ "${1/[^0-9]/}" == "$1" ]; then p=./; for i in $(seq 1 $1); do p=${p}../; done; cd $p; else echo 'usage: up N'; fi }

headless() {
  [ $# -lt 1 ] && echo "Usage: $FUNCNAME vm_name" && return
  VBoxHeadless -startvm $1&
}

reload () {
          exec "${SHELL}" "$@"
}

poweroff() { _confirm_wrapper --root $0 "$@"; }
reboot() { _confirm_wrapper --root $0 "$@"; }
hibernate() { _confirm_wrapper --root $0 "$@"; }
