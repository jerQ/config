# aliases

Deploy: `install.sh` symlinks `aliases/aliases` to `~/.aliases` and adds `source "$HOME/.aliases"` to `~/.bashrc`.

## Aliases

| Name | Description |
|------|-------------|
| `lah` | `ls -lah --color=auto` |
| `ll` | `ls -la --color=auto` |
| `l` | `ls -l --color=auto` |
| `grep` | `grep --color=auto` |
| `gi` | `grep -i` — case-insensitive |
| `gr` | `grep -r` — recursive |
| `gri` | `grep -ri` — recursive + case-insensitive |
| `ff` | fzf file picker with `cat -n` line-number preview (`fzf --preview 'cat -n {}'`) |
| `open` | `xdg-open` wrapper (background, suppressed output) |
| `fixscreens` | Disable laptop screen, use only HDMI-A-0 |
| `caps2esc` / `caps2ctrl` | Remap Caps Lock via xkbmap |

## Functions

| Name | Description |
|------|-------------|
| `commit` | Quick timestamped git commit (`git commit -m "commit <epoch>" -a`) |
| `sb` | Strip blank lines from stdin |
| `sc` | Strip commented lines from stdin |
