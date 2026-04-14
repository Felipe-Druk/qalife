#!/bin/bash

# ==============================================================================
# QALIFE - UPDATER SCRIPT (Safe & Robust)
# ==============================================================================
# Description: Pulls latest changes and safely reinstalls the CLI.
# Version: 0.2.1
# ==============================================================================

# shellcheck disable=SC1091
source "$HOME/.qalife/core/logger.sh"
# shellcheck disable=SC1091
source "$HOME/.qalife/core/env.sh" 2>/dev/null || true

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

if [[ -z "$QALIFE_REPO_PATH" || ! -d "$QALIFE_REPO_PATH/.git" ]]; then
    fatal_error "Original repository path not found or invalid. Please run the updater from the cloned directory manually."
fi

log_info "Navigating to source repository: $QALIFE_REPO_PATH"
cd "$QALIFE_REPO_PATH" || fatal_error "Could not access repository path."

log_info "Pulling latest changes..."
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