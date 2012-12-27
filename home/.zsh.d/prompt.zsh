autoload -Uz vcs_info
 
zstyle ':vcs_info:*' stagedstr '%F{28}●'
zstyle ':vcs_info:*' unstagedstr '%F{11}●'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{11}%r'
zstyle ':vcs_info:*' enable git svn
precmd () {
	    if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]] {
		            zstyle ':vcs_info:*' formats ' [%F{green}%b%c%u%F{green}]'
			        } else {
				        zstyle ':vcs_info:*' formats ' [%F{green}%b%c%u%F{red}●%F{green}]'
					    }
					     
					        vcs_info
					}
					 
setopt prompt_subst
PROMPT='%F{green}%n@%m %c${vcs_info_msg_0_}%F{green} %(?/%F{green}/%F{red})%% %{$reset_color%}'

