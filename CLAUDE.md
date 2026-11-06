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
| `opencode/opencode.json` | OpenCode configuration | `~/.config/opencode/opencode.json` |
| `starship/starship.toml` | Starship prompt config | `~/.config/starship.toml` |
| `zsh/` | Zsh plugins (autosuggestions, syntax-highlighting) | `~/.config/zsh` (directory symlink) |
| `ansible/` | Provisioning playbooks | — |
| `install/alpine/` | CIS-partitioned Alpine install (answer file + disk script) | run from the Alpine live ISO |
| `install.sh` | Symlinks all configs to target locations | run from repo root |

Each subdirectory has its own README with full details.

## Git workflow

This repo pushes directly to `main` — no feature branches, no PRs. Commit and push straight to `main`.

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

Plugins: catppuccin, oil.nvim, mini.pick, vim-tmux-navigator.
LSP servers: `lua_ls`, `clangd`, `pyright` (must be installed separately).

Leader: `<Space>`. Key mappings: `<leader>f` file picker, `<leader>e` oil, `<leader>lf` LSP format, `<leader>y/d` clipboard yank/delete, `<leader>pc` remove unused plugins, `<leader>rn` rename symbol, `<leader>D` show diagnostic float, `]d`/`[d` next/prev diagnostic, `gd` go to definition, `gr` references, `<leader>ca` code action, `K` hover docs.

## Aliases

File: `aliases/aliases` → `~/.aliases`, sourced from `~/.bashrc`.

Notable: `lah`/`ll`/`l` ls variants, `grep`/`gi`/`gr`/`gri` grep variants, `ff` fzf picker, `commit` timestamped git commit, `sb`/`sc` stdin filters, `open` xdg-open wrapper, `fixscreens`, `caps2esc`/`caps2ctrl`, `cht` cht.sh cheat sheet lookup, `cat` → `bat` (syntax highlighting), `cd` → `z` (zoxide), `fd` → `fdfind` (Debian compat), `rgi` → `rg -i`, `prs`/`prc` → `gh pr list`/`gh pr create`.

## FZF

Files: `fzf/fzf.bash` → `~/.fzf.bash`, `fzf/fzf.zsh` → `~/.fzf.zsh`, sourced from `~/.bashrc` / `~/.zshrc`.

Key bindings (requires `fzf` installed via system package manager):
- `Ctrl+R` — fzf history search
- `Ctrl+T` — fzf file picker (pastes path into command line)
- `Alt+C` — fzf directory picker (`cd` into selection)

Theme: Catppuccin Frappé colors via `FZF_DEFAULT_OPTS`. Shell integration generated via `eval "$(fzf --bash)"` / `eval "$(fzf --zsh)"` (fzf 0.48+), distro-independent.

## Env

Files: `env/env.bash` → `~/.env.bash`, `env/env.zsh` → `~/.env.zsh`, sourced from `~/.bashrc` / `~/.zshrc`.

Sets:
- `GOPATH="$HOME/go"` — Go workspace directory
- `PATH` — appends `$GOPATH/bin`, `$HOME/.cargo/bin`, `$HOME/.local/bin`
- Initializes `zoxide` (smart `cd`) via `eval "$(zoxide init <shell>)"` if installed
- Initializes `starship` prompt via `eval "$(starship init <shell>)"` if installed

## Starship

File: `starship/starship.toml` → `~/.config/starship.toml`.

Two-line prompt, plain-text symbols (no Nerd Font required): directory, git branch/status, language version (`c`, `golang`, `lua`, `python`, `rust` — shown only when relevant to the current directory), command duration (if >2s), then an exit-code-colored `❯` on its own line.

Theme: Catppuccin Frappé, matching tmux, fzf, and neovim. Installed via the official install script into `~/.local/bin` (see `ansible/common/starship.yml`) since it isn't reliably packaged via `dnf`/`apt` and a `cargo install` compile is too slow/heavy on low-power devices (e.g. Raspberry Pi).

## Zsh Plugins

Directory: `zsh/` → `~/.config/zsh` (directory symlink), loader `zsh-plugins.zsh` sourced from `~/.zshrc`.

Plugins (git submodules under `zsh/plugins/`, sourced directly — no plugin manager): `zsh-users/zsh-autosuggestions`, `zsh-users/zsh-syntax-highlighting`. Sourcing order matters — `zsh-syntax-highlighting` must load last.

## Ansible

Playbooks in `ansible/`, split per OS — pick the directory matching the machine, no OS detection or `when:` conditions:
- `fedora/`, `debian/`, `alpine/` — `update.yml` (system upgrade), `packages.yml` (CLI tools), `gui.yml` (GUI apps, skip on headless boxes), `neovim.yml` (Neovim from distro repos + clangd/pip, then imports `common/lsp.yml`; Alpine uses doas and installs lua-language-server via apk and pyright via npm instead, since upstream binaries are glibc-only), `site.yml` (runs everything in order; hardening only with `-e hardening=true`)
- `<os>/hardening.yml` — optional, on-demand security hardening (MAC: AppArmor on Alpine/Debian, SELinux on Fedora; auditd, sysctl, module blacklist, firewall: nftables on Alpine/Debian, firewalld on Fedora; SSH key-only + fail2ban; automatic updates). Imported by `site.yml` but skipped unless `-e hardening=true`; sections selectable via tags
- `common/` — OS-independent: `lsp.yml` (pyright via pip, lua-language-server for x86_64/aarch64), `starship.yml` (official install script, no sudo), `setup.yml` (creates `~/Devel`, clones config repo, runs `install.sh`, no sudo)

Usage: `ansible-playbook -i inventory.ini fedora/site.yml`, or pass any combination of individual playbooks.

## Alpine install

`install/alpine/cis-install.sh [--encrypt] <disk> <answerfile|URL>` runs from the Alpine live ISO. It creates GPT (UEFI or BIOS), optional LUKS2, then LVM `vg0` with separate `/var`, `/var/log`, `/var/log/audit`, `/var/tmp` and `/home` volumes, and mounts them with CIS options under `/mnt`. Then it runs `setup-alpine -f` with `DISKOPTS="-m sys /mnt"`; `setup-fstab` copies the mount options into fstab. Afterwards it fixes `/tmp` and `/dev/shm` to `noexec` and adds swap.

`answers.example.conf` is the committed template. The real `answers*.conf` is git-ignored, because it holds the hostname, username and SSH key. It sets `KERNELOPTS` (AppArmor `lsm=`, `audit=1`) via `export`, since setup-alpine sources the file.
