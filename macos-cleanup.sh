#!/bin/bash
# macOS Cleanup and Uninstall Script
# Removes packages and resets configurations installed by the setup script
#
# WARNING: This will remove applications and configurations!
# Review the script before running.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')] WARNING:${NC} $1"
}

error() {
    echo -e "${RED}[$(date +'%H:%M:%S')] ERROR:${NC} $1"
}

confirm() {
    read -r -p "$(echo -e ${YELLOW}$1 [y/N]${NC}) " response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

echo -e "${RED}"
cat << "EOF"
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║              macOS CLEANUP & UNINSTALL                   ║
║                                                          ║
║  WARNING: This will remove applications and             ║
║     configurations installed by the setup script!       ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

if ! confirm "Are you sure you want to continue?"; then
    log "Cleanup cancelled"
    exit 0
fi

if ! confirm "Are you REALLY sure? This cannot be undone!"; then
    log "Cleanup cancelled"
    exit 0
fi

### Backup Important Files ###
if confirm "Create backup of important dotfiles before cleanup?"; then
    BACKUP_DIR="$HOME/macos-setup-backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    log "Creating backup at $BACKUP_DIR..."

    [[ -f "$HOME/.zshrc" ]] && cp "$HOME/.zshrc" "$BACKUP_DIR/"
    [[ -f "$HOME/.bashrc" ]] && cp "$HOME/.bashrc" "$BACKUP_DIR/"
    [[ -f "$HOME/.gitconfig" ]] && cp "$HOME/.gitconfig" "$BACKUP_DIR/"
    [[ -d "$HOME/.ssh" ]] && cp -r "$HOME/.ssh" "$BACKUP_DIR/"
    [[ -d "$HOME/.config" ]] && cp -r "$HOME/.config" "$BACKUP_DIR/"

    log "Backup created at $BACKUP_DIR"
fi

### Stop Services ###
if confirm "Stop running services (databases, etc.)?"; then
    log "Stopping services..."

    brew services stop --all 2>/dev/null || true

    log "Services stopped"
fi

### Remove Homebrew Packages ###
if confirm "Remove Homebrew packages?"; then
    if command -v brew &>/dev/null; then
        log "Removing Homebrew packages..."

        # Remove applications
        brew list --cask | xargs brew uninstall --cask --force 2>/dev/null || true

        # Remove formulas
        brew list --formula | xargs brew uninstall --force --ignore-dependencies 2>/dev/null || true

        log "Homebrew packages removed"
    else
        warn "Homebrew not found"
    fi
fi

### Remove Homebrew ###
if confirm "Remove Homebrew itself?"; then
    if command -v brew &>/dev/null; then
        log "Removing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
        log "Homebrew removed"
    else
        warn "Homebrew not found"
    fi
fi

### Remove Oh My Zsh ###
if confirm "Remove Oh My Zsh?"; then
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log "Removing Oh My Zsh..."
        rm -rf "$HOME/.oh-my-zsh"
        log "Oh My Zsh removed"
    else
        warn "Oh My Zsh not found"
    fi
fi

### Clean Shell Configuration ###
if confirm "Remove custom shell configurations (.aliases, .env_vars)?"; then
    log "Removing shell configurations..."

    [[ -f "$HOME/.aliases" ]] && rm "$HOME/.aliases"
    [[ -f "$HOME/.env_vars" ]] && rm "$HOME/.env_vars"
    [[ -f "$HOME/.hushlogin" ]] && rm "$HOME/.hushlogin"

    log "Shell configurations removed"
fi

### Clean VS Code ###
if confirm "Remove VS Code extensions and settings?"; then
    if command -v code &>/dev/null; then
        log "Removing VS Code extensions..."
        code --list-extensions | xargs -n 1 code --uninstall-extension 2>/dev/null || true

        if confirm "Remove VS Code settings?"; then
            VSCODE_DIR="$HOME/Library/Application Support/Code"
            [[ -d "$VSCODE_DIR" ]] && rm -rf "$VSCODE_DIR"
            log "VS Code settings removed"
        fi
    else
        warn "VS Code not found"
    fi
fi

### Clean npm Global Packages ###
if confirm "Remove global npm packages?"; then
    if command -v npm &>/dev/null; then
        log "Removing global npm packages..."
        npm list -g --depth=0 | grep -v npm | awk '{print $2}' | awk -F@ '{print $1}' | xargs npm uninstall -g 2>/dev/null || true
        log "Global npm packages removed"
    fi
fi

### Clean Development Directory ###
if confirm "Remove ~/dev directory? (WARNING: This contains your projects!)"; then
    if [[ -d "$HOME/dev" ]]; then
        warn "This will delete all projects in ~/dev!"
        if confirm "Are you absolutely sure?"; then
            log "Removing ~/dev directory..."
            rm -rf "$HOME/dev"
            log "~/dev removed"
        fi
    fi
fi

### Reset System Preferences ###
if confirm "Reset system preferences to defaults?"; then
    log "Resetting system preferences..."

    # Finder
    defaults delete com.apple.finder AppleShowAllFiles 2>/dev/null || true
    defaults delete com.apple.finder ShowPathbar 2>/dev/null || true
    defaults delete com.apple.finder ShowStatusBar 2>/dev/null || true

    # Dock
    defaults delete com.apple.dock tilesize 2>/dev/null || true
    defaults delete com.apple.dock autohide 2>/dev/null || true

    # Keyboard
    defaults delete NSGlobalDomain KeyRepeat 2>/dev/null || true
    defaults delete NSGlobalDomain InitialKeyRepeat 2>/dev/null || true

    killall Finder 2>/dev/null || true
    killall Dock 2>/dev/null || true

    log "System preferences reset"
fi

### Clean Caches ###
if confirm "Clean Homebrew and system caches?"; then
    log "Cleaning caches..."

    # Homebrew cache
    [[ -d "$HOME/Library/Caches/Homebrew" ]] && rm -rf "$HOME/Library/Caches/Homebrew"

    # npm cache
    command -v npm &>/dev/null && npm cache clean --force 2>/dev/null || true

    # yarn cache
    command -v yarn &>/dev/null && yarn cache clean 2>/dev/null || true

    log "Caches cleaned"
fi

### Final Cleanup ###
log "Running final cleanup..."

# Remove .DS_Store files
find "$HOME" -name ".DS_Store" -delete 2>/dev/null || true

# Empty trash
rm -rf "$HOME/.Trash/*" 2>/dev/null || true

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                 Cleanup Complete!                        ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

if [[ -n "${BACKUP_DIR:-}" ]]; then
    log "Backup saved at: $BACKUP_DIR"
fi

warn "You may need to restart your computer for all changes to take effect"
log "To restore shell to default: chsh -s /bin/zsh"
