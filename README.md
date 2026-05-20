# Config

Personal dotfiles and system configuration.

## Install

Clone the repo and run the install script:

```sh
git clone https://github.com/jerQ/config.git ~/.config/dotfiles
cd ~/.config/dotfiles
./install.sh
```

This symlinks all configs to their target locations and adds the aliases source line to `~/.bashrc` if not already present. Safe to re-run for updates.

---

## tmux-config

Tmux configuration, plugins, and themes. See [tmux-config/README.md](tmux-config/README.md).

---

## neovim-minimal

Single-file Neovim config using native `vim.pack`. See [neovim-minimal/README.md](neovim-minimal/README.md).

---

## aliases

Deploy: `install.sh` symlinks `aliases/aliases` to `~/.aliases` and adds `source "$HOME/.aliases"` to `~/.bashrc`.

Notable functions:

| Name | Description |
|------|-------------|
| `lah` | `ls -lah --color=auto` |
| `ll` | `ls -la --color=auto` |
| `l` | `ls -l --color=auto` |
| `commit` | Quick timestamped git commit (`git commit -m "commit <epoch>" -a`) |
| `sb` / `sc` | Strip blank lines / strip commented lines from stdin |
| `ff` | fzf with `cat -n` preview |
| `grep` | grep with `--color=auto` |
| `gi` | `grep -i` — case-insensitive |
| `gr` | `grep -r` — recursive |
| `gri` | `grep -ri` — recursive + case-insensitive |
| `open` | `xdg-open` wrapper (background, suppressed output) |
| `fixscreens` | Disable laptop screen, use only HDMI-A-0 |
| `caps2esc` / `caps2ctrl` | Remap Caps Lock via xkbmap |

---

## ansible

Playbooks for system provisioning. See [ansible/README.md](ansible/README.md).
