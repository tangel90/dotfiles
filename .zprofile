export XDG_CONFIG_HOME="$HOME/.config"
export PATH=$PATH:$HOME/.local/bin:$HOME/bin:/usr/local/bin
export PATH=$PATH:$HOME/.local/scripts
export LD_LIBRARY_PATH=/usr/local/lib
export ANDROID_HOME=$HOME/Android/Sdk
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
export EDITOR="nvim"
export TERM="xterm-256color"
export TMPDIR="$HOME/.local/tmp"

export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

export FZF_DEFAULT_OPTS='--height 40% --layout reverse --border top'
export FZF_DEFAULT_COMMAND='find .'
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

bindkey -v
bindkey -M viins '^F' forward-char
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

alias vimdev='NVIM_APPNAME=nvim-dev nvim'
alias c="clear"
alias tls="tmux-list-session"
alias ls="ls --color=auto -X"
alias vim='nvim'
alias cat="bat"
alias lg="gpg-unlock-lazygit"
alias v="fd . --type f --hidden --exclude .git | fzf-tmux --border --preview='bat --style=numbers --color=always {}' -p 80%,80% | xargs nvim"
alias chat="chatgpt"
alias g="tmux-open-chatgpt"

if [ -x "$(command -v yazi)" ]; then
    bindkey -s "^e" "yazi-cwd\n"
    alias e="yazi-cwd"
fi

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

function yazi-cwd() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp" < /dev/tty
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

function tmux-list-session () {
    if tmux list-sessions >/dev/null 2>&1; then
        selected=$(tmux list-sessions | fzf | cut -d: -f1) && [ -n "$selected" ] && tmux attach-session -t "$selected"
    else
        echo "No active tmux sessions."
    fi
}

function tmux-open-claude() {
    if ! tmux has-session -t LLM 2>/dev/null; then
        echo "Creating new session."
        tmux new-session -d -s LLM -n Claude -c "$PROJECTS_HOME" "/home/thomas/.config/claude/local/claude" 
    elif ! tmux list-windows -t LLM | grep -q 'Claude'; then
        echo "Creating new window."
        tmux new-window -t LLM -n Claude -c "$PROJECTS_HOME" "/home/thomas/.config/claude/local/claude"
    fi
    tmux switch-client -t LLM
    tmux select-window -t LLM:Claude
}

function tmux-open-chatgpt() {
    if ! tmux has-session -t LLM 2>/dev/null; then
        tmux new-session -d -s LLM -n ChatGPT "$(which chatgpt)"
    elif ! tmux list-windows -t LLM | grep -q 'ChatGPT'; then
        tmux new-window -t LLM -n ChatGPT "$(which chatgpt)"
    fi
    tmux switch-client -t LLM
    tmux select-window -t LLM:ChatGPT
}

function tmux-open-dotfiles() {
    if ! tmux has-session -t dotfiles 2>/dev/null; then
        tmux new-session -d -s dotfiles -n nvim "cd ~/dotfiles && nvim"
        tmux new-window -c "$HOME/dotfiles"
        tmux last-window
    fi
    tmux switch-client -t dotfiles
}

function tmux-open-tmp() {
    ext=$(echo -e "md\npy\ngo" | fzf)
    [[ -z $ext ]] && { echo "No extension selected"; return 1 }
    local tmpdir="${TMPDIR:-/tmp}"
    local tmpfile="$(mktemp $tmpdir/tmp.XXXXXX.$ext)"
    local w_name=$(basename "$tmpfile" | tr . _)
    tmux new-window -n "$w_name" -c "$tmpdir" "nvim \"$tmpfile\""
}

function tmux-open-todo() {
    if ! tmux has-session -t Notes 2>/dev/null; then
        tmux new-session -d -s Notes -n TODO "cd $NOTES_HOME && nvim TODO.md"
    fi
    tmux switch-client -t Notes
}
