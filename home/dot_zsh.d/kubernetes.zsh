alias kd="kubectl describe"
alias kg="kubectl get"

# Doesn't work here but does in the function when already called from a
# shell
# Credit: https://frederic-hemberger.de/articles/speed-up-initial-zsh-startup-with-lazy-loading/
# if [ $commands[kubectl] ]; then
#   # Placeholder 'kubectl' shell function:
#   # Will only be executed on the first call to 'kubectl'
#   kubectl() {
#     # Remove this function, subsequent calls will execute 'kubectl' directly
#     unfunction "$0"
#     # Load auto-completion
#     source <(kubectl completion zsh)
#     # Execute 'kubectl' binary
#     $0 "$@"
#   }
# fi

lazyload_init_kubectl(){
  eval "$(kubectl completion zsh)"
}

# This command is used a LOT both below and in daily life
lazyload_init_k(){
  source <(kubectl completion zsh | sed -e 's/__start_kubectl kubectl/__start_kubectl k/g' -e 's/#compdef kubectl/#compdef k/g' -e 's/_complete kubectl/_complete k/g')
}


# ------------- kubectl.plugin.zsh
# if (( $+commands[kubectl] )); then
#   __KUBECTL_COMPLETION_FILE="${ZSH_CACHE_DIR:-$HOME/tmp}/kubectl_completion"

#   if [[ ! -f $__KUBECTL_COMPLETION_FILE ]]; then
#     kubectl completion zsh >! $__KUBECTL_COMPLETION_FILE
#   fi

#   [[ -f $__KUBECTL_COMPLETION_FILE ]] && source $__KUBECTL_COMPLETION_FILE

#   unset __KUBECTL_COMPLETION_FILE
# fi

alias krm='kubectl delete'
alias krmf='kubectl delete -f'
alias krming='kubectl delete ingress'
alias krmingl='kubectl delete ingress -l'
alias krmingall='kubectl delete ingress --all-namespaces'
alias ka='kubectl apply -f'
alias klo='kubectl logs -f'
alias kex='kubectl exec -i -t'

# Manage configuration quickly to switch contexts between local, dev ad staging.
alias kcuc='kubectl config use-context'
alias kcsc='kubectl config set-context'
alias kcdc='kubectl config delete-context'
alias kccc='kubectl config current-context'

# General aliases
alias kdel='kubectl delete'
alias kdelf='kubectl delete -f'

# Pod management.
alias kgp='kubectl get pods'
alias kgpw='kgp --watch'
alias kgpwide='kgp -o wide'
alias kep='kubectl edit pods'
alias kdp='kubectl describe pods'
alias kdelp='kubectl delete pods'

# get pod by label: kgpl "app=myapp" -n myns
alias kgpl='kgp -l'

# Service management.
alias kgs='kubectl get svc'
alias kgsw='kgs --watch'
alias kgswide='kgs -o wide'
alias kes='kubectl edit svc'
alias kds='kubectl describe svc'
alias kdels='kubectl delete svc'

# Ingress management
alias kgi='kubectl get ingress'
alias kei='kubectl edit ingress'
alias kdi='kubectl describe ingress'
alias kdeli='kubectl delete ingress'

# Namespace management
alias kgns='kubectl get namespaces'
alias kens='kubectl edit namespace'
alias kdns='kubectl describe namespace'
alias kdelns='kubectl delete namespace'

# ConfigMap management
alias kgcm='kubectl get configmaps'
alias kecm='kubectl edit configmap'
alias kdcm='kubectl describe configmap'
alias kdelcm='kubectl delete configmap'

# Secret management
alias kgsec='kubectl get secret'
alias kdsec='kubectl describe secret'
alias kdelsec='kubectl delete secret'

# Deployment management.
alias kgd='kubectl get deployment'
alias kgdw='kgd --watch'
alias kgdwide='kgd -o wide'
alias ked='kubectl edit deployment'
alias kdd='kubectl describe deployment'
alias kdeld='kubectl delete deployment'
alias ksd='kubectl scale deployment'
alias krsd='kubectl rollout status deployment'

# Rollout management.
alias kgrs='kubectl get rs'
alias krh='kubectl rollout history'
alias kru='kubectl rollout undo'

# Port forwarding
alias kpf="kubectl port-forward"

# Tools for accessing all information
alias kga='kubectl get all'
alias kgaa='kubectl get all --all-namespaces'

# Logs
alias kl='kubectl logs'
alias klf='kubectl logs -f'

# File copy
alias kcp='kubectl cp'

# Node Management
alias kgno='kubectl get nodes'
alias keno='kubectl edit node'
alias kdno='kubectl describe node'
alias kdelno='kubectl delete node'
