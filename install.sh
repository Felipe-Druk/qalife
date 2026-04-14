#!/bin/bash

# ==============================================================================
# QALIFE - AUTO INSTALLER & CONFIGURATOR
# ==============================================================================
# Description: Safely installs Qalife tools into the user's environment.
# ==============================================================================

set -e # Exit immediately if a command exits with a non-zero status

INSTALL_DIR="$HOME/.qalife"
SCRIPTS_DIR="$INSTALL_DIR/scripts"
CORE_DIR="$INSTALL_DIR/core"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELL_CONFIGS=("$HOME/.zshrc" "$HOME/.bashrc")

# 1. Bootstrap Logger
if [[ -f "$REPO_DIR/core/logger.sh" ]]; then
    source "$REPO_DIR/core/logger.sh"
else
    echo -e "\033[0;31m[ERROR]\033[0m Missing core/logger.sh. Installation aborted."
    exit 1
fi

log_info "Initializing Qalife installation process..."

# 2. Directory Creation & Permission Hardening
log_info "Setting up directories with restricted permissions..."
mkdir -p "$SCRIPTS_DIR"
mkdir -p "$CORE_DIR"
chmod 700 "$INSTALL_DIR"

# 3. Copy Assets
log_info "Copying executable scripts and core files..."
cp "$REPO_DIR/scripts/"*.sh "$SCRIPTS_DIR/" 2>/dev/null || true
cp "$REPO_DIR/core/"*.sh "$CORE_DIR/" 2>/dev/null || true

# Secure execution permissions
chmod 700 "$SCRIPTS_DIR/"*.sh
chmod 600 "$CORE_DIR/"*.sh # Core files only need read access, not execution

# 4. Shell Configuration Block
QALIFE_BLOCK="
# --- Qalife Tools ---
unalias qalife-clean qalife-update-code qalife-sysupdate qalife-full-maintenance qalife-audit 2>/dev/null || true

export QALIFE_HOME=\"$INSTALL_DIR\"

qalife-clean() { sudo \"\$QALIFE_HOME/scripts/qalife-clean.sh\"; }
qalife-update-code() { sudo \"\$QALIFE_HOME/scripts/qalife-codeupdate.sh\"; }
qalife-sysupdate() { sudo \"\$QALIFE_HOME/scripts/qalife-sysupdate.sh\"; }
qalife-audit() { sudo \"\$QALIFE_HOME/scripts/qalife-audit.sh\"; }

qalife-full-maintenance() {
    qalife-sysupdate
    qalife-update-code
    qalife-clean
}
# --- End Qalife Tools ---"


# 5. Injecting into User Profile
log_info "Configuring shell environments..."
for config_file in "${SHELL_CONFIGS[@]}"; do
    if [[ -f "$config_file" ]]; then
        if grep -q "# --- Qalife Tools ---" "$config_file"; then
            log_info "Updating existing Qalife configuration in $(basename "$config_file")..."
            
            # 5a. Create a safety backup
            cp "$config_file" "${config_file}.bak"
            
            # 5b. Safely purge the old block (handles both old and new end markers)
            sed -i '/# --- Qalife Tools ---/,/# --------------------/d' "$config_file"
            sed -i '/# --- Qalife Tools ---/,/# --- End Qalife Tools ---/d' "$config_file"
        fi
        
        # 5c. Append the fresh configuration
        echo "$QALIFE_BLOCK" >> "$config_file"
        log_success "Successfully injected configuration into $(basename "$config_file")."
    fi
done