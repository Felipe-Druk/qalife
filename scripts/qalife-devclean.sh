#!/bin/bash

# ==============================================================================
# QALIFE - DEV ENVIRONMENT CLEANUP SCRIPT (Safe & Robust)
# ==============================================================================
# Description: Safely purges dev caches (Python, Node, Go, Docker, C++, Rust).
# Version: 0.2.1-dev
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

# Create a secure temporary file for the verbose buffer
TMP_LOG="/tmp/qalife_devclean_$$.log"

# Safe trap to ensure spinner stops cleanly and temp file is removed
trap '[[ -n "$SPINNER_PID" ]] && stop_spinner "Process interrupted."; rm -f "$TMP_LOG"; exit 1' INT

log_info "=== Starting Developer Environment Cleanup ==="

TOTAL_BEFORE=$(df -k / | awk 'NR==2 {print $3}')

# Helper function to calculate and display space freed per tool
report_tool_space() {
    local tool_name="$1"
    local kb_before="$2"
    local kb_after=$(df -k / | awk 'NR==2 {print $3}')
    local freed=$((kb_before - kb_after))
    
    # Failsafe for OS cache fluctuations
    [[ $freed -lt 0 ]] && freed=0 
    
    if [[ "$QALIFE_VERBOSE" == "true" ]]; then
        local freed_mb=$((freed / 1024))
        echo -e "  ${GREEN}[OK] Space freed by $tool_name: ${YELLOW}${freed_mb} MB${NC}\n"
    fi
}

if [[ "$QALIFE_VERBOSE" == "true" ]]; then
    log_warn "Verbose mode ENABLED. Buffering detailed dependency tracking..."
    echo ""
fi

# ------------------------------------------------------------------------------
# 1. Python Cleanup
# ------------------------------------------------------------------------------
STEP_BEFORE=$(df -k / | awk 'NR==2 {print $3}')
start_spinner "Cleaning Python compiled artifacts and pip cache..."
if [[ "$QALIFE_VERBOSE" == "true" ]]; then
    # Buffer verbose output to temp log
    rm -rfv /root/.cache/pip /home/*/.cache/pip > "$TMP_LOG" 2>&1 || true
    find /home/* /root -type d -name "__pycache__" -exec rm -rfv {} + >> "$TMP_LOG" 2>&1 || true
    find /home/* /root -type f -name "*.pyc" -print -delete >> "$TMP_LOG" 2>&1 || true
    stop_spinner "Python caches purged."
    
    # Dump formatted output
    [[ -s "$TMP_LOG" ]] && sed 's/^/  -> /' "$TMP_LOG" || echo "  -> No files removed."
    > "$TMP_LOG" # Clear buffer for the next tool
else
    rm -rf /root/.cache/pip /home/*/.cache/pip 2>/dev/null || true
    find /home/* /root -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
    find /home/* /root -type f -name "*.pyc" -delete 2>/dev/null || true
    stop_spinner "Python caches purged."
fi
report_tool_space "Python" "$STEP_BEFORE"

# ------------------------------------------------------------------------------
# 2. Node.js & TypeScript Cleanup
# ------------------------------------------------------------------------------
STEP_BEFORE=$(df -k / | awk 'NR==2 {print $3}')
start_spinner "Clearing Node.js package caches..."
if [[ "$QALIFE_VERBOSE" == "true" ]]; then
    rm -rfv /home/*/.npm/_cacache > "$TMP_LOG" 2>&1 || true
    rm -rfv /home/*/.yarn/cache >> "$TMP_LOG" 2>&1 || true
    stop_spinner "Node.js caches cleared."
    [[ -s "$TMP_LOG" ]] && sed 's/^/  -> /' "$TMP_LOG" || echo "  -> No files removed."
    > "$TMP_LOG"
else
    rm -rf /home/*/.npm/_cacache 2>/dev/null || true
    rm -rf /home/*/.yarn/cache 2>/dev/null || true
    stop_spinner "Node.js caches cleared."
fi
report_tool_space "Node.js" "$STEP_BEFORE"

# ------------------------------------------------------------------------------
# 3. Go Cleanup
# ------------------------------------------------------------------------------
STEP_BEFORE=$(df -k / | awk 'NR==2 {print $3}')
start_spinner "Clearing Go build caches..."
if [[ "$QALIFE_VERBOSE" == "true" ]]; then
    rm -rfv /home/*/.cache/go-build > "$TMP_LOG" 2>&1 || true
    stop_spinner "Go build caches cleared."
    [[ -s "$TMP_LOG" ]] && sed 's/^/  -> /' "$TMP_LOG" || echo "  -> No files removed."
    > "$TMP_LOG"
