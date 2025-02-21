# dotfiles

packages:

neovim
lazygit
powerline10k
bat
zoxide
fzf
exa
stow
ripgrep
tmux
cargo
go
nvm
zig
jq
glow
unzip


##Neovim:
### Linux

#### Pre-built archives

The [Releases](https://github.com/neovim/neovim/releases) page provides pre-built binaries for Linux systems.

```sh
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz

#### Get Clipboard working in WSL:
Download win32yank.exe and copy it to /usr/local/bin
```

Then add this to your shell config (`~/.bashrc`, `~/. zshrc`, ...):

    export PATH="$PATH:/opt/nvim-linux64/bin"

## manual install zinit:

###add to .zshrc:
```bash
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"
```

### if sourcing zinit.zsh after compinit, add following after sourcing zinit.zsh:
```bash
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
```
reload shell and run ```exec zsh```

# Installations

## Exa

install exa via apt
to make exa autocompletion work:
download _exa file from https://github.com/ogham/exa/blob/master/completions/zsh/_exa
and save it to /usr/local/share/zsh/site-functions/_exa

## fzf
install fzf via git, since apt repository is not up-to-date:
```
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

## zoxide:
```
#!/bin/bash
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
```
install lazygit
```bash
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
```

## tmux

```
sudo apt install tmux
```

install tmux package manager
```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

add to $XDG_CONFIG_HOME/tmux/tmux.conf 
```
# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'   

# type this in terminal if tmux is already running
tmux source ~/.tmux.conf
```

## cargo with rustup
Run rustup installer:
```
curl https://sh.rustup.rs -sSf | sh
```
make sure to add $HOME/.cargo/bin/ folder to PATH


## golang
Download latest archive and unpack to /usr/local
```
 rm -rf /usr/local/go && tar -C /usr/local -xzf go1.23.1.linux-amd64.tar.gz
```
make sure do add /usr/local/go/bin to PATH


