[[ $TERM != "screen" ]] && exec tmux

# Export variables
export PATH="${PATH}:${HOME}/.local/bin"

# Sources
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
