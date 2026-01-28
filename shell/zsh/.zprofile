export XDG_CONFIG_HOME="$HOME/.config"
export PATH=$HOME/.local/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/lib
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/.ripgreprc"
export EDITOR="nvim"
export COLORTERM="truecolor"
export TMPDIR="$HOME/.local/tmp"
export PAGER="less"
export LESS="-SRXF"
export LOCALCONFIG="$HOME/.local/config"
export LOCALPROFILE="$LOCALCONFIG/.zprofile"
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export FZF_DEFAULT_OPTS='--height 40% --layout reverse --border top'
export FZF_DEFAULT_COMMAND='fd . --follow --hidden --exclude .git'
export FZF_TMUX_OPTS='-p80%,60%'

# SSH_AUTH_SOCK set to GPG. This enables using gpgagent as the ssh agent.
unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi

if [ -n "$TTY" ]; then
  export GPG_TTY=$(tty)
else
  export GPG_TTY="$TTY"
fi

# zle -N yazi-cwd # Widget breaks yazi on some machines ...
#
bindkey -r '^L' #removes C-l for clear-console
bindkey -v
bindkey -M viins '^F' forward-char
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

alias c="clear"
alias ls="ls --color=auto -X"

if [ -x "$(command -v nvim)" ]; then
  alias vim="nvim"
  alias vimdev='NVIM_APPNAME=nvim-dev nvim'
  alias nvr="nvim --listen $HOME/.local/tmp/nvimsocket"
fi

if [ -x "$(command -v direnv)" ]; then
  alias da='direnv allow'
  alias dd='direnv deny'
fi

if [ -x "$(command -v yazi)" ]; then
  alias e="yazi-cwd"
fi

if [ -x "$(command -v fd)" ]; then
  alias vc="fd . '$HOME/.config' --type f --follow --hidden --exclude .git | fzf-tmux --border --preview='bat --style=numbers --color=always {}' -p 80%,80% | xargs nvim"
  alias fd="fd --follow --hidden --exclude .git"
fi

if [ -x "$(command -v rg)" ]; then
  alias grep="rg"
fi

if [ -x "$(command -v lazygit)" ]; then
  alias lg="lazygit"
fi

if [ -x "$(command -v bat)" ]; then
    alias cat="bat"
fi

if [ -x "$(command -v exa)" ]; then
    alias lt="exa --tree --level=2"
    alias ll="exa --long --header --sort=type --icons --no-permissions --no-user"
    alias la="exa --long --header --all --sort=type --icons --no-permissions --no-user" 
fi

function gpg-unlock-lazygit() {
    command git fetch
    command lazygit
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

if [ -d "$LOCALCONFIG" ]; then
    for i in $(find -L "$LOCALCONFIG" -type f); do
        source "$i"
    done
fi
