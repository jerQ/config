#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
        echo "  ok: $dst"
        return
    fi
    rm -rf "$dst"
    ln -s "$src" "$dst"
    echo "  linked: $dst -> $src"
}

echo "==> neovim"
link "$REPO/neovim-minimal" "$HOME/.config/nvim"

echo "==> tmux"
link "$REPO/tmux-config" "$HOME/.config/tmux"

echo "==> aliases"
link "$REPO/aliases/aliases" "$HOME/.config/aliases"

if ! grep -qF 'source "$HOME/.config/aliases"' "$HOME/.bashrc" 2>/dev/null; then
    echo '' >> "$HOME/.bashrc"
    echo 'source "$HOME/.config/aliases"' >> "$HOME/.bashrc"
    echo "  added aliases source to ~/.bashrc"
else
    echo "  aliases already sourced in ~/.bashrc"
fi

echo "done"
