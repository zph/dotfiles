#Forwarding X11 with speedier compression & encryption
#ssh -X -C -c blowfish -i KEY_FILE_PATH -l root INSTANCE_PUBLIC_DNS
# yubikey_sock="/usr/local/var/run/yubikey-agent.sock"

# export SSH_AUTH_SOCK="$yubikey_sock"
export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
