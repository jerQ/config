# Catppuccin Frappé colors, matching tmux/fzf/starship
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#737994"
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[default]="fg=#c6d0f5"
ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=#e78284"
ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=#ca9ee6"
ZSH_HIGHLIGHT_STYLES[alias]="fg=#8caaee"
ZSH_HIGHLIGHT_STYLES[builtin]="fg=#8caaee"
ZSH_HIGHLIGHT_STYLES[function]="fg=#8caaee"
ZSH_HIGHLIGHT_STYLES[command]="fg=#8caaee"
ZSH_HIGHLIGHT_STYLES[precommand]="fg=#8caaee,italic"
ZSH_HIGHLIGHT_STYLES[path]="fg=#babbf1"
ZSH_HIGHLIGHT_STYLES[globbing]="fg=#f4b8e4"
ZSH_HIGHLIGHT_STYLES[history-expansion]="fg=#f4b8e4"
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=#a6d189"
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=#a6d189"
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=#a6d189"
ZSH_HIGHLIGHT_STYLES[comment]="fg=#737994"

# zsh-syntax-highlighting must be sourced last
[ -f "$HOME/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ] && source "$HOME/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
[ -f "$HOME/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && source "$HOME/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
