#!/bin/bash

# ==============================================================================
# QALIFE - DYNAMIC INITIALIZER
# ==============================================================================
# Description: Dynamically loads all Qalife scripts as shell functions.
# ==============================================================================

export QALIFE_HOME="$HOME/.qalife"

export QALIFE_HOME="$HOME/.qalife"

qalife() {
    local verbose=false
    local command=""
    local args=()

    
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

    
    if [[ -z "$command" ]]; then
        command="help"
    fi

   
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
                export QALIFE_VERBOSE=$verbose
                sudo "$script_path" "${args[@]}"
            else
                echo -e "\033[0;31m[ERROR]\033[0m Command '$command' not found."
                echo "Run 'qalife help' for a list of available commands."
                return 1
            fi
            ;;
    esac
}

qalife-clean() { qalife clean; }
qalife-sysupdate() { qalife sysupdate; }
qalife-audit() { qalife audit; }
qalife-devclean() { qalife devclean; }
qalife-help() { qalife help; }