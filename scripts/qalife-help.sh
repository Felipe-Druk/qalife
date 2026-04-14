#!/bin/bash

# ==============================================================================
# QALIFE - CLI MANUAL
# ==============================================================================

# ANSI Color Codes
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

echo -e "${BLUE}"
cat << "EOF"
  ____    _    _      ___ _____ _____ 
 / __ \  / \  | |    |_ _|  ___| ____|
| |  | |/ _ \ | |     | || |_  |  _|  
| |__| / ___ \| |___  | ||  _| | |___ 
 \___\_\_/   \_\_____|___|_|   |_____|
EOF
echo -e "${NC}"

echo -e "${GREEN}Qalife CLI v0.1.0${NC} - System Maintenance & Security Suite\n"

echo -e "${YELLOW}USAGE:${NC}"
echo -e "  qalife-<command> [options]\n"

echo -e "${YELLOW}CORE COMMANDS:${NC}"
echo -e "  ${GREEN}qalife-help${NC}             Displays this manual."
echo -e "  ${GREEN}qalife-full-maintenance${NC} Runs system update, code update, clean, and dev clean in sequence.\n"

echo -e "${YELLOW}MAINTENANCE:${NC}"
echo -e "  ${GREEN}qalife-sysupdate${NC}        Safely updates apt package lists and runs dist-upgrade."
echo -e "  ${GREEN}qalife-clean${NC}            Removes orphaned packages, clears apt cache, and rotates logs."
echo -e "  ${GREEN}qalife-codeupdate${NC}       Updates Visual Studio Code and its Microsoft GPG repositories."
echo -e "  ${GREEN}qalife-devclean${NC}         Purges Python, Node.js, Go, and Docker caches to free up space.\n"

echo -e "${YELLOW}SECURITY:${NC}"
echo -e "  ${GREEN}qalife-audit${NC}            Scans for exposed ports, UFW status, and SSH root login misconfigurations.\n"

echo "For more details, visit the repository or read the README.md."