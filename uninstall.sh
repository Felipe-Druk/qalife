#!/bin/bash

# ==============================================================================
# QALIFE - UNINSTALLER SCRIPT (Safe & Robust)
# ==============================================================================
# Description: Completely removes Qalife and cleans terminal rc files.
# Version: 0.2.1-dev
# ==============================================================================

readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

echo -e "${YELLOW}WARNING: This will completely remove Qalife from your system.${NC}"
read -p "Are you sure you want to continue? (y/n): " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Uninstallation canceled."
    exit 0
fi

echo "[INFO] Removing core directories..."
rm -rf ~/.qalife 2>/dev/null

echo "[INFO] Cleaning terminal configuration files..."
# Remove the dynamic sourcing block from rc files safely
if [[ -f ~/.zshrc ]]; then
    sed -i '/# QALIFE CLI INITIALIZER/d' ~/.zshrc
    sed -i '/qalife\/core\/init\.sh/d' ~/.zshrc
fi

if [[ -f ~/.bashrc ]]; then
    sed -i '/# QALIFE CLI INITIALIZER/d' ~/.bashrc
    sed -i '/qalife\/core\/init\.sh/d' ~/.bashrc
fi

echo -e "\033[0;32m[OK]\033[0m Qalife has been successfully uninstalled. We are sad to see you go!"
echo "Please restart your terminal to finalize the cleanup."