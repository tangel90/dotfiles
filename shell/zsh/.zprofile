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

# SSH_AUTH_SOCK set to GPG to enable using gpgagent as the ssh agent.
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

alias da='direnv allow'
alias dd='direnv deny'
alias grep="rg"
alias vimdev='NVIM_APPNAME=nvim-dev nvim'
alias c="clear"
alias ls="ls --color=auto -X"
alias vim="nvim"
alias lg="lazygit"
alias vc="fd . '$HOME/.config' --type f --follow --hidden --exclude .git | fzf-tmux --border --preview='bat --style=numbers --color=always {}' -p 80%,80% | xargs nvim"
alias e="yazi-cwd"
alias nvr="nvim --listen $HOME/.local/tmp/nvimsocket"
alias fd="fd --follow --hidden --exclude .git"

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

function tmux-hide-pane() {
    tmux select-pane -t :.+
    tmux resize-pane -Z
}

function tmux-run-python() {
    local file file_name dir pane target="run-python"
    local NVIM_LISTEN_ADDRESS="$HOME/.local/tmp/nvimsocket"
    file="$(nvim --server "$NVIM_LISTEN_ADDRESS" --remote-expr 'expand("%:p")')"
    [[ -f "$file" && "$file" == *.py ]] || { tmux display-message "Not a python file"; return; }

    dir="$(dirname "$file")"
    # See if the pane already exists
    pane=$(tmux list-panes -a -F '#{pane_id} #{pane_title}' | awk -v target="$target" '$2==target {print $1; exit}')
    if [[ -z "$pane" ]]; then
        pane=$(tmux split-window -v -p 40 -c "$dir" -P -F '#{pane_id}' "tmux select-pane -T '$target'; exec \$SHELL")
    fi
    tmux select-pane -T \"$target\"
    # Send the python command to the pane
    file_name=$(basename  "$file")
    tmux send-keys -t "$pane" "cd '$dir' && python '$file_name'" C-m
}

function tmux-open-lazygit() {
    if ! ls -a | grep -q '^\.git$'; then
        return 0
    fi

    if [ -z "$TMUX" ]; then
        echo "Not inside tmux session"
        return 1
    fi

    if ! tmux list-windows 2>/dev/null | grep -q '^lazygit$'; then
        tmux new-window -n lazygit "lazygit"
    fi

    tmux select-window -t lazygit
}

# >>> initialize environment >>>
if [ -d "$LOCALCONFIG" ]; then
    for i in $(find -L "$LOCALCONFIG" -type f); do
        source "$i"
    done
fi
# <<< initialize environment <<<
