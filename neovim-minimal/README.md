# neovim-minimal

- Truly simplistic, the most basic nvim config
- Single file configuration with less than 100 lines of code
- Uses native plugin manager
- Catppuccin
- Avoid bloat

Deploy: symlink `neovim-minimal/` to `~/.config/nvim` (handled by `install.sh`).

Requires Neovim 0.11+ (uses native `vim.pack` — no lazy.nvim or packer).

## Plugins

- `catppuccin/nvim` — colorscheme
- `stevearc/oil.nvim` — file explorer
- `echasnovski/mini.pick` — fuzzy picker
- `christoomey/vim-tmux-navigator` — seamless vim/tmux pane navigation

Install plugins by running `:packadd` or letting `vim.pack.add` fetch them on first launch.  
Remove unused plugins with `<leader>pc`.

## LSP

Servers enabled: `lua_ls`, `clangd`, `pyright`. These must be installed separately on the system.

Autocompletion triggers on every keypress via `vim.lsp.completion`.

## Keybindings

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
| `<leader>rn` | Rename symbol |
| `<leader>D` | Show diagnostic float |
| `]d` / `[d` | Next / prev diagnostic |
| `gd` | Go to definition |
| `K` | Hover documentation |
