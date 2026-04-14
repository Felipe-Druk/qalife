#!/bin/bash

# ==============================================================================
# QALIFE - DEV ENVIRONMENT CLEANUP SCRIPT
# ==============================================================================
# Description: Safely purges development caches (Python, Node, Go, Docker).
# Version: 0.1.0-dev
# ==============================================================================

# 1. Resolve absolute paths dynamically
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="$(cd "$SCRIPT_DIR/../core" && pwd)"

# 2. Bootstrap Logger
if [[ -f "$CORE_DIR/logger.sh" ]]; then
    source "$CORE_DIR/logger.sh"
else
    echo -e "\033[0;31m[ERROR]\033[0m Missing core/logger.sh. Execution aborted."
    exit 1
fi

# 3. Privilege check
if [[ $EUID -ne 0 ]]; then
   fatal_error "This script must be run as root (use sudo)."
fi

log_info "=== Starting Developer Environment Cleanup ==="

# 4. Python Cleanup
log_info "Cleaning Python compiled artifacts and pip cache..."
# Remove global and user pip caches
rm -rf /root/.cache/pip 2>/dev/null || true
rm -rf /home/*/.cache/pip 2>/dev/null || true

# Find and remove __pycache__ directories and .pyc files securely
find /home/* /root -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find /home/* /root -type f -name "*.pyc" -delete 2>/dev/null || true
log_success "Python caches purged."

# 5. Node.js & TypeScript Cleanup (NPM/Yarn)
log_info "Clearing Node.js (NPM/Yarn) package caches..."
rm -rf /home/*/.npm/_cacache 2>/dev/null || true
rm -rf /home/*/.yarn/cache 2>/dev/null || true
log_success "Node.js caches cleared."

# 6. Go Cleanup
log_info "Clearing Go build caches..."
rm -rf /home/*/.cache/go-build 2>/dev/null || true
log_success "Go build caches cleared."

# 7. Docker Cleanup (Safe Mode)
if command -v docker >/dev/null 2>&1; then
    log_info "Pruning dangling Docker images and build caches..."
    # Only removes dangling (untagged/unused) images and build cache, NOT active containers
    docker image prune -f >/dev/null 2>&1
    docker builder prune -f >/dev/null 2>&1
    log_success "Docker artifacts pruned safely."
else
    log_info "Docker is not installed. Skipping..."
fi

# 8. Disk Space Summary
log_info "=== Post-Cleanup Disk Space ==="
df -h / | grep /$

log_success "=== DEV CLEANUP COMPLETED ==="