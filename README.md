# Config

Personal dotfiles and system configuration.

## Install

Clone the repo and run the install script:

```sh
git clone https://github.com/jerQ/Config.git ~/.config/dotfiles
cd ~/.config/dotfiles
./install.sh
```

This symlinks all configs to their target locations and adds the aliases source line to `~/.bashrc` if not already present. Safe to re-run for updates.

---

## tmux-config

Deploy: symlink `tmux-config/` to `~/.config/tmux` (handled by `install.sh`).

### Prefix

`Ctrl-u`

### Keybindings

| Key | Action |
|-----|--------|
| `<prefix> r` | Reload config |
| `<prefix> \|` | Split horizontal (current path) |
| `<prefix> -` | Split vertical (current path) |
| `<prefix> c` | New window (current path) |
| `<prefix> m` | Zoom/unzoom pane |
| `<prefix> h/j/k/l` | Resize pane |

**Copy mode** (vi keys):

| Key | Action |
|-----|--------|
| `v` | Begin selection |
| `C-v` | Rectangle selection |
| `y` | Yank and exit copy mode |
| `Shift + drag` | Mouse select |

### Plugins

Managed by [TPM](https://github.com/tmux-plugins/tpm). Install with `<prefix> + I`.

- `tmux-plugins/tmux-yank` — system clipboard integration
- `christoomey/vim-tmux-navigator` — seamless navigation between tmux panes and vim splits

### Theme

Catppuccin Frappé (`default.theme`). To switch theme, replace `default.theme` with one of the alternatives in `themes/`:

```
themes/catppuccin/catppuccin_frappe_tmux.conf
themes/catppuccin/catppuccin_latte_tmux.conf
themes/catppuccin/catppuccin_macchiato_tmux.conf
themes/catppuccin/catppuccin_mocha_tmux.conf
themes/nord/nord.conf
```

---

## neovim-minimal

Deploy: symlink `neovim-minimal/` to `~/.config/nvim` (handled by `install.sh`).

Requires Neovim 0.11+ (uses native `vim.pack` — no lazy.nvim or packer).

### Plugins

- `catppuccin/nvim` — colorscheme
- `stevearc/oil.nvim` — file explorer
- `echasnovski/mini.pick` — fuzzy picker
- `neovim/nvim-lspconfig` — LSP configurations

Install plugins by running `:packadd` or letting `vim.pack.add` fetch them on first launch.  
Remove unused plugins with `<leader>pc`.

### LSP

Servers enabled: `lua_ls`, `clangd`, `pyright`. These must be installed separately on the system.

Autocompletion triggers on every keypress via `vim.lsp.completion`.

### Keybindings

Leader key: `<Space>`

| Key | Action |
|-----|--------|
| `<leader>o` | Save and source current file |
| `<leader>w` | Write |
| `<leader>q` | Quit |
| `<leader>f` | File picker (mini.pick) |
| `<leader>h` | Help picker (mini.pick) |
| `<leader>e` | Oil file explorer |
| `<leader>lf` | LSP format |
| `<leader>y` | Yank to system clipboard |
| `<leader>d` | Delete to system clipboard |
| `<leader>pc` | Remove unused plugins |

---

## aliases

Deploy: `install.sh` symlinks `aliases/aliases` to `~/.aliases` and adds `source "$HOME/.aliases"` to `~/.bashrc`.

Notable functions:

| Name | Description |
|------|-------------|
| `commit` | Quick timestamped git commit (`git commit -m "commit <epoch>" -a`) |
| `sb` / `sc` | Strip blank lines / strip commented lines from stdin |
| `ff` | fzf with bat preview |
| `open` | `xdg-open` wrapper (background, suppressed output) |
| `fixscreens` | Disable laptop screen, use only HDMI-A-0 |
| `caps2esc` / `caps2ctrl` | Remap Caps Lock via xkbmap |
