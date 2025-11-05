#!/bin/bash
# Development Tools Installation
# Sets up programming languages, version managers, and databases

set -euo pipefail

source "$(dirname "$0")/utils.sh"

section "Development Tools"

### Git Configuration ###
if confirm "Configure Git?"; then
    if [[ -z "${GIT_NAME:-}" ]] || [[ -z "${GIT_EMAIL:-}" ]]; then
        read -p "Enter your full name for Git: " GIT_NAME
        read -p "Enter your email address for Git: " GIT_EMAIL
        export GIT_NAME GIT_EMAIL
    fi

    log "Configuring Git..."
    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"

    # Recommended Git settings
    git config --global init.defaultBranch main
    git config --global pull.rebase false
    git config --global core.editor "code --wait"
    git config --global merge.conflictstyle diff3

    # Useful aliases
    git config --global alias.st "status"
    git config --global alias.co "checkout"
    git config --global alias.br "branch"
    git config --global alias.ci "commit"
    git config --global alias.unstage "reset HEAD --"
    git config --global alias.last "log -1 HEAD"
    git config --global alias.lg "log --oneline --graph --decorate --all"

    success "Git configured"
fi

### SSH Keys ###
if confirm "Generate SSH keys?"; then
    if [[ -f ~/.ssh/id_ed25519 ]] || [[ -f ~/.ssh/id_rsa ]]; then
        warn "SSH keys already exist. Skipping generation."
        if [[ -f ~/.ssh/id_ed25519.pub ]]; then
            log "Your ED25519 public key:"
            cat ~/.ssh/id_ed25519.pub
        elif [[ -f ~/.ssh/id_rsa.pub ]]; then
            log "Your RSA public key:"
            cat ~/.ssh/id_rsa.pub
        fi
    else
        log "Generating ED25519 SSH key..."
        ssh-keygen -t ed25519 -C "${GIT_EMAIL}"

        # Start ssh-agent and add key
        eval "$(ssh-agent -s)"
        ssh-add ~/.ssh/id_ed25519

        # Add to macOS keychain
        ssh-add --apple-use-keychain ~/.ssh/id_ed25519 2>/dev/null || true

        success "SSH key generated!"
        log "Your public key (add this to GitHub/GitLab):"
        cat ~/.ssh/id_ed25519.pub

        # Create SSH config for convenience
        if [[ ! -f ~/.ssh/config ]]; then
            log "Creating SSH config..."
            cat > ~/.ssh/config << 'EOF'
Host *
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_ed25519

Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519

Host gitlab.com
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/id_ed25519
EOF
            chmod 600 ~/.ssh/config
            success "SSH config created"
        fi

        echo ""
        log "Press Enter to continue..."
        read -r
    fi
fi

### GitHub CLI Setup ###
if command_exists gh; then
    if confirm "Authenticate with GitHub CLI?"; then
        log "Starting GitHub CLI authentication..."
        gh auth login
        success "GitHub CLI authenticated"
    fi
fi

### Node.js Setup ###
if command_exists node; then
    log "Node.js version: $(node --version)"
    log "npm version: $(npm --version)"

    if confirm "Configure npm global packages location?"; then
        # Set npm global directory to user directory
        mkdir -p ~/.npm-global
        npm config set prefix '~/.npm-global'

        # Add to PATH if not already there
        if [[ -f "$HOME/.zshrc" ]] && ! grep -q "npm-global/bin" "$HOME/.zshrc"; then
            echo 'export PATH=~/.npm-global/bin:$PATH' >> "$HOME/.zshrc"
        fi
        if [[ -f "$HOME/.bashrc" ]] && ! grep -q "npm-global/bin" "$HOME/.bashrc"; then
            echo 'export PATH=~/.npm-global/bin:$PATH' >> "$HOME/.bashrc"
        fi

        success "npm configured"
    fi

    if confirm "Install common global npm packages?"; then
        log "Installing global npm packages..."
        npm install -g \
            typescript \
            ts-node \
            eslint \
            prettier \
            nodemon \
            npm-check-updates \
            serve \
            http-server || warn "Some packages failed to install"

        success "Global npm packages installed"
    fi
fi

### Python Setup ###
if command_exists python3; then
    log "Python version: $(python3 --version)"

    if command_exists pip3; then
        if confirm "Install common Python packages?"; then
            log "Installing Python packages..."
            pip3 install --user --upgrade \
                pip \
                virtualenv \
                pipenv \
                black \
                pylint \
                flake8 \
                pytest \
                requests \
                ipython || warn "Some packages failed to install"

            success "Python packages installed"
        fi
    fi
fi

### Database Setup ###
if command_exists psql; then
    if confirm "Start and configure PostgreSQL?"; then
        log "Starting PostgreSQL..."
        brew services start postgresql@15
        success "PostgreSQL started"
    fi
fi

if command_exists mysql; then
    if confirm "Start and configure MySQL?"; then
        log "Starting MySQL..."
        brew services start mysql
        success "MySQL started"
    fi
fi

if command_exists redis-server; then
    if confirm "Start Redis?"; then
        log "Starting Redis..."
        brew services start redis
        success "Redis started"
    fi
fi

### Docker Setup ###
if command_exists docker; then
    log "Docker version: $(docker --version)"
    if confirm "Verify Docker is running?"; then
        if ! docker ps &>/dev/null; then
            warn "Docker is not running. Please start Docker Desktop."
            log "Press Enter after starting Docker Desktop..."
            read -r
        else
            success "Docker is running"
        fi
    fi
fi

### Development Directory ###
if confirm "Create ~/dev directory for projects?"; then
    log "Creating development directory structure..."
    mkdir -p ~/dev/{personal,work,playground,opensource}
    success "Development directories created at ~/dev/"
fi

success "Development tools setup complete!"
