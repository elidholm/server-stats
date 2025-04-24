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
idle_cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | sed 's/,/./')
cpu_usage=$(echo "100-$idle_cpu" | bc)
print_stat "Total CPU Usage" "$cpu_usage%"

print_header "Memory Usage"
memory_info=$(free -m | grep "Mem:")
total_memory=$(echo "$memory_info" | awk '{print $2}')
used_memory=$(echo "$memory_info" | awk '{print $3}')
free_memory=$(echo "$memory_info" | awk '{print $4}')
available_memory=$(echo "$memory_info" | awk '{print $7}')
memory_usage=$(echo " scale=2; $used_memory/$total_memory*100" | bc)

print_stat "Total Memory" "$total_memory MB"
print_stat "Used Memory" "$used_memory MB ($memory_usage%)"
print_stat "Free Memory" "$(echo "${free_memory}+${available_memory}" | bc) MB ($(echo "scale=2; 100-$memory_usage" | bc)%)"

swap_info=$(free -m | grep "Swap:")
total_swap=$(echo "$swap_info" | awk '{print $2}')
used_swap=$(echo "$swap_info" | awk '{print $3}')
free_swap=$(echo "$swap_info" | awk '{print $4}')

if [ "$total_swap" -ne 0 ]; then
  swap_usage=$(echo "scale=2; $used_swap/$total_swap*100" | bc)
  print_stat "Total Swap Memory" "$total_swap MB"
  print_stat "Used Swap Memory" "$used_swap MB ($swap_usage%)"
  print_stat "Free Swap Memory" "$free_swap MB ($(echo "scale=2; 100-$swap_usage" | bc)%)"
else
  print_stat "Swap" "No swap configured"
fi
