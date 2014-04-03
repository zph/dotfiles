# function shuttle_start () {
#   remote_server=${SSHUTTLE_REMOTE}
#   if [[ $SSHUTTLE_REMOTE == '']];then
#     echo "No sshuttle found. Make sure it is visible in path"
#     exit 1
#   fi
#   if [[ -x sshuttle ]]; then
#     echo $remote_server
#     #sshuttle --dns -vvr $remote_server 0/0
#   else
#     echo "No sshuttle found. Make sure it is visible in path"
#     exit 1
#   fi
# }
