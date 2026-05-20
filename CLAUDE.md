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
| `ansible/` | Provisioning playbooks | — |
| `install.sh` | Symlinks all configs to target locations | run from repo root |

Each subdirectory has its own README with full details.

## Install

```sh
./install.sh
```

Safe to re-run — skips targets that are already correctly symlinked.

## Tmux

- Prefix: `C-u`
- Plugin manager: TPM (`tmux-plugins/tpm`). Run `<prefix> + I` inside tmux to install plugins after changes.
- Plugins: `tmux-plugins/tmux-yank`, `christoomey/vim-tmux-navigator`
- Theme: Catppuccin Frappé (`default.theme`). Swap with any file in `themes/` to change.
- Reload config: `<prefix> + r`

## Neovim

Single-file config (`neovim-minimal/init.lua`) using Neovim's native `vim.pack` (Neovim 0.11+). No lazy.nvim or packer.

Plugins: catppuccin, oil.nvim, mini.pick, nvim-lspconfig.
LSP servers: `lua_ls`, `clangd`, `pyright` (must be installed separately).

Leader: `<Space>`. Key mappings: `<leader>f` file picker, `<leader>e` oil, `<leader>lf` LSP format, `<leader>y/d` clipboard yank/delete, `<leader>pc` remove unused plugins.

## Aliases

File: `aliases/aliases` → `~/.aliases`, sourced from `~/.bashrc`.

Notable: `lah`/`ll`/`l` ls variants, `grep`/`gi`/`gr`/`gri` grep variants, `ff` fzf picker, `commit` timestamped git commit, `sb`/`sc` stdin filters, `open` xdg-open wrapper, `fixscreens`, `caps2esc`/`caps2ctrl`.

## Ansible

Playbooks in `ansible/`. Currently: `update.yml` — updates all packages on Debian/Ubuntu (`apt`) and Fedora (`dnf`).
