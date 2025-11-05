#!/bin/bash
# macOS System Setup Script
#
# Comprehensive setup script for new macOS development machines
#
# Features:
# - System preferences configuration
# - Package management (Homebrew)
# - Development tools installation
# - Shell customization (zsh, Oh My Zsh, Starship)
# - Security hardening
# - VS Code setup
# - And much more!
#
# Usage:
#   ./macos-setup.sh                    # Interactive mode
#   ./macos-setup.sh --config FILE      # Use configuration file
#   ./macos-setup.sh --help             # Show help
#
# Documentation: https://github.com/ryanspoone/new-computer-who-dis

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"

# Load utilities
source "$SCRIPTS_DIR/utils.sh"

# Configuration file
CONFIG_FILE="${CONFIG_FILE:-}"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        --help|-h)
            cat << EOF
macOS Setup Script

Usage:
  $0                    Interactive mode
  $0 --config FILE      Use configuration file
  $0 --help             Show this help message

Configuration:
  Copy .setup-config.example to .setup-config and customize
  Use --config to specify a different configuration file

Scripts:
  All modular scripts are in the scripts/ directory:
    - 01-system-preferences.sh  System UI and preferences
    - 02-package-managers.sh    Homebrew and package installation
    - 03-development-tools.sh   Git, SSH, languages, databases
    - 04-shell-setup.sh         Zsh, Oh My Zsh, aliases
    - 05-security.sh            Security hardening
    - 06-vscode.sh              VS Code extensions and settings

Documentation:
  See README.md for full documentation

EOF
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Load configuration if specified
if [[ -n "$CONFIG_FILE" ]]; then
    if [[ -f "$CONFIG_FILE" ]]; then
        log "Loading configuration from $CONFIG_FILE"
        source "$CONFIG_FILE"
    else
        error "Configuration file not found: $CONFIG_FILE"
    fi
fi

# Verify running on macOS
check_macos

# Display header
clear
echo -e "${CYAN}"
cat << "EOF"
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║              macOS Development Setup                     ║
║                                                          ║
║  Complete setup script for new development machines     ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

print_system_info

echo ""
log "This script will help you set up your macOS development environment"
log "You'll be prompted for each section - you can skip anything you don't want"
echo ""

if [[ -z "$CONFIG_FILE" ]]; then
    log "Tip: You can create a .setup-config file to automate this process"
    log "   See .setup-config.example for details"
    echo ""
fi

if ! confirm "Ready to begin setup?"; then
    log "Setup cancelled"
    exit 0
fi

# Start logging
LOG_FILE="$HOME/.macos-setup.log"
log "Logging to $LOG_FILE"
exec > >(tee -a "$LOG_FILE")
exec 2>&1

log_to_file "=== Setup started ==="

# Personal information (needed for Git and SSH)
if [[ -z "${GIT_NAME:-}" ]] || [[ -z "${GIT_EMAIL:-}" ]]; then
    section "Personal Information"
    read -r -p "Enter your full name for Git: " GIT_NAME
    read -r -p "Enter your email address for Git: " GIT_EMAIL
    export GIT_NAME GIT_EMAIL
fi

# Track start time
START_TIME=$(date +%s)

# Run setup scripts
SETUP_SCRIPTS=(
    "01-system-preferences.sh"
    "02-package-managers.sh"
    "03-development-tools.sh"
    "04-shell-setup.sh"
    "05-security.sh"
    "06-vscode.sh"
)

for script in "${SETUP_SCRIPTS[@]}"; do
    script_path="$SCRIPTS_DIR/$script"

    if [[ -f "$script_path" ]]; then
        echo ""
        if confirm "Run $script?"; then
            log "Running $script..."

            # Make executable
            chmod +x "$script_path"

            # Run script
            if bash "$script_path"; then
                success "$script completed successfully"
            else
                warn "$script encountered errors (check log for details)"
            fi
        else
            log "Skipping $script"
        fi
    else
        warn "Script not found: $script_path"
    fi
done

# Copy dotfiles
section "Dotfiles"

if confirm "Install dotfile templates?"; then
    log "Installing dotfiles..."

    DOTFILES_DIR="$SCRIPT_DIR/dotfiles"

    if [[ -d "$DOTFILES_DIR" ]]; then
        # Backup and copy gitconfig
        if [[ -f "$DOTFILES_DIR/.gitconfig" ]]; then
            if [[ -f "$HOME/.gitconfig" ]]; then
                backup_file "$HOME/.gitconfig"
            fi
            log "Copy $DOTFILES_DIR/.gitconfig to ~/.gitconfig and customize"
        fi

        # Copy gitignore_global
        if [[ -f "$DOTFILES_DIR/.gitignore_global" ]]; then
            cp "$DOTFILES_DIR/.gitignore_global" "$HOME/.gitignore_global"
            git config --global core.excludesfile ~/.gitignore_global
            success "Global gitignore installed"
        fi

        # Copy editorconfig
        if [[ -f "$DOTFILES_DIR/.editorconfig" ]]; then
            cp "$DOTFILES_DIR/.editorconfig" "$HOME/.editorconfig"
            success "EditorConfig installed"
        fi

        success "Dotfiles installed (remember to customize .gitconfig with your info)"
    else
        warn "Dotfiles directory not found"
    fi
fi

# Calculate duration
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

# Final summary
section "Setup Complete!"

echo ""
echo "  Total time: ${MINUTES}m ${SECONDS}s"
echo ""

log "Setup Summary:"
echo "  - System preferences configured"
echo "  - Package managers installed"
echo "  - Development tools ready"
echo "  - Shell customized"
echo "  - Security hardened"
echo "  - VS Code configured"
echo ""

section "Next Steps"

echo "1. Restart your computer for all changes to take effect"
echo ""
echo "2. Add SSH key to GitHub/GitLab:"
echo "   cat ~/.ssh/id_ed25519.pub | pbcopy"
echo "   Then paste at: https://github.com/settings/keys"
echo ""
echo "3. Customize your dotfiles:"
echo "   - Edit ~/.gitconfig with your information"
echo "   - Review ~/.zshrc for additional customizations"
echo "   - Check ~/Library/Application Support/Code/User/settings.json"
echo ""
echo "4. Install additional software:"
echo "   - Edit Brewfile and run: brew bundle install"
echo "   - Install Mac App Store apps with: mas install <id>"
echo ""
echo "5. Project-specific setup:"
echo "   - Clone your repositories to ~/dev/"
echo "   - Install project dependencies"
echo "   - Set up databases and services"
echo ""
echo "6. Documentation:"
echo "   - README.md - Full documentation"
echo "   - scripts/ - Individual setup modules"
echo "   - dotfiles/ - Configuration templates"
echo ""

warn "Important: Restart your Mac for all changes to take effect!"
echo ""

log_to_file "=== Setup completed in ${MINUTES}m ${SECONDS}s ==="

if confirm "Would you like to restart now?"; then
    log "Restarting in 5 seconds... (Ctrl+C to cancel)"
    sleep 5
    sudo shutdown -r now
else
    log "Remember to restart when convenient!"
fi
