# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles and system configuration. No build system, no tests, no linter. Run `install.sh` to deploy — it symlinks all configs to their target locations.

## Repository layout

| Path | Purpose | Deployed to |
|------|---------|-------------|
| `aliases/aliases` | Bash aliases and shell functions | `~/.aliases`, sourced from `.bashrc` |
| `fzf/fzf.bash` | fzf shell integration for bash | `~/.fzf.bash`, sourced from `.bashrc` |
| `fzf/fzf.zsh` | fzf shell integration for zsh | `~/.fzf.zsh`, sourced from `.zshrc` |
| `env/env.bash` | PATH and environment variables for bash | `~/.env.bash`, sourced from `.bashrc` |
| `env/env.zsh` | PATH and environment variables for zsh | `~/.env.zsh`, sourced from `.zshrc` |
| `tmux-config/` | Tmux configuration and plugins | `~/.config/tmux` (directory symlink) |
| `neovim-minimal/` | Single-file Neovim config using native `vim.pack` | `~/.config/nvim` (directory symlink) |
| `ansible/` | Provisioning playbooks | — |
| `install.sh` | Symlinks all configs to target locations | run from repo root |

Each subdirectory has its own README with full details.

## Install

```sh
git clone https://github.com/jerQ/config.git ~/Devel/config
cd ~/Devel/config
./install.sh
```

Safe to re-run — skips targets that are already correctly symlinked. Initializes submodules automatically.

## Tmux

- Prefix: `C-u`
- Plugin manager: TPM (`tmux-plugins/tpm`). Run `<prefix> + I` inside tmux to install plugins after changes.
- Plugins: `tmux-plugins/tmux-yank`, `christoomey/vim-tmux-navigator` (git submodule at `tmux-config/plugins/vim-tmux-navigator`)
- Theme: Catppuccin Frappé (`default.theme`). Swap with any file in `themes/` to change.
- Reload config: `<prefix> + r`

## Neovim

Single-file config (`neovim-minimal/init.lua`) using Neovim's native `vim.pack` (Neovim 0.11+). No lazy.nvim or packer.

Plugins: catppuccin, oil.nvim, mini.pick, nvim-lspconfig.
LSP servers: `lua_ls`, `clangd`, `pyright` (must be installed separately).

Leader: `<Space>`. Key mappings: `<leader>f` file picker, `<leader>e` oil, `<leader>lf` LSP format, `<leader>y/d` clipboard yank/delete, `<leader>pc` remove unused plugins.

## Aliases

File: `aliases/aliases` → `~/.aliases`, sourced from `~/.bashrc`.

Notable: `lah`/`ll`/`l` ls variants, `grep`/`gi`/`gr`/`gri` grep variants, `ff` fzf picker, `commit` timestamped git commit, `sb`/`sc` stdin filters, `open` xdg-open wrapper, `fixscreens`, `caps2esc`/`caps2ctrl`, `cht` cht.sh cheat sheet lookup, `gh` GitHub CLI, `bat` pager with syntax highlighting.

## FZF

Files: `fzf/fzf.bash` → `~/.fzf.bash`, `fzf/fzf.zsh` → `~/.fzf.zsh`, sourced from `~/.bashrc` / `~/.zshrc`.

Key bindings (requires `fzf` installed via system package manager):
- `Ctrl+R` — fzf history search
- `Ctrl+T` — fzf file picker (pastes path into command line)
- `Alt+C` — fzf directory picker (`cd` into selection)

Theme: Catppuccin Frappé colors via `FZF_DEFAULT_OPTS`. System integration files sourced from `/usr/share/fzf/shell/` (Fedora package path).

## Env

Files: `env/env.bash` → `~/.env.bash`, `env/env.zsh` → `~/.env.zsh`, sourced from `~/.bashrc` / `~/.zshrc`.

Sets:
- `GOPATH="$HOME/go"` — Go workspace directory
- `PATH` — appends `$GOPATH/bin`, `$HOME/.cargo/bin`, `$HOME/.local/bin`
- Initializes `zoxide` (smart `cd`) via `eval "$(zoxide init <shell>)"` if installed

## Ansible

Playbooks in `ansible/`:
- `main.yml` — runs all playbooks in order (update → packages → neovim → setup)
- `update.yml` — updates all packages on Debian/Ubuntu (`apt`) and Fedora (`dnf`)
- `packages.yml` — installs common CLI tools (including neovim), GUI apps, and third-party repos (VS Code, Brave)
- `neovim.yml` — fetches latest stable tag from GitHub, compiles, and installs Neovim to `/usr/local`
- `setup.yml` — creates `~/Devel`, clones config repo, and runs `install.sh` (runs as current user, no sudo)
