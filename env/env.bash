export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin:$HOME/.cargo/bin:$HOME/.local/bin"

command -v zoxide &>/dev/null && eval "$(zoxide init bash)"
