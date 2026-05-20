# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles and system configuration. No build system, no tests, no linter. Run `install.sh` to deploy — it symlinks all configs to their target locations.

## Repository layout

| Path | Purpose | Deployed to |
|------|---------|-------------|
| `aliases/aliases` | Bash aliases and shell functions | `~/.aliases`, sourced from `.bashrc` |
| `tmux-config/` | Tmux configuration and plugins | `~/.config/tmux` (directory symlink) |
| `neovim-minimal/` | Single-file Neovim config using native `vim.pack` | `~/.config/nvim` (directory symlink) |
| `install.sh` | Symlinks all configs to target locations | run from repo root |
| `ansible/` | Empty — reserved for future provisioning playbooks | — |

## Install

```sh
./install.sh
```

Safe to re-run — skips targets that are already correctly symlinked.

## Tmux

- Prefix: `C-u`
- Terminal: `tmux-256color` with true-color override via `terminal-overrides`
- Plugin manager: TPM (`tmux-plugins/tpm`). Run `<prefix> + I` inside tmux to install plugins after changes.
- Plugins: `tmux-plugins/tmux-yank`, `christoomey/vim-tmux-navigator`
- Theme: Catppuccin Frappé, loaded from `default.theme`. Swap with any file in `themes/` to change. Status bar colors (`status-bg purple`) are applied after the theme load and intentionally override it.
- Reload config: `<prefix> + r`

## Neovim

Single-file config (`neovim-minimal/init.lua`) using Neovim's native `vim.pack` plugin manager (Neovim 0.11+). No external package manager (no lazy.nvim, no packer).

Plugins: catppuccin, oil.nvim, mini.pick, nvim-lspconfig.  
LSP servers configured: `lua_ls`, `clangd`, `pyright` (must be installed separately on the system).

Leader key: `<Space>`

Key mappings summary:
- `<leader>o` — save and source current file
- `<leader>w` — write
- `<leader>q` — quit
- `<leader>f` — file picker (mini.pick)
- `<leader>h` — help picker (mini.pick)
- `<leader>e` — oil file explorer
- `<leader>lf` — LSP format
- `<leader>pc` — remove unused plugins (`pack_clean`)
- `<leader>y/d` — yank/delete to system clipboard

## Aliases

Notable aliases and functions in `aliases/aliases`:
- `lah` — `ls -lah --color=auto`
- `ll` — `ls -la --color=auto`
- `l` — `ls -l --color=auto`
- `grep` — `grep --color=auto`
- `gi` / `gr` / `gri` — grep with `-i`, `-r`, `-ri`
- `ff` — fzf with `cat -n` preview
- `commit` — quick timestamped git commit (`git commit -m "commit <epoch>" -a`)
- `sb` / `sc` — strip blank lines / strip commented lines from stdin
- `open` — `xdg-open` wrapper (background, suppressed output)
- `fixscreens` — disable laptop screen, use only HDMI-A-0
- `caps2esc` / `caps2ctrl` — remap Caps Lock via xkbmap
