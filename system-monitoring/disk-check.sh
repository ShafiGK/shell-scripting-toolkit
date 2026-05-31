#!/bin/bash
##############################################
# Script: disk-check.sh
# Author: Shafique Khan
# Purpose: Monitor disk usage and alert
# Usage: ./disk-check.sh [threshold_percent]
# Example: ./disk-check.sh 80
##############################################

set -euo pipefail

# Configuration
THRESHOLD=${1:-80}
LOG_FILE="/tmp/disk-check.log"
HOSTNAME=$(hostname)

# Color codes
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

log_message() {
    echo "[$(date +%Y-%m-%d_%H:%M:%S)] $1" >> "$LOG_FILE"
}

check_disk() {
    log_message "Starting disk check on $HOSTNAME (threshold: ${THRESHOLD}%)"
    echo "Disk Usage Report for $HOSTNAME"
    echo "================================"
    echo ""
    
    df -h | awk -v threshold="$THRESHOLD" -v RED="$RED" -v YELLOW="$YELLOW" -v GREEN="$GREEN" -v NC="$NC" '
        NR == 1 { print; next }
        $5 ~ /[0-9]+%/ {
            usage = $5
            gsub(/%/, "", usage)
            if (usage+0 >= threshold) {
                print RED $0 " [ALERT]" NC
            } else if (usage+0 >= threshold-10) {
                print YELLOW $0 " [WARN]" NC
            } else {
                print GREEN $0 NC
            }
        }'
}

main() {
    check_disk
    log_message "Disk check completed"
}

main "$@"
