# multiplexer init: herdr (launches or attaches its persistent session), tmux
# where herdr isn't installed. HERDR_ENV/TMUX keep panes from nesting.
if [ "$PS1" != "" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ "$TMUX" = "" ] && [ "$KUBECONFIG" = "" ] && [ "$HERDR_ENV" != "1" ]; then
    if command -v herdr &> /dev/null; then
        herdr
    elif command -v tmux &> /dev/null; then
        sessions=$(tmux list-sessions 2>/dev/null)
        if [ "$sessions" = "" ]; then
            tmux new-session -A
        else
            tmux attach
        fi
    fi
fi

# Inside herdr, run claude in its own pane rather than in Claude's background
# service. The service hosts every session in shared workers, which carry the
# HERDR_* env of whichever pane first started the service — so herdr's
# integration, which works through per-pane env, ends up tracking a viewer: no
# resume after restart, no hfork, hooks reporting to a stale pane. Costs
# background jobs (claude agents, /background, --bg) in herdr panes.
if [ "$HERDR_ENV" = "1" ]; then
    export CLAUDE_CODE_DISABLE_AGENT_VIEW=1
fi

export GPG_TTY="$TTY"
gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# Set the directory we want to store zinit and plugins
# Download Zinit, if it's not there yet
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname "$ZINIT_HOME")"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light jeffreytse/zsh-vi-mode
zinit light Aloxaf/fzf-tab
zinit ice wait lucid; zinit light zsh-users/zsh-syntax-highlighting
zinit ice wait lucid; zinit light zsh-users/zsh-completions
zinit ice wait lucid atload"_zsh_autosuggest_start"; zinit light zsh-users/zsh-autosuggestions

# Add in snippets
# zinit snippet OMZP::git
# zinit snippet OMZP::sudo
# zinit snippet OMZP::archlinux
zinit ice lucid wait
zinit snippet OMZP::fzf
# zinit snippet OMZP::aws
# zinit snippet OMZP::command-not-found

autoload -Uz compinit && compinit
zinit cdreplay -q

HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls $realpath'

bindkey -r '^L' #removes C-l for clear-console
bindkey -v
bindkey -M viins '^F' forward-char
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# zle -N yazi-cwd # Widget breaks yazi on some machines ...

alias c="clear"
alias da='direnv allow'
alias dd='direnv deny'
alias e="yazi-cwd"
alias fd="fd --follow --hidden --exclude .git"
alias lg=gpg-unlock-lazygit
alias lt="exa --tree --level=2"
alias ll="exa --long --header --sort=type --icons --no-permissions --no-user"
alias la="exa --long --header --all --sort=type --icons --no-permissions --no-user" 
# Google throttles translate-shell by IP ("Rate limiting"); bing has no such
# limit here. Override per call with `trans -e google ...` when needed.
alias trans="trans -e bing"
alias grep="rg"
alias cat="bat"
alias vim="nvim"
alias vimdev='NVIM_APPNAME=nvim-dev nvim'
alias nvr="nvim --listen $HOME/.local/tmp/nvimsocket"

function gpg-unlock-lazygit() {
    git fetch
    lazygit
}

function vv() {
    local CONFIG_DIRS=$(find -L "$XDG_CONFIG_HOME" -type d -name "nvim*")
    selected_config=$(echo "$CONFIG_DIRS" | fzf --prompt "Nvim Config > ")

    [[ -z $selected_config ]] && echo "No config selected" && return

    echo "Config selected: $selected_config"
    NVIM_APPNAME=$(basename "$selected_config") nvim "$@"
}

function yazi-cwd() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ "$cwd" != "" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

function load-nvm() {
  if [ -n $NVM_DIR ]; then
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
  else
    echo "NVM_DIR not defined."
  fi
}

# >>> Shell hooks >>>
if command -v kubectl &>/dev/null; then
    source <(kubectl completion zsh)
    zinit snippet OMZP::kubectl
    alias kk=k9s
    # zinit snippet OMZP::kubectx
fi

eval "$(fzf --zsh)"
eval "$(zoxide init zsh --cmd cd)"
eval "$(direnv hook zsh)"

# Replace direnv's precmd hook with one that drops its $ZSH_EVAL_CONTEXT guard.
#
# direnv's own _direnv_hook starts with:
#
#   [[ ! -o interactive || $ZSH_SUBSHELL -ne 0 || \
#      ( -n $ZSH_EVAL_CONTEXT && $ZSH_EVAL_CONTEXT != toplevel(:[a-z]#func|)# ) ]] && return
#
# In this shell $ZSH_EVAL_CONTEXT is plain "shfunc" at precmd time, not
# "toplevel:shfunc" — something in the startup chain (p10k's instant prompt,
# zinit or zsh-vi-mode, all of which sit in precmd_functions) runs the prompt
# cycle below top level. So the third clause matches, the hook returns
# immediately, and direnv never loads. It is registered and invoked every
# prompt, and silently does nothing — no load line, no error, nothing.
#
# Only the precmd path is affected; chpwd still gets a passing context, which
# is why `cd` into a directory worked while a shell STARTED there (what
# tmux-sessionizer does, `new-session -c "$selected"`) never loaded at all.
#
# The interactive and subshell checks are kept — those are the meaningful ones.
# chpwd_functions is left on direnv's own hook since it works there.
_direnv_precmd_hook() {
    [[ -o interactive && $ZSH_SUBSHELL -eq 0 ]] || return
    eval "$(direnv export zsh)"
}
precmd_functions=(_direnv_precmd_hook ${precmd_functions:#_direnv_hook})
# <<< Shell hooks <<<

# >>> Personal (untracked) interactive config >>>
# Loaded after compinit so compdef/zstyle/completions work.
# Env vars belong in $PERSONALCONFIG/* (sourced from .zprofile).
if [[ -d "$PERSONALCONFIG/zsh" ]]; then
  for f in "$PERSONALCONFIG"/zsh/*.zsh(N.); do
    source "$f"
  done
  unset f
fi
# <<< Personal (untracked) interactive config <<<
