# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi 
# SSH_AUTH_SOCK set to GPG to enable using gpgagent as the ssh agent.
# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
# zinit snippet OMZP::archlinux
# zinit snippet OMZP::aws
# zinit snippet OMZP::kubectl
# zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

autoload -Uz compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

HISTSIZE=5000
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

# Shell integrations
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(fzf --zsh)"
eval "$(zoxide init zsh --cmd cd)"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/thomas/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/thomas/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/thomas/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/thomas/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# >>> initialize environment >>>
source $HOME/.zprofile

LOCALENV="$XDG_CONFIG_HOME/localenv"
if [ -d "$LOCALENV" ]; then
    export "LOCALPROFILE=$LOCALENV/.zprofile"
    for i in $(find -L "$LOCALENV" -type f); do
        source "$i"
    done
fi
# <<< initialize environment <<<

gpgconf --launch gpg-agent
gpg-connect-agent updatestartuptty /bye >/dev/null

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
    sessions=$(tmux list-sessions 2>/dev/null)
    if [ -z "$sessions" ]; then
        echo "No sessions found!"
        tmux new-session
    else
        if command -v tmux-list-session; then
            tmux-list-session
        else
            echo "Tmux sessions found. Trying to attach ..."
            tmux attach
        fi
    fi
fi
