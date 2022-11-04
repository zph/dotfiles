#!/bin/sh
# Credit: http://www.cubicrace.com/2016/03/efficient-logging-mechnism-in-shell.html

# Usage
# LOGENTRY
# updateUserDetails(){
#   ENTRY
#   DEBUG "Username: $1, Key: $2"
#   INFO "User details updated for $1"
#   RETURN
# }

# INFO "Updating user details..."
# updateUserDetails "cubicrace" "3445"

# rc=2

# if [ ! "$rc" = "0" ]
# then
#   ERROR "Failed to update user details. RC=$rc"
# fi
# LOGEXIT

function LOGGER(){
  local lvl="$1"
  local msg="$2"
  printf "[$(tstamp)] [$lvl]\t$msg\n"
}

function tstamp(){
  date "+%Y-%m-%d %H:%M:%S"
}

function script_name(){
  basename "$0"
}

function LOGENTRY(){
  printf "$FUNCNAME: $(script_name)\n"
}

function LOGEXIT(){
  printf "$FUNCNAME: $(script_name)\n"
}

function ENTRY(){
  LOGGER "DEBUG" "> $FUNCNAME ${FUNCNAME[1]}"
}

function RETURN(){
  LOGGER "DEBUG" "> $FUNCNAME ${FUNCNAME[1]}"
}

function INFO() {
  LOGGER "INFO" "$1"
}

function ERROR() {
  LOGGER "ERROR" "$1"
}

function DEBUG() {
  LOGGER "DEBUG" "$1"
}

