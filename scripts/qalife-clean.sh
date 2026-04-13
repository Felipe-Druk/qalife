#!/bin/bash

# ==============================================================================
# QALIFE - SYSTEM CLEANUP SCRIPT (Safe & Robust)
# ==============================================================================
# Description: Maintenance and cleanup script for Debian-based systems.
# Version: 0.0.2
# ==============================================================================

# 1. Resolve absolute paths dynamically (Safe execution under sudo)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="$(cd "$SCRIPT_DIR/../core" && pwd)"

# 2. Bootstrap Logger
if [[ -f "$CORE_DIR/logger.sh" ]]; then
    source "$CORE_DIR/logger.sh"
else
    echo -e "\033[0;31m[ERROR]\033[0m Missing core/logger.sh. Execution aborted."
    exit 1
fi

# Configuration
LOG_DIR="/var/log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# 3. Privilege check
if [[ $EUID -ne 0 ]]; then
   fatal_error "This script must be run as root (use sudo)."
fi

log_info "=== Starting system maintenance: $TIMESTAMP ==="
log_info "Scanning for unnecessary files..."

# Check for orphans (Field 6) and residuals before acting
ORPHANS=$(apt-get -s autoremove | grep -P '^\d+ upgraded' | awk '{print $6}')
RESIDUALS=$(dpkg -l | grep "^rc" | wc -l)

# Failsafe: If ORPHANS is somehow empty, default to 0
ORPHANS=${ORPHANS:-0}

if [[ "$ORPHANS" -eq 0 ]] && [[ "$RESIDUALS" -eq 0 ]]; then
    log_success "Your system is already clean. No junk found."
else
    log_info "Found unnecessary packages. Proceeding with cleanup..."
fi

# 4. Package Management (APT Cleanup)
log_info "Updating package lists..."
apt-get update -qq >/dev/null 2>&1

log_info "Cleaning up old package cache..."
apt-get autoclean -qq -y >/dev/null 2>&1
apt-get clean -qq >/dev/null 2>&1

log_info "Removing orphaned dependencies (autoremove)..."
apt-get autoremove --purge -qq -y >/dev/null 2>&1

# 5. Purging residual configuration files
log_info "Removing configuration files of uninstalled packages..."
EXTRA_CONFIGS=$(dpkg -l | awk '/^rc/ {print $2}')
if [[ -n "$EXTRA_CONFIGS" ]]; then
    echo "$EXTRA_CONFIGS" | xargs apt-get -y purge >/dev/null 2>&1
    log_success "Residual configurations cleared."
else
    log_info "No residual configurations found."
fi

# 6. Log Management (Safe Method)
log_info "Managing log files (rotating and shrinking)..."

# Delete compressed logs older than 7 days
find "$LOG_DIR" -type f -name "*.gz" -mtime +7 -delete 2>/dev/null || true

# Shrink large log files without deleting the file (preserves permissions/owners)
find "$LOG_DIR" -type f -name "*.log" -size +50M -exec truncate -s 0 {} + 2>/dev/null || true
log_success "Logs processed safely."

# 7. User-level Cleanup (Thumbnails and Cache)
log_info "Cleaning user thumbnail cache..."
find /home/*/.cache/thumbnails -type f -atime +7 -delete 2>/dev/null || true

# 8. Systemd Journal Management
if command -v journalctl >/dev/null 2>&1; then
    log_info "Vacuuming Systemd Journal to 200MB..."
    journalctl --vacuum-size=200M >/dev/null 2>&1
fi

# 9. Final disk space report
log_info "=== Disk Space Summary ==="
df -h / | grep /$

log_success "=== MAINTENANCE COMPLETED SUCCESSFULLY ==="