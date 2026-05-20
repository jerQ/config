# Config

Personal dotfiles and system configuration.

---

## tmux-config

Deploy: symlink or copy `tmux-config/` contents to `~/.config/tmux/`.

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

Deploy: symlink or copy `neovim-minimal/init.lua` to `~/.config/nvim/init.lua`.

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
