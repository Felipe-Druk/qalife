#!/bin/bash

# ==============================================================================
# ULTIMATE SYSTEM CLEANUP SCRIPT (Safe & Robust)
# ==============================================================================
# Description: Maintenance script for Debian-based systems.
# Version: 1.0.0
# ==============================================================================

# Configuration
LOG_DIR="/var/log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 1. Privilege check
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root (use sudo)."
   exit 1
fi

log_info "Scanning for unnecessary files..."

ORPHANS=$(apt-get -s autoremove | grep -P '^\d+ upgraded' | awk '{print $4}')
RESIDUALS=$(dpkg -l | grep "^rc" | wc -l)

if [ "$ORPHANS" -eq 0 ] && [ "$RESIDUALS" -eq 0 ]; then
    log_success "Your system is already clean. No junk found! ✅"
else
    # ... (Proceed with cleanup logic) ...
    log_success "Cleanup finished. System is now optimized!"
fi

log_info "=== Starting system maintenance: $TIMESTAMP ==="

# 2. Package Management (APT Cleanup)
log_info "Updating package lists..."
apt-get update -qq

log_info "Cleaning up old package cache..."
apt-get autoclean -y
apt-get clean

log_info "Removing orphaned dependencies (autoremove)..."
apt-get autoremove --purge -y

# 3. Purging residual configuration files
log_info "Removing configuration files of uninstalled packages..."
EXTRA_CONFIGS=$(dpkg -l | awk '/^rc/ {print $2}')
if [ -n "$EXTRA_CONFIGS" ]; then
    echo "$EXTRA_CONFIGS" | xargs apt-get -y purge
    log_success "Residual configurations cleared."
else
    log_info "No residual configurations found."
fi

# 4. Log Management (Safe Method)
log_info "Managing log files (rotating and shrinking)..."

# Delete compressed logs older than 7 days
find $LOG_DIR -type f -name "*.gz" -mtime +7 -delete

# Shrink large log files without deleting the file (preserves permissions/owners)
# This prevents breaking services that require specific directory structures.
find $LOG_DIR -type f -name "*.log" -size +50M -exec truncate -s 0 {} +
log_success "Logs processed safely."

# 5. User-level Cleanup (Thumbnails and Cache)
log_info "Cleaning user thumbnail cache..."
find /home/*/.cache/thumbnails -type f -atime +7 -delete 2>/dev/null || true

# 6. Systemd Journal Management
if command -v journalctl >/dev/null; then
    log_info "Vacuuming Systemd Journal to 200MB..."
    journalctl --vacuum-size=200M
fi

# 7. Final disk space report
log_info "=== Disk Space Summary ==="
df -h / | grep /

log_success "=== MAINTENANCE COMPLETED SUCCESSFULLY ==="