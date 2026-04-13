#!/bin/bash

# ==============================================================================
# ULTIMATE SYSTEM UPDATE SCRIPT (Safe & Robust)
# ==============================================================================
# Description: Automated update & multiverse enabler for Debian/Ubuntu systems.
# Version: 1.0.0
# ==============================================================================


# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 1. Privilege check
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root (use sudo)."
   exit 1
fi

log_info "Checking for available updates..."
# Check if there are packages to upgrade without installing them yet
UPGRADABLE=$(apt-get -s upgrade | grep -P '^\d+ upgraded' | cut -d' ' -f1)

if [ "$UPGRADABLE" -le 0 ]; then
    log_success "Your system is already up to date. Nothing to do! ✅"
    exit 0
fi

log_info "Found $UPGRADABLE packages to update. Starting process..."
apt-get dist-upgrade -y
log_success "System updated successfully!"

log_info "=== Starting System Update ==="

# 2. Add Multiverse Repository (Safely)
# Instead of echoing to sources.list, we use add-apt-repository which handles duplicates
if command -v add-apt-repository >/dev/null; then
    log_info "Ensuring multiverse repository is enabled..."
    add-apt-repository -y multiverse
else
    log_info "Adding multiverse manually to sources..."
    # Check if it already exists before adding to avoid duplicates
    grep -q "multiverse" /etc/apt/sources.list || echo "deb http://archive.ubuntu.com/ubuntu $(lsb_release -cs) multiverse" >> /etc/apt/sources.list
fi

# 3. Update Package Lists
log_info "Updating package database..."
if apt-get update; then
    log_success "Database updated successfully."
else
    log_error "Failed to update package database. Check your internet connection."
    exit 1
fi

# 4. System Upgrade
log_info "Upgrading system packages..."
# 'dist-upgrade' is often better for scripts as it handles dependency changes
apt-get dist-upgrade -y

# 5. Post-Upgrade Cleanup
log_info "Removing obsolete packages and clearing cache..."
apt-get autoremove --purge -y
apt-get autoclean -y

log_success "=== SYSTEM UPDATED SUCCESSFULLY ==="