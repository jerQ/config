# fzf

Deploy: `install.sh` symlinks `fzf.bash` → `~/.fzf.bash` and `fzf.zsh` → `~/.fzf.zsh`, then adds source lines to `~/.bashrc` and `~/.zshrc`.

Requires `fzf` installed via system package manager (`dnf install fzf`). Shell integration files are sourced from `/usr/share/fzf/shell/` (Fedora package path).

## Key bindings

| Key | Action |
|-----|--------|
| `Ctrl+R` | fzf history search |
| `Ctrl+T` | fzf file picker — pastes selected path into command line |
| `Alt+C` | fzf directory picker — `cd` into selected directory |

## Theme

Catppuccin Frappé colors via `FZF_DEFAULT_OPTS`, matching the tmux and neovim theme.
