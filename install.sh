#!/bin/bash

# ==============================================================================
# QALIFE - INSTALLATION SCRIPT (Safe & Robust)
# ==============================================================================
# Description: Deploys Qalife to user home directory and configures shell rc.
# Version: 0.3.0
# ==============================================================================

# 1. Source local logger
if [[ -f "./core/logger.sh" ]]; then
    # shellcheck disable=SC1091
    source "./core/logger.sh"
else
    echo -e "\033[0;31m[ERROR]\033[0m Cannot find ./core/logger.sh. Execution aborted."
    exit 1
fi

if [[ -z "$QALIFE_IS_UPDATING" ]]; then
    echo -e "${BLUE}"
    cat << "EOF"
  ____    _    _      ___ _____ _____ 
 / __ \  / \  | |    |_ _|  ___| ____|
| |  | |/ _ \ | |     | || |_  |  _|  
| |__| / ___ \| |___  | ||  _| | |___ 
 \___\_\_/   \_\_____|___|_|   |_____|
EOF
    echo -e "${NC}"
    echo -e "${GREEN}Qalife Installer v0.3.0-dev${NC}\n"
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
    # Salvamos el config.json si existe antes de destruir
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
cp update.sh uninstall.sh "$INSTALL_DIR/" 2>/dev/null || true # Copiamos los scripts de ciclo de vida

# Restauramos el config anterior o creamos uno nuevo por defecto
if [[ -f "/tmp/qalife_config_backup.json" ]]; then
    mv "/tmp/qalife_config_backup.json" "$INSTALL_DIR/core/config.json"
else
    cat << 'EOF' > "$INSTALL_DIR/core/config.json"
{
  "full-maintenance": [
    "sysupdate",
    "codeupdate",
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

# Create env.sh with dynamic path
echo "export QALIFE_REPO_PATH=\"$PWD\"" > "$INSTALL_DIR/core/env.sh"
stop_spinner "Files successfully copied and secured."

# 5. Configure terminal RC files
start_spinner "Configuring terminal RC files..."
INIT_BLOCK="\n# QALIFE CLI INITIALIZER\nif [[ -f \"$INSTALL_DIR/core/init.sh\" ]]; then\n    source \"$INSTALL_DIR/core/init.sh\"\nfi\n"

for rc_file in ~/.zshrc ~/.bashrc; do
    if [[ -f "$rc_file" ]]; then
        # Clean old entries safely
        sed -i '/# QALIFE CLI INITIALIZER/d' "$rc_file" 2>/dev/null || true
        sed -i '/qalife\/core\/init\.sh/d' "$rc_file" 2>/dev/null || true
        
        # Append new dynamic entry
        echo -e "$INIT_BLOCK" >> "$rc_file"
    fi
done
stop_spinner "Shell environments configured."

log_success "Qalife successfully installed!"
log_info "Please run 'source ~/.zshrc' or 'source ~/.bashrc' to reload your terminal."