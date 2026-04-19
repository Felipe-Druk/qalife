#!/bin/bash

# ==============================================================================
# QALIFE - UNINSTALLER SCRIPT (Safe & Robust)
# ==============================================================================
# Description: Completely removes Qalife and cleans terminal rc files.
# Version: 0.2.2-dev
# ==============================================================================

readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

echo -e "${YELLOW}WARNING: This will completely remove Qalife from your system.${NC}"
read -r -p "Are you sure you want to continue? (y/n): " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Uninstallation canceled."
    exit 0
fi

echo "[INFO] Removing core directories..."
rm -rf ~/.qalife 2>/dev/null

echo "[INFO] Cleaning terminal configuration files..."
BLOCK_START="# === QALIFE CLI START ==="
BLOCK_END="# === QALIFE CLI END ==="

for rc_file in ~/.zshrc ~/.bashrc; do
    if [[ -f "$rc_file" ]]; then
        # Remove the new robust block
        sed -i "/$BLOCK_START/,/$BLOCK_END/d" "$rc_file" 2>/dev/null || true
        
        # Remove legacy blocks just in case they survived
        sed -i '/# --- Qalife Initialization ---/,/# -----------------------------/d' "$rc_file" 2>/dev/null || true
        sed -i '/# QALIFE CLI INITIALIZER/,/fi/d' "$rc_file" 2>/dev/null || true
    fi
done

echo -e "\033[0;32m[OK]\033[0m Qalife has been successfully uninstalled. We are sad to see you go!"
echo "Please restart your terminal to finalize the cleanup."