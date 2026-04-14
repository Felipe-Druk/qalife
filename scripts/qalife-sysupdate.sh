#!/bin/bash

# ==============================================================================
# QALIFE - SYSTEM UPDATE SCRIPT (Safe & Robust)
# ==============================================================================
# Description: Automated update & multiverse enabler for Debian/Ubuntu systems.
# Version: 0.1.0
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="$(cd "$SCRIPT_DIR/../core" && pwd)"

if [[ -f "$CORE_DIR/logger.sh" ]]; then
    source "$CORE_DIR/logger.sh"
else
    echo -e "\033[0;31m[ERROR]\033[0m Missing core/logger.sh. Execution aborted."
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   fatal_error "This script must be run as root (use sudo)."
fi

trap 'stop_spinner "Process interrupted."; exit 1' INT

log_info "=== Starting System Update ==="

start_spinner "Verifying multiverse repository..."
if command -v add-apt-repository >/dev/null 2>&1; then
    add-apt-repository -y multiverse >/dev/null 2>&1
else
    grep -q "multiverse" /etc/apt/sources.list || echo "deb http://archive.ubuntu.com/ubuntu $(lsb_release -cs) multiverse" >> /etc/apt/sources.list
fi
stop_spinner "Repositories verified."

start_spinner "Updating package database..."
if apt-get update -qq >/dev/null 2>&1; then
    stop_spinner "Database updated."
else
    stop_spinner "Failed."
    fatal_error "Failed to update package database. Check your internet connection."
fi

UPGRADABLE=$(apt-get -s dist-upgrade | grep -oP '^\d+(?=\s+upgraded)' || echo 0)

if [[ "$UPGRADABLE" -eq 0 ]]; then
    log_success "System is already up to date. No packages to upgrade."
else
    start_spinner "Upgrading $UPGRADABLE package(s). This may take a while..."
    if apt-get dist-upgrade -qq -y >/dev/null 2>&1; then
        stop_spinner "Packages upgraded successfully."
    else
        stop_spinner "Failed."
        fatal_error "System upgrade encountered an error."
    fi
fi

start_spinner "Performing post-upgrade cleanup..."
apt-get autoremove --purge -qq -y >/dev/null 2>&1
apt-get autoclean -qq -y >/dev/null 2>&1
stop_spinner "Cleanup finished."

log_success "=== SYSTEM UPDATE COMPLETED SUCCESSFULLY ==="