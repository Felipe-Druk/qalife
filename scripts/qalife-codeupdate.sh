#!/bin/bash

# ==============================================================================
# QALIFE - VISUAL STUDIO CODE UPDATE SCRIPT (Safe & Robust)
# ==============================================================================
# Description: Standardizes VS Code repository and updates the application.
# Target OS: Kubuntu / Ubuntu / Debian
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

log_info "=== Starting Visual Studio Code Update ==="

# 4. Dependency check
log_info "Verifying required dependencies (curl, gpg, apt-transport-https)..."
apt-get update -qq >/dev/null 2>&1
apt-get install -qq -y curl gpg apt-transport-https >/dev/null 2>&1

# 5. Repository & Key Configuration (Safe approach)
log_info "Configuring Microsoft repository and GPG keys..."

# Download and install the keyring safely
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg --yes >/dev/null 2>&1

# Create the source list file
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list

# 6. Update Package Database
log_info "Refreshing package database with Microsoft sources..."
apt-get update -qq >/dev/null 2>&1

# 7. Version Check
INSTALLED_VER=$(dpkg-query -W -f='${Version}' code 2>/dev/null || echo "Not Installed")
CANDIDATE_VER=$(apt-cache policy code | grep "Candidate:" | awk '{print $2}')

if [[ -z "$CANDIDATE_VER" ]]; then
    fatal_error "Failed to fetch candidate version for VS Code. Repository configuration might be broken."
fi

if [[ "$INSTALLED_VER" == "$CANDIDATE_VER" ]]; then
    log_success "Visual Studio Code is already at the latest version ($INSTALLED_VER)."
    # Proceed to cleanup before exiting cleanly
else
    if [[ "$INSTALLED_VER" == "Not Installed" ]]; then
        log_info "Visual Studio Code not found. Performing fresh installation..."
    else
        log_info "New version detected: $CANDIDATE_VER (Current: $INSTALLED_VER). Upgrading..."
    fi

    # 8. Installation/Upgrade
    if apt-get install -qq -y code >/dev/null 2>&1; then
        CURRENT_VERSION=$(dpkg-query -W -f='${Version}' code)
        log_success "Visual Studio Code is now at version: $CURRENT_VERSION"
    else
        fatal_error "Installation/Upgrade failed. Please check your internet connection."
    fi
fi

# 9. Cleanup
log_info "Cleaning up temporary apt cache..."
apt-get autoclean -qq -y >/dev/null 2>&1

log_success "=== VS CODE UPDATE COMPLETED SUCCESSFULLY ==="