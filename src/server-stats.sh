#!/usr/bin/env bash

# server-stats.sh - A script to analyze server performance stats
# Author: Edvin Lidholm
# Date: 2025-04-24

set -euo pipefail

LC_NUMERIC="en_US.UTF-8"

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

calculate_percentage() {
  local total=$1
  local used=$2
  local percentage
  percentage=$(echo "$used/$total*100" | bc -l)
  printf "%.2f%%" "$percentage"
}

echo -e "${GREEN}Server Statistics Report - $(uname -n)${NC}"
echo -e "${GREEN}Generated on: $(date)${NC}"

print_header "OS Information"
if [ -f /etc/os-release ]; then
  # shellcheck source=/dev/null
  . /etc/os-release
  print_stat "OS" "$NAME $VERSION"
elif [ -f /etc/lsb-release ]; then
  # shellcheck source=/dev/null
  . /etc/lsb-release
  print_stat "OS" "$DISTRIB_ID $DISTRIB_RELEASE"
fi
print_stat "Kernel" "$(uname -s) $(uname -r)"

print_header "Uptime"
uptime_info=$(uptime -p)
print_stat "Uptime" "$uptime_info"

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
memory_usage=$(calculate_percentage "$total_memory" "$used_memory")

print_stat "Total Memory" "$total_memory MB"
print_stat "Used Memory" "$used_memory MB ($memory_usage)"
print_stat "Free Memory" "$free_memory MB"
print_stat "Available Memory" "$available_memory MB"

echo
swap_info=$(free -m | grep "Swap:")
total_swap=$(echo "$swap_info" | awk '{print $2}')
used_swap=$(echo "$swap_info" | awk '{print $3}')
free_swap=$(echo "$swap_info" | awk '{print $4}')

if [ "$total_swap" -ne 0 ]; then
  swap_usage=$(calculate_percentage "$total_swap" "$used_swap")
  print_stat "Total Swap Memory" "$total_swap MB"
  print_stat "Used Swap Memory" "$used_swap MB ($swap_usage)"
  print_stat "Free Swap Memory" "$free_swap MB"
else
  print_stat "Swap" "No swap configured"
fi

print_header "Disk Usage"
df_output=$(df -h --total | grep "total")
total_disk=$(echo "$df_output" | awk '{print $2}' | sed 's/G//')
used_disk=$(echo "$df_output" | awk '{print $3}' | sed 's/G//')
free_disk=$(echo "$df_output" | awk '{print $4}' | sed 's/G//')
disk_usage=$(calculate_percentage "$total_disk" "$used_disk")
print_stat "Total Disk Space" "$total_disk GB"
print_stat "Used Disk Space" "$used_disk GB ($disk_usage)"
print_stat "Free Disk Space" "$free_disk GB"

print_header "Top 5 Processes by CPU Usage"
ps aux --sort=-%cpu | head -n 6 | awk 'NR==1 {printf "\033[0;33m%-10s %-10s %-10s %-10s\033[0m\n", $1, $2, $3, $11}
NR>1 {printf "%-10s %-10s %-10s %-10s\n", $1, $2, $3, $11}'

print_header "Top 5 Processes by Memory Usage"
ps aux --sort=-%mem | head -n 6 | awk 'NR==1 {printf "\033[0;33m%-10s %-10s %-10s %-10s\033[0m\n", $1, $2, $4, $11}
NR>1 {printf "%-10s %-10s %-10s %-10s\n", $1, $2, $4, $11}'

print_header "Network Information"
print_stat "Hostname" "$(hostname)"
print_stat "Local IP address" "$(ip addr | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | tail -1)"
print_stat "Public IP Address" "$(curl -s ifconfig.me)"

print_header "Listening Ports"
if command -v ss &>/dev/null; then
  ss -tuln | grep -E 'LISTEN|Netid' | awk 'NR==1 {printf "\033[0;33m%-10s %-10s\033[0m\n", "Proto", "Local Address:Port"}
  NR>1 {printf "%-10s %-10s\n", $1, $5}'
elif command -v netstat &>/dev/null; then
  netstat -tuln | grep -E 'LISTEN|Proto' | awk 'NR==1 {printf "\033[0;33m%-10s %-10s\033[0m\n", "Proto", "Local Address:Port"}
  NR>1 {printf "%-10s %-10s\n", $1, $4}'
else
  echo -e "${RED}Error:${NC} Neither ss nor netstat command found. Cannot display listening ports."
fi

echo -e "\n${GREEN}Server Statistics Report Complete${NC}"
