#!/usr/bin/env bash

# server-stats.sh - A script to analyze server performance stats
# Author: Edvin Lidholm
# Date: 2025-04-24

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

print_header() {
  echo -e "\n${BLUE}==== $1 ====${NC}"
}

print_stat() {
  echo -e "${YELLOW}$1:${NC} $2"
}

# Chheck if running as root (some commands might need elevated privileges)
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Warning:${NC} Some statistics might be limited because script is not running as root"
fi

echo -e "${GREEN}Server Statistics Report - $(uname -n)${NC}"
echo -e "${GREEN}Generated on: $(date)${NC}"

print_header "OS Information"
if [ -f /etc/os-release ]; then
  . /etc/os-release
  print_stat "OS" "$NAME $VERSION"
elif [ -f /etc/lsb-release ]; then
  print_stat "OS" "$DISTRIB_ID $DISTRIB_RELEASE"
fi
print_stat "Kernel" "$(uname -s) $(uname -r)"

print_header "CPU Usage"
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8"%"}')
print_stat "Total CPU Usage" "$cpu_usage"

