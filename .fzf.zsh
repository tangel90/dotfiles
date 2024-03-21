# Setup fzf
# ---------
if [[ ! "$PATH" == */home/knilch/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/knilch/.fzf/bin"
fi

eval "$(fzf --zsh)"
