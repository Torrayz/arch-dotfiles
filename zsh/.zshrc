# =============================================================================
# Zsh Configuration — Torray Custom Arch Setup (Catppuccin Mocha)
# =============================================================================

export EDITOR="nvim"
export VISUAL="code"
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.npm-global/bin:$PATH"

# History Settings
HISTFILE="$HOME/.zsh_history"
HISTSIZE=20000
SAVEHIST=20000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt INTERACTIVE_COMMENTS
setopt AUTO_CD

# Completion System
autoload -Uz compinit
zmodload zsh/complist
compinit -C
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Keybindings
bindkey -e
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search
bindkey '^[[3~' delete-char
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Catppuccin Mocha FZF Theme
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--height 50% --layout=reverse --border=rounded"

# Aliases (Synced with Torrayz/dotfilesku + Developer Workflow)
alias c='clear'
alias cls='clear'
alias nf='fastfetch'
alias pf='fastfetch'
alias ff='fastfetch'
alias ls='eza -a --icons=always --group-directories-first'
alias ll='eza -al --icons=always --group-directories-first --git'
alias lt='eza -a --tree --level=2 --icons=always'
alias cat='bat --style=auto'
alias v='nvim'
alias vim='nvim'
alias vs='code .'
alias lg='lazygit'
alias top='btop'
alias wifi='nmtui'
alias keys='~/.config/rofi/keybindings.sh'
alias shutdown='systemctl poweroff'
alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'

# Git Shortcuts
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate -n 15'
alias gd='git diff'

# Arch Package Shortcuts
alias pacs='sudo pacman -S'
alias pacu='sudo pacman -Syu'
alias pacr='sudo pacman -Rns'
alias pacq='pacman -Ss'

# Load FZF, Zoxide, and Starship
command -v fzf >/dev/null 2>&1 && source <(fzf --zsh)
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"
command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

# Zsh Plugins (Autosuggestions + Syntax Highlighting)
if [ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#a6adc8'
    ZSH_AUTOSUGGEST_USE_ASYNC=1
    ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=80
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    bindkey '^[[C' forward-char
    bindkey '^F' autosuggest-accept
fi
if [ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Custom user overrides if ~/.zshrc_custom exists
if [ -f "$HOME/.zshrc_custom" ]; then
    source "$HOME/.zshrc_custom"
fi

# Auto-run Fastfetch with Custom Logo on Interactive Terminal Launch
if [[ $- == *i* ]] && [[ $(tty) == *"pts"* ]] && [[ -z "$FASTFETCH_SHOWN" ]]; then
    export FASTFETCH_SHOWN=1
    fastfetch
fi
