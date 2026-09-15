# zsh

Deploy: `install.sh` symlinks `zsh/` → `~/.config/zsh`, then adds a source line for `zsh-plugins.zsh` to `~/.zshrc`.

## Plugins

Managed as git submodules under `zsh/plugins/`, sourced directly by `zsh-plugins.zsh` — no plugin manager.

| Plugin | Purpose |
|--------|---------|
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | Fish-like command suggestions from history |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Fish-like command syntax highlighting |

**Sourcing order matters**: `zsh-syntax-highlighting` must be sourced last (its own documented requirement — sourcing it before other zle-wrapping plugins like `zsh-autosuggestions` breaks them). `zsh-plugins.zsh` sources `zsh-autosuggestions` first, `zsh-syntax-highlighting` second, and `install.sh` appends its source line after aliases/fzf/env in `~/.zshrc` so nothing loads after it.

## Theme

Suggestion and syntax highlight colors are set to Catppuccin Frappé, matching tmux, fzf, and starship.
