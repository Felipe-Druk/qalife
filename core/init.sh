#!/bin/bash

# ==============================================================================
# QALIFE - DYNAMIC INITIALIZER (Safe & Robust)
# ==============================================================================
# Description: Dynamically loads all Qalife scripts, handles flags, and autocomplete.
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
        "help")
            local script_path="$QALIFE_HOME/scripts/qalife-help.sh"
            if [[ -f "$script_path" ]]; then
                sudo QALIFE_VERBOSE="$verbose" "$script_path" "${args[@]}"
            else
                echo -e "\033[0;31m[ERROR]\033[0m Help module not found."
            fi
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

# ==============================================================================
# AUTOCOMPLETION ENGINE
# ==============================================================================
_qalife_completions() {
    local cur commands
    
    # 1. Cross-shell compatibility for current word extraction
    if [[ -n "$ZSH_VERSION" ]]; then
        cur=${words[CURRENT]}
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
    fi

    # 2. Hardcoded compound/master commands
    commands="help full-maintenance"

    # 3. Dynamic payload extraction (Scanning the scripts directory)
    if [[ -d "$QALIFE_HOME/scripts" ]]; then
        for script in "$QALIFE_HOME/scripts/qalife-"*.sh; do
            if [[ -f "$script" ]]; then
                # Extraer nombre base: "qalife-clean.sh" -> "qalife-clean"
                local cmd_name=$(basename "$script" .sh)
                # Remover prefijo: "qalife-clean" -> "clean"
                cmd_name=${cmd_name#qalife-}
                commands+=" $cmd_name"
            fi
        done
    fi

    # 4. Generate matching replies
    COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
    return 0
}

# 5. Register the autocomplete engine (Zsh & Bash support)
if [[ -n "$ZSH_VERSION" ]]; then
    autoload -Uz compinit && compinit 2>/dev/null
    autoload -Uz bashcompinit && bashcompinit 2>/dev/null
fi

complete -F _qalife_completions qalife