#!/bin/bash

# ==============================================================================
# QALIFE CORE - LOGGER
# ==============================================================================
# Description: Standardized logging functions and color definitions.
# ==============================================================================

# ANSI Color Codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Critical error wrapper (logs and exits)
fatal_error() {
    log_error "$1"
    exit 1
}