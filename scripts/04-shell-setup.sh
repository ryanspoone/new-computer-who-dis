#!/bin/bash
# Shell Configuration and Enhancement
# Sets up zsh with Oh My Zsh or Starship prompt

set -euo pipefail

source "$(dirname "$0")/utils.sh"

section "Shell Setup"

### Set default shell to zsh ###
if [[ "$SHELL" != "$(which zsh)" ]]; then
    if confirm "Set zsh as default shell?"; then
        log "Changing default shell to zsh..."
        chsh -s "$(which zsh)"
        success "Default shell changed to zsh (takes effect after logout)"
    fi
fi

### Oh My Zsh or Starship ###
if confirm "Install Oh My Zsh (alternative: Starship)?"; then
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        success "Oh My Zsh already installed"
    else
        log "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        success "Oh My Zsh installed"

        # Install popular plugins
        if confirm "Install Oh My Zsh plugins (zsh-autosuggestions, zsh-syntax-highlighting)?"; then
            log "Installing zsh-autosuggestions..."
            git clone https://github.com/zsh-users/zsh-autosuggestions \
                "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

            log "Installing zsh-syntax-highlighting..."
            git clone https://github.com/zsh-users/zsh-syntax-highlighting \
                "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

            # Update .zshrc to enable plugins
            if [[ -f "$HOME/.zshrc" ]]; then
                backup_file "$HOME/.zshrc"
                sed -i.bak 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker kubectl npm node python)/g' "$HOME/.zshrc"
                success "Oh My Zsh plugins installed and configured"
            fi
        fi

        # Set theme
        if confirm "Set Oh My Zsh theme to 'robbyrussell'?"; then
            if [[ -f "$HOME/.zshrc" ]]; then
                sed -i.bak 's/ZSH_THEME=".*"/ZSH_THEME="robbyrussell"/g' "$HOME/.zshrc"
                success "Oh My Zsh theme set"
            fi
        fi
    fi
elif confirm "Install Starship prompt instead?"; then
    if command_exists starship; then
        success "Starship already installed"
    else
        log "Installing Starship..."
        brew install starship

        # Add to .zshrc
        if [[ -f "$HOME/.zshrc" ]]; then
            backup_file "$HOME/.zshrc"
            if ! grep -q "starship init zsh" "$HOME/.zshrc"; then
                echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
            fi
        else
            echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
        fi

        # Create starship config
        mkdir -p "$HOME/.config"
        if [[ ! -f "$HOME/.config/starship.toml" ]]; then
            cat > "$HOME/.config/starship.toml" << 'EOF'
# Starship configuration
format = """
[┌───────────────────>](bold green)
[│](bold green)$directory$git_branch$git_status$nodejs$python$rust$golang
[└─>](bold green) """

[directory]
truncation_length = 3
truncate_to_repo = true

[git_branch]
symbol = " "

[git_status]
ahead = "⇡${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
behind = "⇣${count}"

[nodejs]
symbol = " "

[python]
symbol = " "

[rust]
symbol = " "

[golang]
symbol = " "
EOF
            success "Starship installed and configured"
        fi
    fi
fi

### Useful Shell Aliases ###
if confirm "Add useful shell aliases?"; then
    ALIAS_FILE="$HOME/.aliases"

    log "Creating aliases file..."
    cat > "$ALIAS_FILE" << 'EOF'
# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# ls replacements (using exa if available)
if command -v exa &> /dev/null; then
    alias ls='exa'
    alias ll='exa -lah'
    alias la='exa -a'
    alias lt='exa --tree'
else
    alias ll='ls -lah'
    alias la='ls -A'
fi

# cat replacement (using bat if available)
if command -v bat &> /dev/null; then
    alias cat='bat'
fi

# Git aliases
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gco='git checkout'
alias glog='git log --oneline --graph --decorate'

# Development
alias dc='docker-compose'
alias dps='docker ps'
alias k='kubectl'

# Network
alias myip='curl ifconfig.me'
alias localip='ipconfig getifaddr en0'
alias ports='lsof -i -P -n | grep LISTEN'

# System
alias update='brew update && brew upgrade && brew cleanup'
alias cleanup='find . -name ".DS_Store" -delete'

# Quick edits
alias zshconfig='code ~/.zshrc'
alias ohmyzsh='code ~/.oh-my-zsh'
alias hosts='sudo code /etc/hosts'

# Directories
alias dev='cd ~/dev'
alias dl='cd ~/Downloads'
alias dt='cd ~/Desktop'

# NPM
alias nrs='npm run start'
alias nrb='npm run build'
alias nrt='npm run test'
alias nrd='npm run dev'

# Python
alias py='python3'
alias pip='pip3'

# Reload shell
alias reload='source ~/.zshrc'
EOF

    # Add to .zshrc
    if [[ -f "$HOME/.zshrc" ]]; then
        if ! grep -q "source.*\.aliases" "$HOME/.zshrc"; then
            echo "" >> "$HOME/.zshrc"
            echo "# Load aliases" >> "$HOME/.zshrc"
            echo "[ -f ~/.aliases ] && source ~/.aliases" >> "$HOME/.zshrc"
        fi
    fi

    success "Aliases created at $ALIAS_FILE"
fi

### Environment Variables ###
if confirm "Set up environment variables?"; then
    ENV_FILE="$HOME/.env_vars"

    log "Creating environment variables file..."
    cat > "$ENV_FILE" << 'EOF'
# Editor
export EDITOR='code --wait'
export VISUAL='code --wait'

# Language settings
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# History settings
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups

# Development paths
export DEV_DIR="$HOME/dev"

# Node
export NODE_ENV=development

# Python
export PYTHONDONTWRITEBYTECODE=1

# GPG
export GPG_TTY=$(tty)

# FZF settings
if command -v fzf &> /dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# Homebrew settings
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1
EOF

    # Add to .zshrc
    if [[ -f "$HOME/.zshrc" ]]; then
        if ! grep -q "source.*\.env_vars" "$HOME/.zshrc"; then
            echo "" >> "$HOME/.zshrc"
            echo "# Load environment variables" >> "$HOME/.zshrc"
            echo "[ -f ~/.env_vars ] && source ~/.env_vars" >> "$HOME/.zshrc"
        fi
    fi

    success "Environment variables configured"
fi

### FZF Setup ###
if command_exists fzf; then
    if confirm "Configure FZF key bindings?"; then
        log "Setting up FZF..."
        if [[ -f "$HOME/.zshrc" ]]; then
            if ! grep -q "fzf" "$HOME/.zshrc"; then
                echo "" >> "$HOME/.zshrc"
                echo "# FZF" >> "$HOME/.zshrc"
                echo "[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh" >> "$HOME/.zshrc"
            fi
        fi
        $(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc
        success "FZF configured"
    fi
fi

success "Shell setup complete!"
warn "Changes will take effect in new terminal sessions or after running: source ~/.zshrc"
