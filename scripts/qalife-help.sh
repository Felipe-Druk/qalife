#!/bin/bash

# ==============================================================================
# QALIFE - CLI MANUAL (Safe & Robust)
# ==============================================================================
# Description: Interactive help manual for the Qalife CLI.
# Version: 0.3.1
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="$(cd "$SCRIPT_DIR/../core" && pwd)"

if [[ -f "$CORE_DIR/logger.sh" ]]; then
    # shellcheck disable=SC1091
    source "$CORE_DIR/logger.sh"
else
    # Fallback just in case
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly NC='\033[0m'
    readonly QALIFE_VERSION="0.3.1"
    print_qalife_logo() { echo "QALIFE CLI"; }
fi


# Contextual Command Help
if [[ -n "$1" ]]; then
    echo -e "${GREEN}Qalife Command Documentation: ${YELLOW}$1${NC}\n"
    case "$1" in
        "clean")
            echo "Description: Removes orphaned packages, clears apt cache, and rotates system logs."
            echo "Usage: qalife clean [-v, --verbose]"
            ;;
        "sysupdate")
            echo "Description: Safely updates apt package lists, enables multiverse, and runs dist-upgrade."
            echo "Usage: qalife sysupdate [-v, --verbose]"
            ;;
        "codeupdate")
            echo "Description: Updates Visual Studio Code and its Microsoft GPG repositories."
            echo "Usage: qalife codeupdate [-v, --verbose]"
            ;;
        "devclean")
            echo "Description: Purges dev caches (Python, Node.js, Go, Rust, C++, Docker) to free space."
            echo "Usage: qalife devclean [-v, --verbose]"
            echo "Note: Docker cleanup retention is configurable. Run 'qalife config docker-prune-days set <days>'."
            ;;
        "audit")
            echo "Description: Scans for exposed ports, UFW status, and SSH root login misconfigurations."
            echo "Usage: qalife audit [-v, --verbose]"
            ;;
        "config")
            echo "Description: Manages Qalife settings, dynamic command groups, and variables."
            echo "Usage: qalife config <group/key> <action> [item/value]"
            echo "Array Actions: list, add, remove"
            echo "Value Actions: get, set"
            echo "Example 1: qalife config quick-scan add audit"
            echo "Example 2: qalife config docker-prune-days set 1"
            ;;
        "up"|"update")
            echo "Description: Pulls the latest changes from the repository and safely reinstalls the CLI."
            echo "Usage: qalife up"
            ;;
        "uninstall")
            echo "Description: Completely removes Qalife from the system and cleans terminal rc files."
            echo "Usage: qalife uninstall"
            ;;
        "full-maintenance")
            echo "Description: Dynamic routine. Runs system and dev maintenance tasks in sequence."
            echo "Usage: qalife full-maintenance [-v, --verbose]"
            echo "Note: You can modify this routine using 'qalife config full-maintenance'."
            ;;
        *)
            echo -e "\033[0;31m[ERROR]\033[0m No specific documentation found for '$1'."
            echo "Run 'qalife help' to see all available commands."
            ;;
    esac
    exit 0
fi

# Global CLI Help
print_qalife_logo
echo -e "${GREEN}Qalife Unified CLI v${QALIFE_VERSION}${NC} - System Maintenance & Security Suite\n"

echo -e "${YELLOW}USAGE:${NC}"
echo -e "  qalife [flags] <command> [arguments]\n"

echo -e "${YELLOW}FLAGS:${NC}"
echo -e "  -v, --verbose    Enable detailed raw output."
echo -e "  -h, --help       Show this help message or command-specific help.\n"

echo -e "${YELLOW}CORE COMMANDS:${NC}"
echo -e "  sysupdate        Updates system repositories and packages."
echo -e "  clean            Removes system junk and rotates logs."
echo -e "  codeupdate       Updates Visual Studio Code."
echo -e "  devclean         Purges development caches (Python, Docker, etc.)."
echo -e "  audit            Scans system security configuration."
echo -e "  config           Manages dynamic command groups and settings.\n"

echo -e "${YELLOW}ROUTINES & LIFECYCLE:${NC}"
echo -e "  full-maintenance Dynamic routine managed via config."
echo -e "  up / update      Updates Qalife CLI to the latest version."
echo -e "  uninstall        Removes Qalife from your system.\n"

echo "Tip: Try running 'qalife <command> -h' for more details on a specific tool."