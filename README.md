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

## manual install zinit:

###add to .zshrc:
```
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"
```

### if sourcing zinit.zsh after compinit, add following after sourcing zinit.zsh:
```
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
```
reload shell and run ```exec zsh```

to make exa autocompletion work:
download _exa file from https://github.com/ogham/exa/blob/master/completions/zsh/_exa
and save it to /usr/local/share/zsh/site-functions/_exa

install fzf via git, since apt repository is not up-to-date:
```
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
```

install zoxide:
```
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
#!/bin/bash
```

install tmux
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
