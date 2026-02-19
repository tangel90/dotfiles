# dotfiles

packages:

zsh
neovim
lazygit
powerlevel10k
bat
zoxide
fzf
exa
stow
ripgrep
fd
tmux
cargo
go
nvm
zig
jq
direnv
glow
unzip
yazi
pass
tldr

## change to zsh

list available shells:

```bash
chsh -l
```

change shell:

```bash
chsh -s /bin/zsh
```

## Build Neovim:

### Linux

#### Pre-built archives

The [Releases](https://github.com/neovim/neovim/releases) page provides pre-built binaries for Linux systems.

```sh
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
```

Then add this to your shell config (`~/.bashrc`, `~/. zshrc`, ...):

```sh
export PATH="$PATH:/opt/nvim-linux64/bin"
```

#### Get Clipboard working in WSL:

Download win32yank.exe and copy it to /usr/local/bin

```lua
lua vim.cmd('new') vim.bo.filetype = 'lua' vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(vim.inspect(require('nvim-web-devicons').get_icons()), '\n'))
```

### install NVM

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

put this into ~/.zshrc

```bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
```

### gh credentials-manager on wsl:

git config --global credential.helper "/mnt/c/Users/Thomas/AppData/Local/Programs/Git/mingw64/bin/git-credential-manager.exe"

### GnuPG setup for ssh-keys

create gpg-agent.conf and enable ssh support:

```bash
echo "enable-ssh-support" >> ~/.gnupg/gpg-agent.conf
```

fix gpg pinentry issue within tmux, add to first line of ~/.ssh/config:

```bash
Match host * exec "gpg-connect-agent UPDATESTARTUPTTY /bye"
```

let gpg-agent act as ssh-agent (make sure ssh-agent is not running)

```bash
killall ssh-agent gpg-agent
gpg-connect-agent --verbose /bye
gpg-connect-agent updatestartuptty /bye
ssh-add ~/.ssh/rsa
```

The following error means that ssh-add is picket up by the standard ssh-agent (which is not running)
"Could not add identity "/home/ubuntu/.ssh/knilch": agent refused operation"
-> gpg agent is not properly configured

## manual install zinit:

add to .zshrc:

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

reload shell and run `exec zsh`

# Installations

## Exa

install exa via apt
to make exa autocompletion work:
download \_exa file from https://github.com/ogham/exa/blob/master/completions/zsh/_exa
and save it to /usr/local/share/zsh/site-functions/\_exa

## fzf

install fzf via git, since apt repository is not up-to-date:

```bash
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

## zoxide:

```bash
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

```bash
sudo apt install tmux
```

install tmux package manager

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

add to $XDG_CONFIG_HOME/tmux/tmux.conf

```bash
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

```bash
curl https://sh.rustup.rs -sSf | sh
```

make sure to add $HOME/.cargo/bin/ folder to PATH

## golang

Download latest archive and unpack to /usr/local

```bash
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.23.1.linux-amd64.tar.gz
```

make sure do add /usr/local/go/bin to PATH

install tldr

```bash
npm install -g tldr
```


how to insert unicode characters: (terminal function)

```terminal
ctrl+shift+u
```
