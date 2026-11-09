
export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v '/mnt/c' | tr '\n' ':' | sed 's/:$//')

# SSH_AUTH_SOCK set to GPG. This enables using gpgagent as the ssh agent.
unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi

if [ -d "$PERSONALCONFIG" ]; then
    # depth 1 only: $PERSONALCONFIG/zsh/*.zsh is interactive-only and is
    # sourced from .zshrc after compinit (compdef isn't available yet here).
    for i in $(find -L "$PERSONALCONFIG" -maxdepth 1 -type f); do
        source "$i"
    done
fi
