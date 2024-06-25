# Setup fzf
# ---------
if [[ ! "$PATH" == */home/thomas/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/thomas/.fzf/bin"
fi

eval "$(fzf --bash)"
