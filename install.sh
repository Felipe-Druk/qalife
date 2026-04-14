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

# 4. Minimal Shell Loader
QALIFE_LOADER="
# --- Qalife Initialization ---
export QALIFE_HOME=\"\$HOME/.qalife\"
[[ -s \"\$QALIFE_HOME/core/init.sh\" ]] && source \"\$QALIFE_HOME/core/init.sh\"
# -----------------------------"

# 5. Injecting into User Profile
log_info "Configuring shell environments with dynamic loader..."
for config_file in "${SHELL_CONFIGS[@]}"; do
    if [[ -f "$config_file" ]]; then
        
        # 5a. Clean up the old, bloated Qalife block from previous versions
        if grep -q "# --- Qalife Tools ---" "$config_file"; then
            log_info "Migrating old Qalife configuration in $(basename "$config_file")..."
            cp "$config_file" "${config_file}.bak"
            sed -i '/# --- Qalife Tools ---/,/# --- End Qalife Tools ---/d' "$config_file"
        fi

        # 5b. Inject the new dynamic loader if it doesn't exist
        if ! grep -q "# --- Qalife Initialization ---" "$config_file"; then
            echo "$QALIFE_LOADER" >> "$config_file"
            log_success "Successfully linked dynamic loader in $(basename "$config_file")."
        else
            log_success "Dynamic loader already present in $(basename "$config_file")."
        fi
    fi
done