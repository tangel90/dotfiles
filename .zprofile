export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# If you come from bash you might have to change your $PATH.

export PATH=$PATH:$HOME/.local/bin:$HOME/bin:/usr/local/bin
export LD_LIBRARY_PATH=/usr/local/lib
export ANDROID_HOME=$HOME/Android/Sdk
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
export NVM_DIR=$HOME/.nvm

export EDITOR="nvim"
export TERM="xterm-256color"

# Open in tmux popup if on tmux, otherwise use --height mode
export FZF_DEFAULT_OPTS='--height 40% --layout reverse --border top'
export FZF_DEFAULT_COMMAND='find .'
export FZF_TMUX_OPTS='-p80%,60%'

alias vimdev='NVIM_APPNAME=nvim-dev nvim'
alias c="clear"
alias tmuxfzf='tmux attach-session -t $(tmux ls | fzf | cut -d: -f1)'
alias tls="tmux-list-session"
alias fd="fdfind"
alias ls="ls --color=auto -X"
alias vim='nvim'
alias cat="bat"
alias python="python3"
alias lg="lazygit"
alias act="conda activate"
alias v="fd . --type f --hidden --exclude .git | fzf-tmux --border --preview='bat --style=numbers --color=always {}' -p 80%,80% | xargs nvim"
alias chat="chatgpt"

if [ -x "$(command -v fdfind)" ]; then
    alias fd="fdfind"
fi

if [ -x "$(command -v exa)" ]; then
    alias lt="exa --tree --level=2"
    alias ll="exa --long --header --sort=type --icons --no-permissions --no-user"
    alias la="exa --long --header --all --sort=type --icons --no-permissions --no-user" 
fi

vv() {
    local CONFIG_DIRS=$(find -L $XDG_CONFIG_HOME -type d -name "nvim*")
    selected_config=$(echo "$CONFIG_DIRS" | fzf --prompt "Nvim Config > ")

    [[ -z $selected_config ]] && echo "No config selected" && return

    echo "Config selected: $selected_config"
    # NVIM_APPNAME=$(basename $selected_config) nvim $@
}

tmux-list-session () {
    if tmux list-sessions 2> /dev/null; then
        selected=$(tmux list-sessions | fzf | cut -d: -f1) && [ -n "$selected" ] && tmux attach-session -t "$selected"
    else
        echo "No active tmux sessions."
    fi
}
