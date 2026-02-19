export XDG_CONFIG_HOME="$HOME/.config"
export PATH=$HOME/.local/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/lib
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/.ripgreprc"
export EDITOR="nvim"
export COLORTERM="truecolor"
export TMPDIR="$HOME/.local/tmp"
export PAGER="less"
export LESS="-SRXF"
export PERSONALCONFIG="$HOME/personal"
export PERSONALPROFILE="$PERSONALCONFIG/.profile"
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export FZF_DEFAULT_OPTS='--height 40% --layout reverse --border top'
export FZF_DEFAULT_COMMAND='fd . --follow --hidden --exclude .git'
export FZF_TMUX_OPTS='-p80%,60%'
#
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


if [ -d "$PERSONALCONFIG" ]; then
    for i in $(find -L "$PERSONALCONFIG" -type f); do
        source "$i"
    done
fi
