#!/bin/bash

# ==============================================================================
# QALIFE - UPDATER SCRIPT (Safe & Robust)
# ==============================================================================
# Description: Pulls latest changes and safely reinstalls the CLI.
# Version: 0.2.1-dev
# ==============================================================================

readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

echo -e "${BLUE}"
cat << "EOF"
  ____    _    _      ___ _____ _____ 
 / __ \  / \  | |    |_ _|  ___| ____|
| |  | |/ _ \ | |     | || |_  |  _|  
| |__| / ___ \| |___  | ||  _| | |___ 
 \___\_\_/   \_\_____|___|_|   |_____|
EOF
echo -e "${NC}"
echo -e "${GREEN}Qalife Updater v0.2.1${NC}\n"

echo "[INFO] Pulling latest changes from repository..."
if git pull origin main; then
    echo "[OK] Repository updated."
    echo "[INFO] Running installer to apply new architecture..."
    chmod +x install.sh
    ./install.sh
    echo -e "\n${GREEN}[OK] Update complete! Please run 'source ~/.zshrc' or 'source ~/.bashrc' to reload your terminal.${NC}"
else
    echo -e "\033[0;31m[ERROR]\033[0m Failed to pull from repository. Please check your git status."
    exit 1
fi