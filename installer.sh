sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash



# install fzf fuzzy finder
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# enable zsh tab completion for exa
EXA_ZSH_COMPLETION_URL="https://raw.githubusercontent.com/ogham/exa/master/completions/zsh/_exa"
EXA_TARGET_DIR="/usr/local/share/zsh/site-functions"

sudo mkdir -p "$EXA_TARGET_DIR"
sudo curl -L "$EXA_ZSH_COMPLETION_URL" -o "${EXA_TARGET_DIR}/_exa"
echo "_exa completion file installed successfully to ${EXA_TARGET_DIR}/_exa"

sudo apt install stow
