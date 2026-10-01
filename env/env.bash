export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin:$HOME/.cargo/bin:$HOME/.local/bin:$HOME/.opencode/bin"
export OLLAMA_HOST=127.0.0.1:11434

HISTFILE="$HOME/.bash_history"
HISTSIZE=10000
HISTFILESIZE=10000
HISTCONTROL=ignoredups
shopt -s histappend
PROMPT_COMMAND="history -a; history -c; history -r${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

command -v zoxide &>/dev/null && eval "$(zoxide init bash)"
command -v starship &>/dev/null && eval "$(starship init bash)"

