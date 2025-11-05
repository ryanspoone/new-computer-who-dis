#!/bin/bash
# Security Configuration
# Hardens macOS security settings

set -euo pipefail

source "$(dirname "$0")/utils.sh"

section "Security Configuration"

### Firewall ###
if confirm "Enable macOS firewall?"; then
    log "Enabling firewall..."
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned off
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsignedapp off
    success "Firewall enabled and configured"
fi

### FileVault ###
if confirm "Enable FileVault disk encryption?"; then
    if fdesetup status | grep -q "FileVault is On"; then
        success "FileVault is already enabled"
    else
        log "Enabling FileVault..."
        warn "You will need to restart your computer to complete FileVault setup"
        sudo fdesetup enable -user "$(whoami)"
        success "FileVault enabled (restart required)"
    fi
fi

### Gatekeeper ###
log "Checking Gatekeeper status..."
if sudo spctl --status | grep -q "assessments enabled"; then
    success "Gatekeeper is enabled"
else
    if confirm "Enable Gatekeeper?"; then
        sudo spctl --master-enable
        success "Gatekeeper enabled"
    fi
fi

### Require password after sleep/screensaver ###
log "Configuring password requirements..."
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
success "Password required immediately after sleep/screensaver"

### Disable automatic login ###
if confirm "Disable automatic login?"; then
    log "Disabling automatic login..."
    sudo defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser 2>/dev/null || true
    success "Automatic login disabled"
fi

### Show lock screen message ###
if confirm "Set lock screen message with contact info?"; then
    read -r -p "Enter lock screen message (e.g., 'If found, please contact: your@email.com'): " lock_message
    if [[ -n "$lock_message" ]]; then
        sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "$lock_message"
        success "Lock screen message set"
    fi
fi

### Disable guest account ###
if confirm "Disable guest account?"; then
    log "Disabling guest account..."
    sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess -bool false
    success "Guest account disabled"
fi

### Secure Safari ###
if confirm "Apply secure Safari settings?"; then
    log "Configuring Safari security..."

    # Enable fraudulent website warning
    defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

    # Block pop-ups
    defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false

    # Enable "Do Not Track"
    defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

    # Disable AutoFill
    defaults write com.apple.Safari AutoFillFromAddressBook -bool false
    defaults write com.apple.Safari AutoFillPasswords -bool false
    defaults write com.apple.Safari AutoFillCreditCardData -bool false
    defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false

    success "Safari security configured"
fi

### Check for software updates ###
if confirm "Enable automatic security updates?"; then
    log "Configuring automatic updates..."
    sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
    sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool true
    sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool true
    sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool true
    success "Automatic security updates enabled"
fi

### Disable IR remote control ###
if confirm "Disable infrared receiver (if applicable)?"; then
    log "Disabling IR receiver..."
    sudo defaults write /Library/Preferences/com.apple.driver.AppleIRController DeviceEnabled -bool false
    success "IR receiver disabled"
fi

### Disable Bluetooth when sleeping ###
if confirm "Disable Bluetooth when computer sleeps?"; then
    log "Configuring Bluetooth settings..."
    sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -int 0
    success "Bluetooth will turn off during sleep"
fi

### Secure terminal ###
if confirm "Apply secure terminal settings?"; then
    log "Configuring Terminal security..."

    # Don't display the last login message
    touch ~/.hushlogin

    # Set terminal to close windows when process exits cleanly
    defaults write com.apple.Terminal ShellExitAction -int 1

    success "Terminal security configured"
fi

### Show security summary ###
section "Security Summary"

log "Checking security status..."
echo ""

# Firewall
if sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | grep -q "enabled"; then
    echo "  ✅ Firewall: Enabled"
else
    echo "  ❌ Firewall: Disabled"
fi

# FileVault
if fdesetup status | grep -q "FileVault is On"; then
    echo "  ✅ FileVault: Enabled"
else
    echo "  ❌ FileVault: Disabled"
fi

# Gatekeeper
if sudo spctl --status | grep -q "enabled"; then
    echo "  ✅ Gatekeeper: Enabled"
else
    echo "  ❌ Gatekeeper: Disabled"
fi

# Screen lock
if defaults read com.apple.screensaver askForPassword 2>/dev/null | grep -q "1"; then
    echo "  ✅ Screen Lock: Enabled"
else
    echo "  ❌ Screen Lock: Not configured"
fi

echo ""
success "Security configuration complete!"
warn "Some security changes may require a restart to take effect"
