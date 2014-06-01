### vim:ft=zsh:foldmethod=marker

### check_com(): check if a command exists
### eg: check_com "vim -p"
function check_com() {
    #setopt localoptions xtrace
    local words
    local -i comonly
    local cmd

    function zis_317(){
      # B/C yolo
      true
    }

    if [[ ${1} == '-c' ]] ; then
        (( comonly = 1 ))
        shift
    else
        (( comonly = 0 ))
    fi

    if (( ${#argv} != 1 )) ; then
        printf 'usage: check_com [-c] <command>\n' >&2
        return 1
    fi

    if zis_317 "atleast" ; then
        words=(${(z)1})
    else
        ### <3.1.7 does not know (z); this makes things less flexible. Oh well...
        words=(${(s: :)1})
    fi
    cmd=${words[1]}

    if (( comonly > 0 )) ; then
        if ! zis_317 "atleast"; then
            [[ -x $(which $cmd) ]] && return 0
        else
            [[ -n ${commands[$cmd]}  ]] && return 0
        fi
        return 1
    fi

    zis_317 "atleast" || return 1

    if   [[ -n ${commands[$cmd]}    ]] \
      || [[ -n ${functions[$cmd]}   ]] \
      || [[ -n ${aliases[$cmd]}     ]] \
      || [[ -n ${reswords[(r)$cmd]} ]] ; then

        return 0
    fi

    return 1
}

### check_com_print(): check_com() + error msg
function check_com_print() {
    local command

    if [[ $1 == '-c' ]]; then
        command=$2
    else
        command=$1
    fi
    if ! check_com "$@" ; then
        printf '%s not found in $path.\n' ${command}
        return 1
    fi
    return 0
}
