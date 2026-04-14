#!/bin/bash

# ==============================================================================
# QALIFE - VISUAL STUDIO CODE UPDATE SCRIPT (Safe & Robust)
# ==============================================================================
# Description: Standardizes VS Code repository and updates the application.
# Target OS: Kubuntu / Ubuntu / Debian
# Version: 0.0.1
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

log_info "=== Starting Visual Studio Code Update ==="

start_spinner "Verifying dependencies and GPG keys..."
apt-get update -qq >/dev/null 2>&1
apt-get install -qq -y curl gpg apt-transport-https >/dev/null 2>&1
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg --yes >/dev/null 2>&1
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list
stop_spinner "Microsoft repositories configured."

start_spinner "Fetching latest version data..."
apt-get update -qq >/dev/null 2>&1
stop_spinner "Version data fetched."

INSTALLED_VER=$(dpkg-query -W -f='${Version}' code 2>/dev/null || echo "Not Installed")
CANDIDATE_VER=$(apt-cache policy code | grep "Candidate:" | awk '{print $2}')

if [[ -z "$CANDIDATE_VER" ]]; then
    fatal_error "Failed to fetch candidate version for VS Code. Repository configuration might be broken."
fi

if [[ "$INSTALLED_VER" == "$CANDIDATE_VER" ]]; then
    log_success "Visual Studio Code is already at the latest version ($INSTALLED_VER)."
else
    start_spinner "Installing/Upgrading VS Code to $CANDIDATE_VER..."
    if apt-get install -qq -y code >/dev/null 2>&1; then
        stop_spinner "Upgrade completed."
        CURRENT_VERSION=$(dpkg-query -W -f='${Version}' code)
        log_success "Current version: $CURRENT_VERSION"
    else
        stop_spinner "Failed."
        fatal_error "Installation failed. Please check your internet connection."
    fi
fi

log_success "=== VS CODE UPDATE COMPLETED SUCCESSFULLY ==="