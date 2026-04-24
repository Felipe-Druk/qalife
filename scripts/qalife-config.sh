#!/bin/bash

# ==============================================================================
# QALIFE - CONFIGURATION MANAGER (Safe & Robust)
# ==============================================================================
# Description: Manages Qalife settings and command groups via config.json.
# Version: 0.3.0-dev
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="$(cd "$SCRIPT_DIR/../core" && pwd)"
CONFIG_FILE="$CORE_DIR/config.json"

if [[ -f "$CORE_DIR/logger.sh" ]]; then
    # shellcheck disable=SC1091
    source "$CORE_DIR/logger.sh"
else
    echo -e "\033[0;31m[ERROR]\033[0m Missing core/logger.sh. Execution aborted."
    exit 1
fi

# 1. Dependency and integrity checks
if ! command -v jq >/dev/null 2>&1; then
    fatal_error "The 'jq' dependency is missing. Please run 'qalife up' to reinstall."
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
    fatal_error "Configuration file not found at $CONFIG_FILE."
fi

TARGET_GROUP="$1"
ACTION="$2"
ITEM="$3"

if [[ -z "$TARGET_GROUP" || -z "$ACTION" ]]; then
    log_error "Invalid syntax."
    echo -e "Usage: qalife config <group> <action> [item]"
    echo -e "Actions: list, add, remove"
    exit 1
fi

# 2. Ensure the group exists (create an empty array if adding to a new group)
if [[ $(jq "has(\"$TARGET_GROUP\")" "$CONFIG_FILE") == "false" ]]; then
    if [[ "$ACTION" == "list" ]]; then
        log_warn "Group '$TARGET_GROUP' does not exist or is empty."
        exit 0
    elif [[ "$ACTION" == "add" ]]; then
        jq ".\"$TARGET_GROUP\" = []" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    else
        fatal_error "Group '$TARGET_GROUP' does not exist."
    fi
fi

# 3. Action Routing
case "$ACTION" in
    "list")
        log_info "Commands currently in [${YELLOW}${TARGET_GROUP}${NC}]:"
        jq -r ".\"$TARGET_GROUP\"[]" "$CONFIG_FILE" | sed 's/^/  -> /'
        ;;
        
    "add")
        if [[ -z "$ITEM" ]]; then
            fatal_error "You must specify an item to add. (e.g., qalife config $TARGET_GROUP add audit)"
        fi
        
        # Add item and filter through 'unique' to prevent duplicates
        jq ".\"$TARGET_GROUP\" += [\"$ITEM\"] | .\"$TARGET_GROUP\" |= unique" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
        log_success "Added '$ITEM' to $TARGET_GROUP."
        ;;
        
    "remove")
        if [[ -z "$ITEM" ]]; then
            fatal_error "You must specify an item to remove. (e.g., qalife config $TARGET_GROUP remove clean)"
        fi
        
        # Subtract item array from the target array
        jq ".\"$TARGET_GROUP\" -= [\"$ITEM\"]" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
        log_success "Removed '$ITEM' from $TARGET_GROUP."
        ;;
        
    *)
        log_error "Unknown action: $ACTION"
        echo -e "Valid actions are: list, add, remove"
        exit 1
        ;;
esac