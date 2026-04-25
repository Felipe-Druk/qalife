#!/bin/bash

# ==============================================================================
# QALIFE - CONFIGURATION MANAGER (Safe & Robust)
# ==============================================================================
# Description: Manages Qalife settings and command groups via config.json.
# Version: 0.3.0
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
    echo -e "Usage: qalife config <group/key> <action> [value]"
    echo -e "Array Actions: list, add, remove"
    echo -e "Value Actions: get, set"
    exit 1
fi

# 2. Ensure the key/group exists
if [[ $(jq "has(\"$TARGET_GROUP\")" "$CONFIG_FILE") == "false" ]]; then
    if [[ "$ACTION" == "list" || "$ACTION" == "get" ]]; then
        log_warn "Key or Group '$TARGET_GROUP' does not exist."
        exit 0
    elif [[ "$ACTION" == "add" ]]; then
        jq ".\"$TARGET_GROUP\" = []" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    elif [[ "$ACTION" == "set" ]]; then
        # Dejamos que pase directo para que 'set' cree la clave de tipo string
        true
    else
        fatal_error "Key or Group '$TARGET_GROUP' does not exist."
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
            fatal_error "You must specify an item to add."
        fi
        jq ".\"$TARGET_GROUP\" += [\"$ITEM\"] | .\"$TARGET_GROUP\" |= unique" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
        log_success "Added '$ITEM' to $TARGET_GROUP."
        ;;
        
    "remove")
        if [[ -z "$ITEM" ]]; then
            fatal_error "You must specify an item to remove."
        fi
        jq ".\"$TARGET_GROUP\" -= [\"$ITEM\"]" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
        log_success "Removed '$ITEM' from $TARGET_GROUP."
        ;;
        
    "set")
        if [[ -z "$ITEM" ]]; then
            fatal_error "You must specify a value to set. (e.g., qalife config docker-prune-days set 1)"
        fi
        # Asignamos el valor como un string
        jq ".\"$TARGET_GROUP\" = \"$ITEM\"" "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
        log_success "Set '$TARGET_GROUP' to '$ITEM'."
        ;;
        
    "get")
        jq -r ".\"$TARGET_GROUP\"" "$CONFIG_FILE"
        ;;
        
    *)
        log_error "Unknown action: $ACTION"
        echo -e "Valid actions are: list, add, remove, get, set"
        exit 1
        ;;
esac