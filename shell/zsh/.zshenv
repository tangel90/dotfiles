# Read by every zsh, including `ssh host cmd` (no .zprofile there): herdr
# --remote / saved machines and agents run tools from ~/.local/bin that way.
typeset -U path
path=($HOME/.local/bin $path)
