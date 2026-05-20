# tmux-config

Deploy: symlink `tmux-config/` to `~/.config/tmux` (handled by `install.sh`).

## Prefix

`Ctrl-u`

## Keybindings

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

## Plugins

Managed by [TPM](https://github.com/tmux-plugins/tpm). Install with `<prefix> + I`.

- `tmux-plugins/tmux-yank` — system clipboard integration
- `christoomey/vim-tmux-navigator` — seamless navigation between tmux panes and vim splits

## Theme

Catppuccin Frappé (`default.theme`). To switch theme, replace `default.theme` with one of the alternatives in `themes/`:

```
themes/catppuccin/catppuccin_frappe_tmux.conf
themes/catppuccin/catppuccin_latte_tmux.conf
themes/catppuccin/catppuccin_macchiato_tmux.conf
themes/catppuccin/catppuccin_mocha_tmux.conf
themes/nord/nord.conf
```
