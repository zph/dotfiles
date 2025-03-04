#####################################
# direnv (Setup, Aliases & Helpers) #
#####################################
# Credit: https://raw.githubusercontent.com/ejpcmac/config_files/bc9ee4e7363e4e0ca97f4addbdd9370b83048d3c/zsh/direnv.zsh

##
## Setup
##

# Too useful and want it to not be lazyloaded
eval "$(direnv hook zsh)"
# Used to allow for executing 1password integration inside direnv
export DIRENV_WARN_TIMEOUT=1m

##
## Aliases
##

# direnv
alias ds='direnv status'
alias de='direnv edit'
alias da='direnv allow'
alias dn='direnv deny'
alias dp='direnv prune'
alias dr='direnv reload'

# direnv script for persistent cached Nix shells
alias dcl='find .direnv -name "env-*" -and -not -name `readlink .direnv/default` -exec rm -rf {} +'
alias drs='rm -rf .direnv'
alias dar='direnv deny && rm -rf .direnv'
alias dl='find ~/Programmes -name .direnv'

##
## Helpers
##

nixify() {
    if [ ! -e ./.envrc ]; then
        cat > .envrc << 'EOF'
####################################
# Environment setup for Nix shells #
####################################

# From https://github.com/direnv/direnv/wiki/Nix#persistent-cached-shell
#
# Usage: use_nix [...]
#
# Load environment variables from `nix-shell`.
# If you have a `default.nix` or `shell.nix` one of these will be used and
# the derived environment will be stored at ./.direnv/env-<hash>
# and symlink to it will be created at ./.direnv/default.
# Dependencies are added to the GC roots, such that the environment remains persistent.
#
# Packages can also be specified directly via e.g `use nix -p ocaml`,
# however those will not be added to the GC roots.
#
# The resulting environment is cached for better performance.
#
# To trigger switch to a different environment:
# `rm -f .direnv/default`
#
# To derive a new environment:
# `rm -rf .direnv/env-$(md5sum {shell,default}.nix 2> /dev/null | cut -c -32)`
#
# To remove cache:
# `rm -f .direnv/dump-*`
#
# To remove all environments:
# `rm -rf .direnv/env-*`
#
# To remove only old environments:
# `find .direnv -name 'env-*' -and -not -name `readlink .direnv/default` -exec rm -rf {} +`
#
use_nix() {
    set -e

    local shell="shell.nix"
    if [[ ! -f "${shell}" ]]; then
        shell="default.nix"
    fi

    if [[ ! -f "${shell}" ]]; then
        fail "use nix: shell.nix or default.nix not found in the folder"
    fi

    local dir="${PWD}"/.direnv
    local default="${dir}/default"
    if [[ ! -L "${default}" ]] || [[ ! -d `readlink "${default}"` ]]; then
        local wd="${dir}/env-`md5sum "${shell}" | cut -c -32`" # TODO: Hash also the nixpkgs version?
        mkdir -p "${wd}"

        local drv="${wd}/env.drv"
        if [[ ! -f "${drv}" ]]; then
            log_status "use nix: deriving new environment"
            IN_NIX_SHELL=1 nix-instantiate --add-root "${drv}" --indirect "${shell}" > /dev/null
            nix-store -r `nix-store --query --references "${drv}"` --add-root "${wd}/dep" --indirect > /dev/null
        fi

        rm -f "${default}"
        ln -s `basename "${wd}"` "${default}"
    fi

    local drv=`readlink -f "${default}/env.drv"`
    local dump="${dir}/dump-`md5sum ".envrc" | cut -c -32`-`md5sum ${drv} | cut -c -32`"

    if [[ ! -f "${dump}" ]] || [[ "${XDG_CONFIG_DIR}/direnv/direnvrc" -nt "${dump}" ]]; then
        log_status "use nix: updating cache"

        old=`find "${dir}" -name 'dump-*'`
        nix-shell "${drv}" --show-trace "$@" --run 'direnv dump' > "${dump}"
        rm -f ${old}
    fi

    direnv_load cat "${dump}"

    watch_file "${default}"
    watch_file shell.nix
    if [[ ${shell} == "default.nix" ]]; then
        watch_file default.nix
    fi
}

use nix
EOF
        direnv allow
    fi

    if [ ! -e shell.nix ]; then
        cat > shell.nix << 'EOF'
{ pkgs ? import <nixpkgs> {} }:

with pkgs;

mkShell {
  buildInputs = [
    # Add dependencies here.
  ];
}
EOF
    $EDITOR shell.nix
    fi
}
