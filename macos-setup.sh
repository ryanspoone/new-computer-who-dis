#!/bin/bash
# Setup fresh MacOS system
#
# This script will:
# - Configure Finder settings
# - Install Xcode Command Line Tools
# - Install Homebrew package manager
# - Install Node.js and Yarn
# - Install common development applications
# - Generate SSH keys
# - Configure Git
# - Set up development environment
#
# IMPORTANT: Review this script before running!
# Some settings are personalized and should be modified.
#
# Estimated time: 30-60 minutes depending on internet speed

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1"
    exit 1
}

confirm() {
    read -r -p "$1 [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Verify running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    error "This script is designed for macOS only. Detected OS: $(uname)"
fi

log "Starting macOS setup..."

# Configure personal information
read -p "Enter your full name for Git: " GIT_NAME
read -p "Enter your email address for Git: " GIT_EMAIL

# Finder Settings
if confirm "Do you want to configure Finder settings?"; then
    log "Configuring Finder settings..."

    # Show Library folder
    chflags nohidden ~/Library

    # Show hidden files
    defaults write com.apple.finder AppleShowAllFiles YES

    # Show path bar
    defaults write com.apple.finder ShowPathbar -bool true

    # Show status bar
    defaults write com.apple.finder ShowStatusBar -bool true

    log "Finder settings configured. Restart Finder for changes to take effect."
fi

# Install Xcode Command Line Tools
if confirm "Do you want to install Xcode Command Line Tools?"; then
    if xcode-select -p &>/dev/null; then
        log "Xcode Command Line Tools already installed"
    else
        log "Installing Xcode Command Line Tools..."
        xcode-select --install
        log "Please complete the Xcode installation in the dialog, then press Enter to continue..."
        read -r
    fi
fi

# Install Homebrew
if confirm "Do you want to install Homebrew?"; then
    if command -v brew &>/dev/null; then
        log "Homebrew already installed"
    else
        log "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            log "Setting up Homebrew for Apple Silicon..."
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi
fi

# Verify Homebrew is available
if ! command -v brew &>/dev/null; then
    error "Homebrew is not available. Please install it manually."
fi

# Install Node.js and Yarn
if confirm "Do you want to install Node.js and Yarn?"; then
    log "Installing Node.js and Yarn..."
    brew install node
    brew install yarn
    log "Node.js version: $(node --version)"
    log "Yarn version: $(yarn --version)"
fi

# Install applications
if confirm "Do you want to install common development applications?"; then
    log "Installing applications..."

    # See https://formulae.brew.sh/formula/
    brew install --cask visual-studio-code
    brew install --cask google-chrome
    brew install --cask firefox
    brew install --cask authy
    brew install --cask dashlane
    brew install --cask iterm2
    brew install --cask slack
    brew install --cask sketch
    brew install --cask postman
    brew install --cask flux

    # Install shellcheck as a formula (not cask)
    brew install shellcheck

    log "Applications installed successfully"
fi

# Install Fira Code font
if confirm "Do you want to install Fira Code font?"; then
    log "Installing Fira Code font..."
    brew install --cask font-fira-code
fi

# Generate SSH keys
if confirm "Do you want to generate SSH keys?"; then
    if [[ -f ~/.ssh/id_ed25519 ]] || [[ -f ~/.ssh/id_rsa ]]; then
        warn "SSH keys already exist. Skipping generation."
        if [[ -f ~/.ssh/id_ed25519.pub ]]; then
            log "Your public key:"
            cat ~/.ssh/id_ed25519.pub
        elif [[ -f ~/.ssh/id_rsa.pub ]]; then
            log "Your public key:"
            cat ~/.ssh/id_rsa.pub
        fi
    else
        log "Generating ED25519 SSH key..."
        ssh-keygen -t ed25519 -C "$GIT_EMAIL"

        # Start ssh-agent and add key
        eval "$(ssh-agent -s)"

        # Add key to ssh-agent
        ssh-add ~/.ssh/id_ed25519

        log "SSH key generated successfully!"
        log "Your public key (copy this to GitHub/GitLab):"
        cat ~/.ssh/id_ed25519.pub

        echo ""
        log "Press Enter to continue..."
        read -r
    fi
fi

# Setup Git configuration
if confirm "Do you want to configure Git?"; then
    log "Configuring Git..."
    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"

    # Additional recommended Git settings
    git config --global init.defaultBranch main
    git config --global pull.rebase false

    log "Git configured successfully"
fi

# Create development folder
if confirm "Do you want to create a ~/dev folder?"; then
    log "Creating development folder..."
    mkdir -p ~/dev
    log "Created ~/dev directory"
fi

# Cleanup
log "Running Homebrew cleanup..."
brew cleanup

log "============================================"
log "Setup complete!"
log "============================================"
echo ""
warn "Please restart your Mac (or at least log out and back in) for all changes to take effect."
echo ""
log "Next steps:"
echo "  1. Restart your computer"
echo "  2. If you generated SSH keys, add them to GitHub/GitLab"
echo "  3. Configure your shell (zsh/bash) with additional customizations"
echo "  4. Install any additional tools specific to your workflow"
