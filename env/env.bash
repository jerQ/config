export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin:$HOME/.cargo/bin:$HOME/.local/bin:$HOME/.opencode/bin"
export OLLAMA_HOST=127.0.0.1:11434

command -v zoxide &>/dev/null && eval "$(zoxide init bash)"

