#!/usr/bin/env bash
# installer.sh [--check] [--groups core,nvim,extra] [--nvim] [--yes]
#
# Installs the tools listed in packages.tsv that are missing on this machine,
# with pacman (Arch and derivatives) or apt (Debian, Ubuntu, WSL). Only missing
# commands are installed; tools without a package for this distro get their
# note printed instead.
#
#   --check    only report what is missing, install nothing (no sudo)
#   --groups   which groups to cover (default core,nvim; extra is opt-in)
#   --nvim     afterwards build nvim's plugins and install its mason tools
#              headless (Lazy sync, then MasonToolsInstallSync)
#   --yes      don't ask before installing
#
# Agent tooling (claude, herdr, devcontainer CLI) and the stow links are
# setup-agents' job: run scripts/.local/bin/setup-agents after this.

set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
manifest=$here/packages.tsv
check=0 nvim=0 yes=0 groups=core,nvim

while (( $# )); do
    case $1 in
        --check) check=1 ;;
        --nvim) nvim=1 ;;
        --yes|-y) yes=1 ;;
        --groups) groups=${2:?--groups needs a value}; shift ;;
        -h|--help) sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "unknown option: $1" >&2; exit 2 ;;
    esac
    shift
done

. /etc/os-release
case " ${ID:-} ${ID_LIKE:-} " in
    *" arch "*) pm=arch ;;
    *" debian "*|*" ubuntu "*) pm=apt ;;
    *) echo "unsupported distro ${ID:-?}: install the commands in packages.tsv by hand" >&2; pm=none ;;
esac

declare -A want=()
missing=() manual=()
while IFS=$'\t' read -r cmd group arch apt note; do
    [[ -z $cmd || $cmd == \#* ]] && continue
    [[ ",$groups," == *",$group,"* ]] || continue
    command -v "$cmd" >/dev/null && continue
    # Debian's renamed binaries count as present when the plain name is missing.
    [[ $pm == apt && $cmd == fd ]] && command -v fdfind >/dev/null && { manual+=("fd: ${note}"); continue; }
    [[ $pm == apt && $cmd == bat ]] && command -v batcat >/dev/null && { manual+=("bat: ${note}"); continue; }
    missing+=("$cmd")
    case $pm in arch) pkgs=$arch ;; apt) pkgs=$apt ;; *) pkgs=- ;; esac
    if [[ $pkgs == - ]]; then
        manual+=("$cmd: ${note:-no package for this distro}")
    else
        for p in $pkgs; do want[$p]=1; done
        [[ -n ${note:-} && $pm == apt && ($cmd == fd || $cmd == bat) ]] && manual+=("$cmd: $note")
    fi
done < "$manifest"

if (( ${#missing[@]} == 0 )); then
    echo "all commands of groups $groups are present"
else
    echo "missing ($groups): ${missing[*]}"
fi

pkgs=("${!want[@]}")
if (( ${#pkgs[@]} )); then
    case $pm in
        arch) install=(sudo pacman -S --needed --noconfirm "${pkgs[@]}") ;;
        apt) install=(sudo apt-get install -y "${pkgs[@]}") ;;
    esac
    echo "to install: ${install[*]}"
    if (( ! check )); then
        if (( ! yes )); then
            read -r -p "install now? [Y/n] " ok
            [[ -z $ok || $ok == [yY]* ]] || { echo "skipped"; pkgs=(); }
        fi
        if (( ${#pkgs[@]} )); then
            [[ $pm == apt ]] && sudo apt-get update
            "${install[@]}"
        fi
    fi
fi

if (( ${#manual[@]} )); then
    echo
    echo "by hand:"
    printf '  %s\n' "${manual[@]}"
fi

if (( nvim && ! check )); then
    command -v nvim >/dev/null || { echo "nvim missing: skipping --nvim" >&2; exit 1; }
    echo
    echo "nvim: syncing plugins (Lazy) ..."
    nvim --headless "+Lazy! sync" +qa
    echo "nvim: installing mason tools ..."
    nvim --headless "+MasonToolsInstallSync" +qa
    echo "nvim: done"
fi
