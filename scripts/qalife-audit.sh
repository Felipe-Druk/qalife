#!/bin/bash

# ==============================================================================
# QALIFE - SYSTEM AUDIT SCRIPT (Security Scanner)
# ==============================================================================
# Description: Lightweight scanner for common security misconfigurations.
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

log_info "=== Starting Qalife Security Audit ==="

# 4. SSH Configuration Check
log_info "Checking SSH configuration..."
if [[ -f /etc/ssh/sshd_config ]]; then
    if grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config; then
        fatal_error "CRITICAL: SSH Root Login is ENABLED. This is a major security risk."
    else
        log_success "SSH Root Login is disabled or set to secure defaults."
    fi
else
    log_info "OpenSSH server not installed. Skipping SSH check."
fi

# 5. Firewall Status Check
log_info "Checking Firewall (UFW) status..."
if command -v ufw >/dev/null 2>&1; then
    UFW_STATUS=$(ufw status | grep -w "Status: active")
    if [[ -n "$UFW_STATUS" ]]; then
        log_success "UFW Firewall is active."
    else
        log_warn "UFW Firewall is inactive or disabled!"
    fi
else
    log_warn "UFW is not installed. System might be exposed."
fi

# 6. Empty Passwords Check
log_info "Checking for users with empty passwords..."
EMPTY_PASS_USERS=$(awk -F: '($2 == "") {print $1}' /etc/shadow 2>/dev/null)
if [[ -n "$EMPTY_PASS_USERS" ]]; then
    fatal_error "CRITICAL: Users with empty passwords found: $EMPTY_PASS_USERS"
else
    log_success "No users with empty passwords found."
fi

# 7. Exposed Ports Summary (Basic)
log_info "Retrieving active listening network ports..."
ss -tuln | awk 'NR>1 {print "  ->", $1, $5}' 

log_success "=== SECURITY AUDIT COMPLETED ==="