## Automatically pushd - then I can go to an old dir with cd - <tab> (pick no.)
setopt AUTOPUSHD
export DIRSTACKSIZE=11 # stack size of eleven gives me a list with ten entries
# SSH Completion (complete from hosts files, .ssh/config,known_hosts lists, etc)
zstyle ':completion:*:scp:*' tag-order \
   files 'hosts:-host hosts:-domain:domain hosts:-ipaddr"IP\ Address *'
zstyle ':completion:*:scp:*' group-order \
   files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' tag-order \
   'hosts:-host hosts:-domain:domain hosts:-ipaddr"IP\ Address *'
zstyle ':completion:*:ssh:*' group-order \
   hosts-domain hosts-host hosts-ipaddr
# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
zstyle ':completion:*:*:kill:*:processes' command 'ps --forest -A -o pid,user,cmd'
zstyle ':completion:*:processes-names' command 'ps axho command' 
