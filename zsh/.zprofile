export XDG_CONFIG_HOME="$HOME/.config"
export PATH=$HOME/.local/bin:/usr/local/bin:$PATH
export PATH=$PATH:$HOME/.local/scripts
export LD_LIBRARY_PATH=/usr/local/lib
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/.ripgreprc"
export EDITOR="nvim"
export TERM="xterm-256color"
export COLORTERM="truecolor"
export TMPDIR="$HOME/.local/tmp"

export LOCALCONFIG="$HOME/.local/config"
export LOCALPROFILE="$LOCALCONFIG/.zprofile"
export LOGDIR="$HOME/dev/logs"
export DEVLOG="$LOGDIR/dev.log"
export PYLOG="$LOGDIR/python.log"

export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

export FZF_DEFAULT_OPTS='--height 40% --layout reverse --border top'
export FZF_DEFAULT_COMMAND='fd . --hidden --exclude .git'
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
alias tls="tmux-list-session"
alias ls="ls --color=auto -X"
alias vim="nvim"
alias cat="bat"
alias lg="lazygit"
alias v="fd . --type f --hidden --exclude .git | fzf-tmux --border --preview='bat --style=numbers --color=always {}' -p 80%,80% | xargs nvim"
alias chat="chatgpt"
alias nvr="nvim --listen $HOME/.local/tmp/nvimsocket"

if [ -x "$(command -v fdfind)" ]; then
    alias fd="fdfind"
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


function load_conda() {
    __conda_setup="$('/home/thomas/.local/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/home/thomas/.local/opt/miniconda3/etc/profile.d/conda.sh" ]; then
            . "/home/thomas/.local/opt/miniconda3/etc/profile.d/conda.sh"
        else
            export PATH="/home/thomas/.local/opt/miniconda3/bin:$PATH"
        fi
    fi
    unset __conda_setup
}

function yazi-cwd() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

function tmux-list-session () {
    if tmux list-sessions >/dev/null 2>&1; then
        selected=$(tmux list-sessions | fzf | cut -d: -f1) && [ -n "$selected" ] && tmux attach-session -t "$selected"
    else
        echo "No active tmux sessions."
    fi
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

function tmux-open-claude() {
    if ! tmux has-session -t llm 2>/dev/null; then
        echo "Creating new session."
        tmux new-session -d -s llm -n Claude -c "$PROJECTS_HOME" "/home/thomas/.config/claude/local/claude" 
    elif ! tmux list-windows -t llm | grep -q 'Claude'; then
        echo "Creating new window."
        tmux new-window -t llm -n Claude -c "$PROJECTS_HOME" "/home/thomas/.config/claude/local/claude"
    fi
    tmux switch-client -t llm
    tmux select-window -t llm:Claude
}

function tmux-open-data() {
      if ! tmux has-session -t data &>/dev/null; then
        tmux new-session -d -s data -n sql -c "$HOME/data"
      fi
      tmux switch-client -t data
}
function tmux-open-yazi() {
      if ! tmux has-session -t files &>/dev/null; then
        tmux new-session -d -s files -n yazi "yazi"
      fi
      tmux switch-client -t files
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

function tmux-open-tmp() {
    ext=$(echo -e "md\npy\ngo" | fzf)
    [[ -z $ext ]] && { echo "No extension selected"; return 1 }
    local tmpdir="${TMPDIR:-/tmp}"
    local tmpfile="$(mktemp $tmpdir/tmp.XXXXXX.$ext)"
    local w_name=$(basename "$tmpfile" | tr . _)
    tmux new-session -d -s tmp -n "$w_name" -c "$tmpdir" "nvim \"$tmpfile\""
}

function tmux-open-todo() {
    if ! tmux has-session -t Notes 2>/dev/null; then
        tmux new-session -d -s Notes -n TODO "cd $NOTES_HOME && nvim TODO.md"
    fi
    tmux switch-client -t Notes
}
