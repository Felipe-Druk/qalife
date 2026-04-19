#!/bin/bash

# ==============================================================================
# QALIFE - INSTALLATION SCRIPT (Safe & Robust)
# ==============================================================================
# Description: Deploys Qalife to user home directory and configures shell rc.
# Version: 0.2.2-dev
# ==============================================================================

# shellcheck disable=SC1091
if [[ -f "./core/logger.sh" ]]; then
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
    echo -e "${GREEN}Qalife Installer v0.2.2-dev${NC}\n"
fi

log_info "Starting Qalife installation..."

INSTALL_DIR="$HOME/.qalife"
trap '[[ -n "$SPINNER_PID" ]] && stop_spinner "Process interrupted."; exit 1' INT

# 2. Backup & Clean old install
if [[ -d "$INSTALL_DIR" ]]; then
    start_spinner "Purging previous installation..."
    rm -rf "$INSTALL_DIR"
    stop_spinner "Previous installation purged."
fi

# 3. Copy files and set secure permissions
start_spinner "Deploying core and scripts to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
cp -r core scripts "$INSTALL_DIR/"
cp update.sh uninstall.sh "$INSTALL_DIR/" 2>/dev/null || true
chmod 700 "$INSTALL_DIR"
chmod 600 "$INSTALL_DIR"/core/*
chmod 700 "$INSTALL_DIR"/scripts/*
chmod 700 "$INSTALL_DIR"/update.sh "$INSTALL_DIR"/uninstall.sh 2>/dev/null || true

echo "export QALIFE_REPO_PATH=\"$PWD\"" > "$INSTALL_DIR/core/env.sh"
stop_spinner "Files successfully copied and secured."

# 4. Configure terminal RC files (BLOCK BASED)
start_spinner "Configuring terminal RC files..."

BLOCK_START="# === QALIFE CLI START ==="
BLOCK_END="# === QALIFE CLI END ==="
INIT_BLOCK="\n$BLOCK_START\nexport QALIFE_HOME=\"\$HOME/.qalife\"\nif [[ -f \"\$QALIFE_HOME/core/init.sh\" ]]; then\n    source \"\$QALIFE_HOME/core/init.sh\"\nfi\n$BLOCK_END\n"

for rc_file in ~/.zshrc ~/.bashrc; do
    if [[ -f "$rc_file" ]]; then
        # A) Clean legacy blocks safely (v0.1.x and v0.2.x fixes)
        sed -i '/# --- Qalife Initialization ---/,/# -----------------------------/d' "$rc_file" 2>/dev/null || true
        sed -i '/# QALIFE CLI INITIALIZER/,/fi/d' "$rc_file" 2>/dev/null || true
        
        # B) Clean the robust new block (Idempotent execution)
        sed -i "/$BLOCK_START/,/$BLOCK_END/d" "$rc_file" 2>/dev/null || true
        
        # C) Append fresh new dynamic entry
        echo -e "$INIT_BLOCK" >> "$rc_file"
    fi
done
stop_spinner "Shell environments configured."

log_success "Qalife successfully installed!"
log_info "Please run 'source ~/.zshrc' or 'source ~/.bashrc' to reload your terminal."