#!/bin/bash
# Package Managers Installation
# Installs Homebrew and other essential package managers

set -euo pipefail

source "$(dirname "$0")/utils.sh"

section "Package Managers Setup"

### Xcode Command Line Tools ###
if confirm "Install Xcode Command Line Tools?"; then
    if xcode-select -p &>/dev/null; then
        success "Xcode Command Line Tools already installed"
    else
        log "Installing Xcode Command Line Tools..."
        xcode-select --install
        log "Please complete the Xcode installation in the dialog, then press Enter to continue..."
        read -r
        success "Xcode Command Line Tools installed"
    fi
fi

### Rosetta 2 (for Apple Silicon) ###
if [[ "$(uname -m)" == "arm64" ]]; then
    if confirm "Install Rosetta 2 for x86 compatibility?"; then
        if /usr/bin/pgrep -q oahd; then
            success "Rosetta 2 already installed"
        else
            log "Installing Rosetta 2..."
            sudo softwareupdate --install-rosetta --agree-to-license
            success "Rosetta 2 installed"
        fi
    fi
fi

### Homebrew ###
if confirm "Install Homebrew package manager?"; then
    if command_exists brew; then
        success "Homebrew already installed"
        log "Updating Homebrew..."
        brew update
    else
        log "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for current session
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            log "Configuring Homebrew for Apple Silicon..."
            eval "$(/opt/homebrew/bin/brew shellenv)"

            # Add to shell profile
            if [[ -f "$HOME/.zprofile" ]]; then
                if ! grep -q "homebrew/bin/brew shellenv" "$HOME/.zprofile"; then
                    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
                fi
            else
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
            fi
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        success "Homebrew installed"
    fi

    # Verify Homebrew is working
    if ! command_exists brew; then
        error "Homebrew installation failed or not in PATH"
    fi

    # Install Homebrew Bundle
    log "Installing Homebrew Bundle..."
    brew tap homebrew/bundle

    success "Homebrew setup complete"
fi

### Install from Brewfile ###
if command_exists brew; then
    BREWFILE_PATH="$(dirname "$0")/../Brewfile"

    if [[ -f "$BREWFILE_PATH" ]]; then
        if confirm "Install all packages from Brewfile?"; then
            log "Installing packages from Brewfile..."
            log "This may take a while (15-30 minutes)..."

            # Install all packages
            brew bundle install --file="$BREWFILE_PATH" --no-lock || warn "Some packages failed to install"

            success "Brewfile packages installed"
        fi
    else
        warn "Brewfile not found at $BREWFILE_PATH"
    fi
fi

### Mac App Store CLI ###
if command_exists brew && ! command_exists mas; then
    if confirm "Install Mac App Store CLI (mas)?"; then
        log "Installing mas..."
        brew install mas
        success "mas installed"
    fi
fi

### Cleanup ###
if command_exists brew; then
    log "Running Homebrew cleanup..."
    brew cleanup
    success "Cleanup complete"
fi

success "Package managers setup complete!"
