#!/bin/bash

# ==============================================================================
# QALIFE - CLI MANUAL (Safe & Robust)
# ==============================================================================
# Description: Interactive help manual for the Qalife CLI.
# Version: 0.2.0
# ==============================================================================

readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

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
            ;;
        "audit")
            echo "Description: Scans for exposed ports, UFW status, and SSH root login misconfigurations."
            echo "Usage: qalife audit [-v, --verbose]"
            ;;
        "full-maintenance")
            echo "Description: Runs sysupdate, codeupdate, clean, and devclean in sequence."
            echo "Usage: qalife full-maintenance [-v, --verbose]"
            ;;
        *)
            echo -e "\033[0;31m[ERROR]\033[0m No specific documentation found for '$1'."
            echo "Run 'qalife help' to see all available commands."
            ;;
    esac
    exit 0
fi

# Global CLI Help
echo -e "${BLUE}"
cat << "EOF"
  ____    _    _      ___ _____ _____ 
 / __ \  / \  | |    |_ _|  ___| ____|
| |  | |/ _ \ | |     | || |_  |  _|  
| |__| / ___ \| |___  | ||  _| | |___ 
 \___\_\_/   \_\_____|___|_|   |_____|
EOF
echo -e "${NC}"

echo -e "${GREEN}Qalife Unified CLI v0.2.0${NC} - System Maintenance & Security Suite\n"

echo -e "${YELLOW}USAGE:${NC}"
echo -e "  qalife [flags] <command> [arguments]\n"

echo -e "${YELLOW}FLAGS:${NC}"
echo -e "  -v, --verbose    Enable detailed raw output."
echo -e "  -h, --help       Show this help message or command-specific help.\n"

echo -e "${YELLOW}COMMANDS:${NC}"
echo -e "  help             Displays this manual."
echo -e "  sysupdate        Updates system repositories and packages."
echo -e "  clean            Removes system junk and rotates logs."
echo -e "  codeupdate       Updates Visual Studio Code."
echo -e "  devclean         Purges development caches (Python, Docker, etc.)."
echo -e "  audit            Scans system security configuration."
echo -e "  full-maintenance Runs all maintenance tasks in sequence.\n"

echo "Tip: Try running 'qalife <command> -h' for more details on a specific tool."