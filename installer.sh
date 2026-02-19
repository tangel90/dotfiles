#!/usr/bin/env bash
sudo pacman -Sy zsh neovim lazygit powerlevel10k bat zoxide fzf exa stow ripgrep fd tmux cargo go nvm zig jq direnv glow unzip yazi tldr

# curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
# install fzf fuzzy finder
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