else
    rm -rf /home/*/.cache/go-build 2>/dev/null || true
    stop_spinner "Go build caches cleared."
fi
report_tool_space "Go" "$STEP_BEFORE"

# ------------------------------------------------------------------------------
# 4. C/C++ Cleanup (ccache)
# ------------------------------------------------------------------------------
STEP_BEFORE=$(df -k / | awk 'NR==2 {print $3}')
start_spinner "Clearing C/C++ compiler caches..."
if [[ "$QALIFE_VERBOSE" == "true" ]]; then
    rm -rfv /home/*/.cache/ccache > "$TMP_LOG" 2>&1 || true
    stop_spinner "C/C++ compiler caches cleared."
    [[ -s "$TMP_LOG" ]] && sed 's/^/  -> /' "$TMP_LOG" || echo "  -> No files removed."
    > "$TMP_LOG"
else
    rm -rf /home/*/.cache/ccache 2>/dev/null || true
    stop_spinner "C/C++ compiler caches cleared."
fi
report_tool_space "C/C++" "$STEP_BEFORE"

# ------------------------------------------------------------------------------
# 5. Rust Cleanup (Cargo)
# ------------------------------------------------------------------------------
STEP_BEFORE=$(df -k / | awk 'NR==2 {print $3}')
start_spinner "Clearing Rust Cargo caches..."
if [[ "$QALIFE_VERBOSE" == "true" ]]; then
    rm -rfv /home/*/.cargo/registry/cache > "$TMP_LOG" 2>&1 || true
    rm -rfv /home/*/.cargo/git/db >> "$TMP_LOG" 2>&1 || true
    stop_spinner "Rust caches cleared."
    [[ -s "$TMP_LOG" ]] && sed 's/^/  -> /' "$TMP_LOG" || echo "  -> No files removed."
    > "$TMP_LOG"
else
    rm -rf /home/*/.cargo/registry/cache 2>/dev/null || true
    rm -rf /home/*/.cargo/git/db 2>/dev/null || true
    stop_spinner "Rust caches cleared."
fi
report_tool_space "Rust" "$STEP_BEFORE"

# ------------------------------------------------------------------------------
# 6. Docker Cleanup
# ------------------------------------------------------------------------------
if command -v docker >/dev/null 2>&1; then
    STEP_BEFORE=$(df -k / | awk 'NR==2 {print $3}')
    start_spinner "Pruning dangling Docker images and build caches..."
    if [[ "$QALIFE_VERBOSE" == "true" ]]; then
        docker image prune -f > "$TMP_LOG" 2>&1
        docker builder prune -f >> "$TMP_LOG" 2>&1
        stop_spinner "Docker artifacts pruned safely."
        [[ -s "$TMP_LOG" ]] && sed 's/^/  -> /' "$TMP_LOG" || echo "  -> No files removed."
    else
        docker image prune -f >/dev/null 2>&1
        docker builder prune -f >/dev/null 2>&1
        stop_spinner "Docker artifacts pruned safely."
    fi
    report_tool_space "Docker" "$STEP_BEFORE"
fi

# Clean up temp file
rm -f "$TMP_LOG"

# ------------------------------------------------------------------------------
# Final Calculation
# ------------------------------------------------------------------------------
TOTAL_AFTER=$(df -k / | awk 'NR==2 {print $3}')
FREED_KB=$((TOTAL_BEFORE - TOTAL_AFTER))

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