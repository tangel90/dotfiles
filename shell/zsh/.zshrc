# tmux init
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
    sessions=$(tmux list-sessions 2>/dev/null)
    if [ -z "$sessions" ]; then
        tmux new-session -A -s "workspace0"
    else
        tmux attach
    fi
fi

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
   mkdir -p "$(dirname $ZINIT_HOME)"
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
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit wait lucid for MichaelAquilina/zsh-autoswitch-virtualenv

# Add in snippets
# zinit snippet OMZP::git
# zinit snippet OMZP::sudo
# zinit snippet OMZP::archlinux
zinit ice lucid wait
zinit snippet OMZP::fzf
# zinit snippet OMZP::aws
# zinit snippet OMZP::kubectl
# zinit snippet OMZP::kubectx
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

# >>> Shell integrations >>>
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(fzf --zsh)"
eval "$(zoxide init zsh --cmd cd)"
eval "$(direnv hook zsh)"
# <<< Shell integrations <<<

bindkey -r '^L' #removes C-l for clear-console
bindkey -v
bindkey -M viins '^F' forward-char
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# zle -N yazi-cwd # Widget breaks yazi on some machines ...

alias c="clear"
alias ls="ls --color=auto -X"
alias da='direnv allow'
alias dd='direnv deny'
alias e="yazi-cwd"
alias fd="fd --follow --hidden --exclude .git"
alias lg="lazygit"
alias lt="exa --tree --level=2"
alias ll="exa --long --header --sort=type --icons --no-permissions --no-user"
alias la="exa --long --header --all --sort=type --icons --no-permissions --no-user" 
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
    local CONFIG_DIRS=$(find -L $XDG_CONFIG_HOME -type d -name "nvim*")
    selected_config=$(echo "$CONFIG_DIRS" | fzf --prompt "Nvim Config > ")

    [[ -z $selected_config ]] && echo "No config selected" && return

    echo "Config selected: $selected_config"
    NVIM_APPNAME=$(basename $selected_config) nvim $@
}

function yazi-cwd() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

function load-nvm() {
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}
