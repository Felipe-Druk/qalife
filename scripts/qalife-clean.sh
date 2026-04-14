#!/bin/bash

# ==============================================================================
# QALIFE - SYSTEM CLEANUP SCRIPT (Safe & Robust)
# ==============================================================================
# Description: Removes orphaned packages, clears apt cache, and rotates logs.
# Version: 0.2.0-dev
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

trap 'stop_spinner "Process interrupted."; exit 1' INT

log_info "=== Starting system maintenance ==="

# --- VERBOSE MODE HANDLING ---
if [[ "$QALIFE_VERBOSE" == "true" ]]; then
    log_warn "Verbose mode ENABLED. UI spinners bypassed for raw output."
    
    log_info "Updating and cleaning apt cache..."
    apt-get update
    apt-get autoclean -y
    apt-get clean
    
    log_info "Removing orphaned dependencies and residual configs..."
    apt-get autoremove --purge -y
    EXTRA_CONFIGS=$(dpkg -l | awk '/^rc/ {print $2}')
    if [[ -n "$EXTRA_CONFIGS" ]]; then
        echo "$EXTRA_CONFIGS" | xargs apt-get -y purge
    fi

    log_info "Managing and rotating log files..."
    find /var/log -type f -name "*.gz" -mtime +7 -delete 2>/dev/null || true
    find /var/log -type f -name "*.log" -size +50M -exec truncate -s 0 {} + 2>/dev/null || true
    
    log_info "Vacuuming Systemd Journal..."
    if command -v journalctl >/dev/null 2>&1; then
        journalctl --vacuum-size=200M
    fi

# --- STANDARD CLEAN MODE ---
else
    start_spinner "Updating and cleaning apt cache..."
    apt-get update -qq >/dev/null 2>&1
    apt-get autoclean -qq -y >/dev/null 2>&1
    apt-get clean -qq >/dev/null 2>&1
    stop_spinner "Apt cache optimized."

    start_spinner "Removing orphaned dependencies and residual configs..."
    apt-get autoremove --purge -qq -y >/dev/null 2>&1
    EXTRA_CONFIGS=$(dpkg -l | awk '/^rc/ {print $2}')
    if [[ -n "$EXTRA_CONFIGS" ]]; then
        echo "$EXTRA_CONFIGS" | xargs apt-get -y purge >/dev/null 2>&1
    fi
    stop_spinner "System packages cleaned."

    start_spinner "Managing and rotating log files..."
    find /var/log -type f -name "*.gz" -mtime +7 -delete 2>/dev/null || true
    find /var/log -type f -name "*.log" -size +50M -exec truncate -s 0 {} + 2>/dev/null || true
    stop_spinner "Log files rotated."

    if command -v journalctl >/dev/null 2>&1; then
        start_spinner "Vacuuming Systemd Journal..."
        journalctl --vacuum-size=200M >/dev/null 2>&1
        stop_spinner "Journalctl vacuumed to 200MB."
    fi
fi

start_spinner "Cleaning user thumbnail cache..."
find /home/*/.cache/thumbnails -type f -atime +7 -delete 2>/dev/null || true
stop_spinner "Thumbnails cleared."

log_success "=== MAINTENANCE COMPLETED SUCCESSFULLY ==="