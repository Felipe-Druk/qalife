#!/bin/bash

# ==============================================================================
# QALIFE CORE - LOGGER & UI
# ==============================================================================
# Description: Standardized logging functions, colors, and UI elements.
# ==============================================================================

# ANSI Color Codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Base Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

fatal_error() {
    log_error "$1"
    exit 1
}

# --- UI Elements (Spinner) ---
SPINNER_PID=""

start_spinner() {
    local msg="$1"
    
    tput civis 2>/dev/null || true
    echo -ne "${BLUE}[..]${NC} $msg "

    
    (
        local spin_chars="\|/-"
        while true; do
            for i in {0..3}; do
                echo -ne "\b${spin_chars:$i:1}"
                sleep 0.1
            done
        done
    ) &
    
    SPINNER_PID=$!
}

stop_spinner() {
    local success_msg="$1"
    if [[ -n "$SPINNER_PID" ]]; then
        kill "$SPINNER_PID" >/dev/null 2>&1
        wait "$SPINNER_PID" 2>/dev/null
        SPINNER_PID=""
        
        tput cnorm 2>/dev/null || true
    
        echo -ne "\r\033[K" 
        log_success "$success_msg"
    fi
}