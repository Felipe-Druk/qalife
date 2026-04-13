#!/bin/bash

# ==============================================================================
# VISUAL STUDIO CODE UPDATE SCRIPT (Safe & Robust)
# ==============================================================================
# Description: Standardizes VS Code repository and updates the application.
# Target OS: Kubuntu / Ubuntu / Debian
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
log_warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 1. Privilege check
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root (use sudo)."
   exit 1
fi

log_info "Checking for Visual Studio Code updates..."
apt-get update -qq

INSTALLED_VER=$(dpkg-query -W -f='${Version}' code 2>/dev/null)
CANDIDATE_VER=$(apt-cache policy code | grep "Candidate:" | awk '{print $2}')

if [ "$INSTALLED_VER" == "$CANDIDATE_VER" ]; then
    log_success "Visual Studio Code is already at the latest version ($INSTALLED_VER). ✅"
    exit 0
fi

log_info "New version detected: $CANDIDATE_VER (Current: $INSTALLED_VER)"
apt-get install -y code
log_success "VS Code has been updated to $CANDIDATE_VER"

log_info "=== Starting Visual Studio Code Update ==="

# 2. Dependency check
log_info "Checking for required dependencies (curl, gpg)..."
apt-get update -qq
apt-get install -y curl gpg apt-transport-https > /dev/null 2>&1

# 3. Repository & Key Configuration (Safe approach)
# We use a dedicated keyring and a separate .list file to avoid messing with sources.list
log_info "Configuring Microsoft repository and GPG keys..."

# Download and install the keyring only if it's missing or to refresh it
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg --yes

# Create the source list file
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list

# 4. Update and Upgrade
log_info "Updating package database..."
apt-get update -qq

# Check if VS Code is already installed
if dpkg -l | grep -q "^ii  code "; then
    log_info "Visual Studio Code found. Upgrading to the latest version..."
else
    log_info "Visual Studio Code not found. Performing fresh installation..."
fi

# We use 'install' without specific versions to let APT handle the latest stable release
# This is much safer than uninstalling and reinstalling.
if apt-get install -y code; then
    CURRENT_VERSION=$(dpkg-query -W -f='${Version}' code)
    log_success "Visual Studio Code is now at version: $CURRENT_VERSION"
else
    log_error "Installation/Upgrade failed. Please check your internet connection."
    exit 1
fi

# 5. Cleanup
log_info "Cleaning up temporary apt cache..."
apt-get autoclean -y > /dev/null

log_success "=== VS CODE UPDATE COMPLETED SUCCESSFULLY ==="
