EXA_ZSH_COMPLETION_URL="https://raw.githubusercontent.com/ogham/exa/master/completions/zsh/_exa"
EXA_TARGET_DIR="/usr/local/share/zsh/site-functions"

sudo mkdir -p "$EXA_TARGET_DIR"
sudo curl -L "$EXA_ZSH_COMPLETION_URL" -o "${EXA_TARGET_DIR}/_exa"
echo "_exa completion file installed successfully to ${EXA_TARGET_DIR}/_exa"
