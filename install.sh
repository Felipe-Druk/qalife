#!/bin/bash

# ==============================================================================
# QALIFE - INSTALLATION SCRIPT (Safe & Robust)
# ==============================================================================
# Description: Deploys Qalife to user home directory and configures shell rc.
# Version: 0.3.1
# ==============================================================================

# shellcheck disable=SC1091
if [[ -f "./core/logger.sh" ]]; then
    source "./core/logger.sh"
else
    echo -e "\033[0;31m[ERROR]\033[0m Cannot find ./core/logger.sh. Execution aborted."
    exit 1
fi

if [[ -z "$QALIFE_IS_UPDATING" ]]; then
    print_qalife_logo
    echo -e "${GREEN}Qalife Installer v${QALIFE_VERSION}${NC}\n"
fi

log_info "Starting Qalife installation..."

INSTALL_DIR="$HOME/.qalife"
trap '[[ -n "$SPINNER_PID" ]] && stop_spinner "Process interrupted."; exit 1' INT

# 2. Verify and Install Dependencies (jq)
start_spinner "Verifying system dependencies (jq)..."
if ! command -v jq >/dev/null 2>&1; then
    stop_spinner "Missing jq. Installing..."
    sudo apt-get update -qq >/dev/null 2>&1
    sudo apt-get install -qq -y jq >/dev/null 2>&1
    log_success "Dependency 'jq' installed successfully."
else
    stop_spinner "Dependencies verified."
fi

# 3. Backup & Clean old install
if [[ -d "$INSTALL_DIR" ]]; then
    start_spinner "Purging previous installation..."
    if [[ -f "$INSTALL_DIR/core/config.json" ]]; then
        cp "$INSTALL_DIR/core/config.json" "/tmp/qalife_config_backup.json" 2>/dev/null || true
    fi
    rm -rf "$INSTALL_DIR"
    stop_spinner "Previous installation purged."
fi

# 4. Copy files and set secure permissions
start_spinner "Deploying core and scripts to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
cp -r core scripts "$INSTALL_DIR/"
cp update.sh uninstall.sh "$INSTALL_DIR/" 2>/dev/null || true

# Restore previous config or create a new default one (WITHOUT codeupdate)
if [[ -f "/tmp/qalife_config_backup.json" ]]; then
    mv "/tmp/qalife_config_backup.json" "$INSTALL_DIR/core/config.json"
else
    cat << 'EOF' > "$INSTALL_DIR/core/config.json"
{
  "full-maintenance": [
    "sysupdate",
    "clean",
    "devclean"
  ]
}
EOF
fi

chmod 700 "$INSTALL_DIR"
chmod 600 "$INSTALL_DIR"/core/*
chmod 700 "$INSTALL_DIR"/scripts/*
chmod 700 "$INSTALL_DIR"/update.sh "$INSTALL_DIR"/uninstall.sh 2>/dev/null || true

echo "export QALIFE_REPO_PATH=\"$PWD\"" > "$INSTALL_DIR/core/env.sh"
stop_spinner "Files successfully copied and secured."

# 5. Configure terminal RC files
start_spinner "Configuring terminal RC files..."
BLOCK_START="# === QALIFE CLI START ==="
BLOCK_END="# === QALIFE CLI END ==="
INIT_BLOCK="\n$BLOCK_START\nexport QALIFE_HOME=\"\$HOME/.qalife\"\nif [[ -f \"\$QALIFE_HOME/core/init.sh\" ]]; then\n    source \"\$QALIFE_HOME/core/init.sh\"\nfi\n$BLOCK_END\n"

for rc_file in ~/.zshrc ~/.bashrc; do
    if [[ -f "$rc_file" ]]; then
        # Clean legacy blocks to prevent orphan code properly
        sed -i '/# --- Qalife Initialization ---/,/# -----------------------------/d' "$rc_file" 2>/dev/null || true
        sed -i '/# QALIFE CLI INITIALIZER/,/fi/d' "$rc_file" 2>/dev/null || true
        
        # Remove current block format safely
        sed -i "/$BLOCK_START/,/$BLOCK_END/d" "$rc_file" 2>/dev/null || true
        
        # B) Clean the robust new block (Idempotent execution)
        sed -i "/$BLOCK_START/,/$BLOCK_END/d" "$rc_file" 2>/dev/null || true
        
        # C) Append fresh new dynamic entry
        echo -e "$INIT_BLOCK" >> "$rc_file"
    fi
done
stop_spinner "Shell environments configured."

log_success "Qalife successfully installed!"
log_info "Please run 'source ~/.zshrc' or 'source ~/.bashrc' to reload your terminal."