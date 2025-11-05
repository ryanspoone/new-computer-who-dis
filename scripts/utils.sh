#!/bin/bash
# Utility functions for setup scripts

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')] WARNING:${NC} $1"
}

error() {
    echo -e "${RED}[$(date +'%H:%M:%S')] ERROR:${NC} $1"
    exit 1
}

success() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"
}

section() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════${NC}"
    echo ""
}

confirm() {
    read -r -p "$(echo -e ${BLUE}$1 [y/N]${NC}) " response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if running on macOS
check_macos() {
    if [[ "$(uname)" != "Darwin" ]]; then
        error "This script is designed for macOS only. Detected OS: $(uname)"
    fi
}

# Get macOS version
get_macos_version() {
    sw_vers -productVersion
}

# Compare versions (returns 0 if version1 >= version2)
version_gte() {
    printf '%s\n%s' "$2" "$1" | sort -C -V
}

# Log to file
log_to_file() {
    local log_file="${HOME}/.macos-setup.log"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$log_file"
}

# Backup file before modification
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        cp "$file" "${file}.backup.$(date +%Y%m%d_%H%M%S)"
        log "Backed up $file"
    fi
}

# Check if running with sudo
is_sudo() {
    [[ $EUID -eq 0 ]]
}

# Print system info
print_system_info() {
    log "macOS Version: $(get_macos_version)"
    log "Architecture: $(uname -m)"
    log "Hostname: $(hostname)"
}
