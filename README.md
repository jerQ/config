# Config

Personal dotfiles and system configuration.

## Install

Clone the repo and run the install script (submodules are initialized automatically):

```sh
git clone https://github.com/jerQ/config.git ~/Devel/config
cd ~/Devel/config
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

Bash aliases and shell functions. See [aliases/README.md](aliases/README.md).

---

## ansible

Playbooks for system provisioning. See [ansible/README.md](ansible/README.md).
