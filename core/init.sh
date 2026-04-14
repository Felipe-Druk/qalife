#!/bin/bash

# ==============================================================================
# QALIFE - DYNAMIC INITIALIZER (Safe & Robust)
# ==============================================================================
# Description: Dynamically loads all Qalife scripts and handles CLI flags.
# Version: 0.2.0-dev
# ==============================================================================

export QALIFE_HOME="$HOME/.qalife"

qalife() {
    local verbose=false
    local command=""
    local args=()

    # 1. Parse Flags
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -v|--verbose)
                verbose=true
                shift
                ;;
            -h|--help)
                command="help"
                shift
                ;;
            -*)
                echo -e "\033[0;31m[ERROR]\033[0m Unknown flag: $1"
                return 1
                ;;
            *)
                if [[ -z "$command" ]]; then
                    command="$1"
                else
                    args+=("$1")
                fi
                shift
                ;;
        esac
    done

    # 2. Default to help if no command is provided
    if [[ -z "$command" ]]; then
        command="help"
    fi

    # 3. Execution Logic
    case "$command" in
        "full-maintenance")
            qalife sysupdate
            qalife codeupdate
            qalife clean
            qalife devclean
            ;;
        *)
            local script_path="$QALIFE_HOME/scripts/qalife-$command.sh"
            if [[ -f "$script_path" ]]; then
                sudo QALIFE_VERBOSE="$verbose" "$script_path" "${args[@]}"
            else
                echo -e "\033[0;31m[ERROR]\033[0m Command '$command' not found."
                echo "Run 'qalife help' for a list of available commands."
                return 1
            fi
            ;;
    esac
}

# 4. Backward compatibility
qalife-clean() { qalife clean; }
qalife-sysupdate() { qalife sysupdate; }
qalife-audit() { qalife audit; }
qalife-devclean() { qalife devclean; }
qalife-help() { qalife help; }