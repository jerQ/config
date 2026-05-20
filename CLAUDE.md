# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles and system configuration. No build system, no tests, no linter. Changes here are applied manually by symlinking or copying files to their target locations.

## Repository layout

| Path | Purpose | Deployed to |
|------|---------|-------------|
| `aliases/aliases` | Bash aliases and shell functions | `~/.config/aliases` or sourced from `.bashrc` |
| `tmux-config/tmux.conf` | Tmux configuration | `~/.config/tmux/tmux.conf` |
| `tmux-config/default.theme` | Active Catppuccin Frappé palette (sourced by tmux.conf) | `~/.config/tmux/default.theme` |
| `tmux-config/themes/` | Alternative themes (catppuccin variants, nord) | swap with `default.theme` to change theme |
| `tmux-config/plugins/` | Vendored plugins: tpm, tmux-yank | `~/.config/tmux/plugins/` |
| `neovim-minimal/init.lua` | Single-file Neovim config using native `vim.pack` | `~/.config/nvim/init.lua` |
| `ansible/` | Empty — reserved for future provisioning playbooks | — |

## Tmux

- Prefix: `C-u`
- Plugin manager: TPM (`plugins/tpm`). Run `<prefix> + I` inside tmux to install plugins after changes.
- Theme is loaded via `run-shell "tmux source-file ~/.config/tmux/default.theme"` — swap the file to change theme, or point the `source-file` line to a different theme in `themes/`.
- Reload config: `<prefix> + r`

## Neovim

Single-file config (`neovim-minimal/init.lua`) using Neovim's native `vim.pack` plugin manager (Neovim 0.11+). No external package manager (no lazy.nvim, no packer).

Plugins: catppuccin, oil.nvim, mini.pick, nvim-lspconfig.  
LSP servers configured: `lua_ls`, `clangd`, `pyright` (must be installed separately on the system).

Leader key: `<Space>`

Key mappings summary:
- `<leader>o` — save and source current file
- `<leader>f` — file picker (mini.pick)
- `<leader>e` — oil file explorer
- `<leader>lf` — LSP format
- `<leader>pc` — remove unused plugins (`pack_clean`)
- `<leader>y/d` — yank/delete to system clipboard

## Aliases

Notable functions in `aliases/aliases`:
- `commit` — quick timestamped git commit (`git commit -m "commit <epoch>" -a`)
- `sb` / `sc` — strip blank lines / strip commented lines from stdin
- `ff` — fzf with bat preview
- `open` — `xdg-open` wrapper (background, suppressed output)
- `fixscreens` — disable laptop screen, use only HDMI-A-0
- `caps2esc` / `caps2ctrl` — remap Caps Lock via xkbmap
