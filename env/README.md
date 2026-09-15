# env

Deploy: `install.sh` symlinks `env.bash` → `~/.env.bash`, `env.zsh` → `~/.env.zsh`, sourced from `~/.bashrc` / `~/.zshrc`.

Sets:
- `GOPATH="$HOME/go"` — Go workspace directory
- `PATH` — appends `$GOPATH/bin`, `$HOME/.cargo/bin`, `$HOME/.local/bin`
- Initializes `zoxide` (smart `cd`) via `eval "$(zoxide init <shell>)"` if installed
- Initializes `starship` prompt via `eval "$(starship init <shell>)"` if installed
