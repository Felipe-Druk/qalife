#!/bin/bash

# ==============================================================================
# QALIFE - UPDATER SCRIPT (Safe & Robust)
# ==============================================================================
# Description: Pulls latest changes and safely reinstalls the CLI.
# Version: 0.2.1-dev
# ==============================================================================

# 1. Source local logger
if [[ -f "./core/logger.sh" ]]; then
    # shellcheck disable=SC1091
    source "./core/logger.sh"
else
    echo -e "\033[0;31m[ERROR]\033[0m Cannot find ./core/logger.sh. Execution aborted."
    exit 1
fi

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

log_info "Pulling latest changes from repository..."

# Pulling current tracked branch safely
if git pull > /dev/null 2>&1; then
    log_success "Repository updated."
    
    log_info "Running installer to apply new architecture..."
    echo ""
    chmod +x install.sh
    export QALIFE_IS_UPDATING=true
    if ./install.sh; then
        echo ""
        log_success "Update complete! Please reload your terminal."
    else
        fatal_error "Installer failed during the update process."
    fi
else
    fatal_error "Failed to pull from repository. Please check your git status or network connection."
fi