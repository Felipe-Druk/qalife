#!/bin/bash

# ==============================================================================
# QALIFE - DEV ENVIRONMENT CLEANUP SCRIPT
# ==============================================================================
# Description: Safely purges development caches and calculates space freed.
# Version: 0.1.1-dev
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="$(cd "$SCRIPT_DIR/../core" && pwd)"

if [[ -f "$CORE_DIR/logger.sh" ]]; then
    source "$CORE_DIR/logger.sh"
else
    echo -e "\033[0;31m[ERROR]\033[0m Missing core/logger.sh. Execution aborted."
    exit 1
fi

if [[ $EUID -ne 0 ]]; then
   fatal_error "This script must be run as root (use sudo)."
fi

# Ensure spinner stops if the user hits Ctrl+C
trap 'stop_spinner "Process interrupted."; exit 1' INT

log_info "=== Starting Developer Environment Cleanup ==="

# 1. Capture initial disk space in KB (Root partition)
USED_BEFORE=$(df -k / | awk 'NR==2 {print $3}')

# 2. Python Cleanup
start_spinner "Cleaning Python compiled artifacts and pip cache..."
rm -rf /root/.cache/pip 2>/dev/null || true
rm -rf /home/*/.cache/pip 2>/dev/null || true
find /home/* /root -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find /home/* /root -type f -name "*.pyc" -delete 2>/dev/null || true
stop_spinner "Python caches purged."

# 3. Node.js & TypeScript Cleanup
start_spinner "Clearing Node.js (NPM/Yarn) package caches..."
rm -rf /home/*/.npm/_cacache 2>/dev/null || true
rm -rf /home/*/.yarn/cache 2>/dev/null || true
stop_spinner "Node.js caches cleared."

# 4. Go Cleanup
start_spinner "Clearing Go build caches..."
rm -rf /home/*/.cache/go-build 2>/dev/null || true
stop_spinner "Go build caches cleared."

# 5. Docker Cleanup
if command -v docker >/dev/null 2>&1; then
    start_spinner "Pruning dangling Docker images and build caches..."
    docker image prune -f >/dev/null 2>&1
    docker builder prune -f >/dev/null 2>&1
    stop_spinner "Docker artifacts pruned safely."
fi

# 6. Calculate Space Freed
USED_AFTER=$(df -k / | awk 'NR==2 {print $3}')
FREED_KB=$((USED_BEFORE - USED_AFTER))

# Failsafe: System cache fluctuations can sometimes make this slightly negative
if [[ $FREED_KB -lt 0 ]]; then FREED_KB=0; fi

FREED_MB=$((FREED_KB / 1024))

log_info "=== Cleanup Results ==="
if [[ $FREED_MB -ge 1024 ]]; then
    FREED_GB=$(awk "BEGIN {printf \"%.2f\", $FREED_MB/1024}")
    log_success "Total space freed: ${YELLOW}${FREED_GB} GB${NC}"
else
    log_success "Total space freed: ${YELLOW}${FREED_MB} MB${NC}"
fi

log_success "=== DEV CLEANUP COMPLETED ==="