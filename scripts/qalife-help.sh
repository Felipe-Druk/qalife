#!/bin/bash

# ==============================================================================
# QALIFE - CLI MANUAL (v0.2.0-dev)
# ==============================================================================

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

echo -e "${GREEN}Qalife Unified CLI${NC}\n"

echo -e "${YELLOW}USAGE:${NC}"
echo -e "  qalife [flags] <command> [arguments]\n"

echo -e "${YELLOW}FLAGS:${NC}"
echo -e "  -v, --verbose    Enable detailed output (debug mode)."
echo -e "  -h, --help       Show this help message.\n"

echo -e "${YELLOW}COMMANDS:${NC}"
echo -e "  help             Displays this manual."
echo -e "  sysupdate        Updates system repositories and packages."
echo -e "  clean            Removes system junk and rotates logs."
echo -e "  codeupdate       Updates Visual Studio Code."
echo -e "  devclean         Purges development caches (Python, Docker, etc.)."
echo -e "  audit            Scans system security configuration."
echo -e "  full-maintenance Runs all maintenance tasks in sequence.\n"

echo "Note: All maintenance and security commands require sudo privileges."