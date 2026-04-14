#!/bin/bash

# ==============================================================================
# QALIFE - DYNAMIC INITIALIZER (Safe & Robust)
# ==============================================================================
# Description: Dynamically loads all Qalife scripts, handles flags, and autocomplete.
# Version: 0.2.0
# ==============================================================================

export QALIFE_HOME="$HOME/.qalife"

qalife() {
    local verbose=false
    local target_cmd=""
    # Explicit array declaration for cross-shell (Bash/Zsh) safety
    local -a args=()
    local is_help=false

    # 1. Parse Arguments & Flags
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -v|--verbose)
                verbose=true
                shift
                ;;
            -h|--help)
                is_help=true
                shift
                ;;
            -*)
                echo -e "\033[0;31m[ERROR]\033[0m Unknown flag: $1"
                return 1
                ;;
            *)
                if [[ -z "$target_cmd" ]]; then
                    target_cmd="$1"
                else
                    args+=("$1")
                fi
                shift
                ;;
        esac
    done

    # 2. Resolve Contextual Help
    if [[ "$is_help" == "true" ]]; then
        # If the user asked for help on a specific command (e.g., qalife devclean -h)
        if [[ -n "$target_cmd" && "$target_cmd" != "help" ]]; then
            args=("$target_cmd")
        fi
        target_cmd="help"
    fi

    # 3. Default Execution (No args)
    if [[ -z "$target_cmd" ]]; then
        target_cmd="help"
    fi

case "$target_cmd" in
        "full-maintenance")
            qalife sysupdate
            qalife codeupdate
            qalife clean
            qalife devclean
            ;;
        "help")
            local script_path="$QALIFE_HOME/scripts/qalife-help.sh"
            if [[ -f "$script_path" ]]; then
                QALIFE_VERBOSE="$verbose" "$script_path" "${args[@]}"
            else
                echo -e "\033[0;31m[ERROR]\033[0m Help module not found."
            fi
            ;;
        "up"|"update")
            if [[ -f "$QALIFE_HOME/update.sh" ]]; then
                "$QALIFE_HOME/update.sh"
            else
                echo -e "\033[0;31m[ERROR]\033[0m Updater not found. Try reinstalling manually."
            fi
            ;;
        "uninstall")
            if [[ -f "$QALIFE_HOME/uninstall.sh" ]]; then
                "$QALIFE_HOME/uninstall.sh"
            else
                echo -e "\033[0;31m[ERROR]\033[0m Uninstaller not found. Try deleting ~/.qalife manually."
            fi
            ;;
        *)
            local script_path="$QALIFE_HOME/scripts/qalife-$target_cmd.sh"
            if [[ -f "$script_path" ]]; then
                sudo QALIFE_VERBOSE="$verbose" "$script_path" "${args[@]}"
            else
                echo -e "\033[0;31m[ERROR]\033[0m Command '$target_cmd' not found."
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
    if [[ -n "$ZSH_VERSION" ]]; then
        # shellcheck disable=SC2154
        cur=${words[CURRENT]}
    else
        cur="${COMP_WORDS[COMP_CWORD]}"
    fi

    commands="help full-maintenance up update uninstall"
    if [[ -d "$QALIFE_HOME/scripts" ]]; then
        for script in "$QALIFE_HOME/scripts/qalife-"*.sh; do
            if [[ -f "$script" ]]; then
                local cmd_name
                cmd_name=$(basename "$script" .sh)
                cmd_name=${cmd_name#qalife-}
                commands+=" $cmd_name"
            fi
        done
    fi

    # shellcheck disable=SC2207
    COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
    return 0
}

if [[ -n "$ZSH_VERSION" ]]; then
    autoload -Uz compinit && compinit 2>/dev/null
    autoload -Uz bashcompinit && bashcompinit 2>/dev/null
fi

complete -F _qalife_completions qalife