export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin:$HOME/.cargo/bin:$HOME/.local/bin:$HOME/.opencode/bin"

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS

command -v starship &>/dev/null && eval "$(starship init zsh)"
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"
