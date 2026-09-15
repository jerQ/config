# starship

Deploy: `install.sh` symlinks `starship.toml` → `~/.config/starship.toml`.

Requires [`starship`](https://starship.rs) installed. Not reliably available via `dnf`/`apt` (Fedora: Copr-only; Debian/Ubuntu: only very recent releases), so it's installed via `cargo install starship` (see `ansible/packages.yml`) — `cargo` is already provisioned there. Initialized via `eval "$(starship init bash)"` / `eval "$(starship init zsh)"` in `env/env.bash` / `env/env.zsh`, guarded by `command -v starship`.

## Prompt

Two-line, plain-text symbols (no Nerd Font required):

| Module | Shows |
|--------|-------|
| `directory` | Current path, truncated to 3 components / repo root |
| `git_branch` | Branch name |
| `git_status` | Dirty/staged/ahead-behind state |
| `c`, `golang`, `lua`, `python`, `rust` | Toolchain version, only when the directory looks like that language's project |
| `cmd_duration` | How long the last command took, if over 2s |
| `character` | `❯` on its own line, green on success / red on last-command failure |

## Theme

Catppuccin Frappé, matching tmux, fzf, and neovim.
