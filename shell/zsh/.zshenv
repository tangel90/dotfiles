# Read by every zsh, including `ssh host cmd` (no .zprofile there): herdr
# --remote / saved machines and agents run tools from ~/.local/bin that way.
typeset -U path
path=($HOME/.local/bin $path)

# Plain environment, here rather than in .zprofile so non-login shells get it
# too: herdr servers started over `ssh host cmd` (the VPS) and everything
# they run, e.g. yazi's `$EDITOR %s` opener (empty EDITOR ran the file: 126).
export XDG_CONFIG_HOME="$HOME/.config"
export LD_LIBRARY_PATH=/usr/local/lib
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME/ripgrep/.ripgreprc"
export EDITOR="nvim"
export COLORTERM="truecolor"
export TMPDIR="$HOME/.local/tmp"
export PAGER="less"
export LESS="-iMSRx4 -XFQ"
export PERSONALCONFIG="$HOME/personal"
export PERSONALPROFILE="$PERSONALCONFIG/.profile"
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export FZF_DEFAULT_OPTS='--height 40% --layout reverse --border top'
export FZF_DEFAULT_COMMAND='fd . --follow --hidden --exclude .git'
export FZF_TMUX_OPTS='-p80%,60%'
export TARGET_LANG=de
export SOURCE_LANG=en
export NVM_DIR="$HOME/.config/nvm"
