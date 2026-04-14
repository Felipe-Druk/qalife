#!/bin/bash

# ==============================================================================
# QALIFE - DYNAMIC INITIALIZER
# ==============================================================================
# Description: Dynamically loads all Qalife scripts as shell functions.
# ==============================================================================

export QALIFE_HOME="$HOME/.qalife"

# 1. Dynamically generate functions for every script in the directory
for script in "$QALIFE_HOME/scripts/"*.sh; do
    if [[ -f "$script" ]]; then
        # Extract filename without the .sh extension (e.g., qalife-clean)
        cmd_name=$(basename "$script" .sh)
        
        # Remove any existing alias to prevent conflicts
        unalias "$cmd_name" 2>/dev/null || true
        
        # Dynamically create the shell function
        eval "$cmd_name() { sudo \"$script\" \"\$@\"; }"
    fi
done

# 2. Define compound/master commands separately
qalife-full-maintenance() {
    qalife-sysupdate
    qalife-update-code
    qalife-clean
    qalife-devclean
}