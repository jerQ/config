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
link "$REPO/aliases/aliases" "$HOME/.aliases"

if ! grep -qF 'source "$HOME/.aliases"' "$HOME/.bashrc" 2>/dev/null; then
    echo '' >> "$HOME/.bashrc"
    echo 'source "$HOME/.aliases"' >> "$HOME/.bashrc"
    echo "  added aliases source to ~/.bashrc"
else
    echo "  aliases already sourced in ~/.bashrc"
fi

echo "==> fzf"
link "$REPO/fzf/fzf.bash" "$HOME/.fzf.bash"
link "$REPO/fzf/fzf.zsh"  "$HOME/.fzf.zsh"

if ! grep -qF '.fzf.bash' "$HOME/.bashrc" 2>/dev/null; then
    echo '' >> "$HOME/.bashrc"
    echo '[ -f "$HOME/.fzf.bash" ] && source "$HOME/.fzf.bash"' >> "$HOME/.bashrc"
    echo "  added fzf source to ~/.bashrc"
else
    echo "  fzf already sourced in ~/.bashrc"
fi

if ! grep -qF '.fzf.zsh' "$HOME/.zshrc" 2>/dev/null; then
    echo '' >> "$HOME/.zshrc"
    echo '[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"' >> "$HOME/.zshrc"
    echo "  added fzf source to ~/.zshrc"
else
    echo "  fzf already sourced in ~/.zshrc"
fi

echo "==> golang"
link "$REPO/golang/golang.bash" "$HOME/.golang.bash"
link "$REPO/golang/golang.zsh"  "$HOME/.golang.zsh"

if ! grep -qF '.golang.bash' "$HOME/.bashrc" 2>/dev/null; then
    echo '' >> "$HOME/.bashrc"
    echo '[ -f "$HOME/.golang.bash" ] && source "$HOME/.golang.bash"' >> "$HOME/.bashrc"
    echo "  added golang source to ~/.bashrc"
else
    echo "  golang already sourced in ~/.bashrc"
fi

if ! grep -qF '.golang.zsh' "$HOME/.zshrc" 2>/dev/null; then
    echo '' >> "$HOME/.zshrc"
    echo '[ -f "$HOME/.golang.zsh" ] && source "$HOME/.golang.zsh"' >> "$HOME/.zshrc"
    echo "  added golang source to ~/.zshrc"
else
    echo "  golang already sourced in ~/.zshrc"
fi

echo "done"
