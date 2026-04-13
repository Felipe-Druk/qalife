#!/bin/bash

# ==============================================================================
# QALIFE - SYSTEM UPDATE SCRIPT (Safe & Robust)
# ==============================================================================
# Description: Automated update & multiverse enabler for Debian/Ubuntu systems.
# Version: 0.0.1
# ==============================================================================

# 1. Resolve absolute paths dynamically (Safe execution under sudo)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="$(cd "$SCRIPT_DIR/../core" && pwd)"

# 2. Bootstrap Logger
if [[ -f "$CORE_DIR/logger.sh" ]]; then
    source "$CORE_DIR/logger.sh"
else
    echo -e "\033[0;31m[ERROR]\033[0m Missing core/logger.sh. Execution aborted."
    exit 1
fi

# 3. Privilege check
if [[ $EUID -ne 0 ]]; then
   fatal_error "This script must be run as root (use sudo)."
fi

log_info "=== Starting System Update ==="

# 4. Add Multiverse Repository (Safely)
if command -v add-apt-repository >/dev/null 2>&1; then
    log_info "Ensuring multiverse repository is enabled..."
    add-apt-repository -y multiverse >/dev/null 2>&1
else
    log_info "Adding multiverse manually to sources..."
    # Check if it already exists before adding to avoid duplicates
    grep -q "multiverse" /etc/apt/sources.list || echo "deb http://archive.ubuntu.com/ubuntu $(lsb_release -cs) multiverse" >> /etc/apt/sources.list
fi

# 5. Update Package Lists
log_info "Updating package database..."
if apt-get update -qq >/dev/null 2>&1; then
    log_success "Database updated successfully."
else
    fatal_error "Failed to update package database. Check your internet connection."
fi

# 6. Check for Available Updates
log_info "Checking for available updates..."
# Dist-upgrade simulation to capture all changes securely
UPGRADABLE=$(apt-get -s dist-upgrade | grep -oP '^\d+(?=\s+upgraded)' || echo 0)

if [[ "$UPGRADABLE" -eq 0 ]]; then
    log_success "Your system is already up to date. No packages to upgrade."
else
    log_info "Found $UPGRADABLE package(s) to update. Starting process..."
    if apt-get dist-upgrade -qq -y >/dev/null 2>&1; then
        log_success "Packages upgraded successfully."
    else
        fatal_error "System upgrade encountered an error."
    fi
fi

# 7. Post-Upgrade Cleanup
log_info "Removing obsolete packages and clearing cache..."
apt-get autoremove --purge -qq -y >/dev/null 2>&1
apt-get autoclean -qq -y >/dev/null 2>&1

log_success "=== SYSTEM UPDATE COMPLETED SUCCESSFULLY ==="