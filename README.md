# dotfiles

packages:

oh-my-zsh
powerline10k
bat
zoxide
fzf
exa
stow
ripgrep
tmux


to make exa autocompletion work:
download _exa file from https://github.com/ogham/exa/blob/master/completions/zsh/_exa
and save it to /usr/local/share/zsh/site-functions/_exa

install fzf via git, since apt repository is not up-to-date:
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

install zoxide:
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
#!/bin/bash

install tmux
sudo apt install tmux
install tmux package manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

add to $XDG_CONFIG_HOME/tmux/tmux.conf 
# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'   

# type this in terminal if tmux is already running
tmux source ~/.tmux.conf
