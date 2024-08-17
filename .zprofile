export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH
export EDITOR="nvim"
export PATH="$HOME/.local/bin:/home/knilch/.cargo/bin:$PATH"
export LD_LIBRARY_PATH=/usr/local/lib
export PATH="$PATH:/opt/nvim-linux64/bin"
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export NVM_DIR=$HOME/.nvm

# Open in tmux popup if on tmux, otherwise use --height mode
export FZF_DEFAULT_OPTS='--height 40% --layout reverse --border top'
export FZF_DEFAULT_COMMAND='find .'
export FZF_TMUX_OPTS='-p80%,60%'

alias c="clear"
alias ls="ls --color"
alias fd="fdfind"
alias vim='nvim'
alias cat="bat"
alias python="python3"
alias lg="lazygit"
alias act="conda activate"
alias v="fd . --type f --hidden --exclude .git | fzf-tmux --border --preview='bat --style=numbers --color=always {}' -p 80%,80% | xargs nvim"

if [ -x "$(command -v exa)" ]; then
    alias lt="exa --tree --level=2"
    alias ll="exa --long --header --sort=type --icons --no-permissions --no-user"
    alias la="exa --long --header --all --sort=type --icons --no-permissions --no-user" 
fi

tm () {
    echo "Start tmux."
    if tmux list-sessions 2> /dev/null; then
        selected_session=$(tmux list-sessions | fzf | cut -d: -f1)
        if [ -n "$selected_session" ]; then
            command tmux attach-session -t "$selected_session"
        else
            echo "No session selected."
        fi
    else
        echo "No existing sessions. Starting a new session."
        command tmux -f ~/.config/tmux/tmux.conf
    fi
}
