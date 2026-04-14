#!/bin/bash

# ==============================================================================
# QALIFE - SYSTEM AUDIT SCRIPT (Safe & Robust)
# ==============================================================================
# Description: Lightweight scanner for common security misconfigurations.
# Version: 0.2.0-dev
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

# Intercept Ctrl+C to clean up spinner
trap '[[ -n "$SPINNER_PID" ]] && stop_spinner "Process interrupted."; exit 1' INT

log_info "=== Starting Qalife Security Audit ==="

# ==============================================================================
# VERBOSE MODE ENABLED
# ==============================================================================
if [[ "$QALIFE_VERBOSE" == "true" ]]; then
    log_warn "Verbose mode ENABLED. Bypassing UI for raw output."
    echo ""

    # 4. SSH Configuration Check
    log_info "Checking SSH configuration..."
    if [[ -f /etc/ssh/sshd_config ]]; then
        if grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config; then
            grep -i "^PermitRootLogin" /etc/ssh/sshd_config | sed 's/^/  -> /'
            fatal_error "CRITICAL: SSH Root Login is ENABLED. This is a major security risk."
        else
            log_success "SSH Root Login is disabled or set to secure defaults."
            grep -i "^PermitRootLogin" /etc/ssh/sshd_config | sed 's/^/  -> /' || echo "  -> PermitRootLogin not explicitly defined (secure defaults apply)."
        fi
    else
        log_info "OpenSSH server not installed. Skipping SSH check."
    fi
    echo ""

    # 5. Firewall Status Check
    log_info "Checking Firewall (UFW) status..."
    if command -v ufw >/dev/null 2>&1; then
        UFW_STATUS=$(ufw status | grep -w "Status: active")
        if [[ -n "$UFW_STATUS" ]]; then
            log_success "UFW Firewall is active."
        else
            log_warn "UFW Firewall is inactive or disabled!"
        fi
        # Dump detailed ufw status indented
        ufw status verbose | sed 's/^/  -> /'
    else
        log_warn "UFW is not installed. System might be exposed."
    fi
    echo ""

    # 6. Empty Passwords Check
    log_info "Checking for users with empty passwords..."
    EMPTY_PASS_USERS=$(awk -F: '($2 == "") {print $1}' /etc/shadow 2>/dev/null)
    if [[ -n "$EMPTY_PASS_USERS" ]]; then
        echo "$EMPTY_PASS_USERS" | sed 's/^/  -> User: /'
        fatal_error "CRITICAL: Users with empty passwords found."
    else
        log_success "No users with empty passwords found."
        echo "  -> /etc/shadow parsed successfully. 0 empty hashes."
    fi
    echo ""

    # 7. Exposed Ports Summary (Verbose shows process names with 'p' flag)
    log_info "Retrieving active listening network ports..."
    ss -tulnp | awk 'NR>1 {print "  ->", $1, $5, $7}' 
    echo ""

# ==============================================================================
# STANDARD UI MODE
# ==============================================================================
else
    # 4. SSH Configuration Check
    start_spinner "Checking SSH configuration..."
    if [[ -f /etc/ssh/sshd_config ]]; then
        if grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config; then
            stop_spinner "Failed."
            fatal_error "CRITICAL: SSH Root Login is ENABLED. This is a major security risk."
        else
            stop_spinner "SSH Root Login is disabled or set to secure defaults."
        fi
    else
        kill "$SPINNER_PID" >/dev/null 2>&1; wait "$SPINNER_PID" 2>/dev/null; SPINNER_PID=""; tput cnorm; echo -ne "\r\033[K"
        log_info "OpenSSH server not installed. Skipping SSH check."
    fi

    # 5. Firewall Status Check
    start_spinner "Checking Firewall (UFW) status..."
    if command -v ufw >/dev/null 2>&1; then
        UFW_STATUS=$(ufw status | grep -w "Status: active")
        if [[ -n "$UFW_STATUS" ]]; then
            stop_spinner "UFW Firewall is active."
        else
            kill "$SPINNER_PID" >/dev/null 2>&1; wait "$SPINNER_PID" 2>/dev/null; SPINNER_PID=""; tput cnorm; echo -ne "\r\033[K"
            log_warn "UFW Firewall is inactive or disabled!"
        fi
    else
        kill "$SPINNER_PID" >/dev/null 2>&1; wait "$SPINNER_PID" 2>/dev/null; SPINNER_PID=""; tput cnorm; echo -ne "\r\033[K"
        log_warn "UFW is not installed. System might be exposed."
    fi

    # 6. Empty Passwords Check
    start_spinner "Checking for users with empty passwords..."
    EMPTY_PASS_USERS=$(awk -F: '($2 == "") {print $1}' /etc/shadow 2>/dev/null)
    if [[ -n "$EMPTY_PASS_USERS" ]]; then
        stop_spinner "Failed."
        fatal_error "CRITICAL: Users with empty passwords found: $EMPTY_PASS_USERS"
    else
        stop_spinner "No users with empty passwords found."
    fi

    # 7. Exposed Ports Summary
    log_info "Retrieving active listening network ports..."
    ss -tuln | awk 'NR>1 {print "  ->", $1, $5}' 
fi

log_success "=== SECURITY AUDIT COMPLETED ==="