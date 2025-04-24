# Server Performance Statistics Tool

A bash script to analyze basic server performance statistics on Linux systems.

## Overview

This tool provides a comprehensive overview of your server's performance metrics including:

- Uptime
- CPU usage
- Memory usage (Free vs Used)
- Disk usage (Free vs Used)
- Top 5 processes by CPU usage
- Top 5 processes by memory usage

Additional information provided:
- OS version
- Network information and listening ports

## Requirements

- Linux-based operating system
- Bash shell
- Basic utilities: `ps`, `free`, `df`, `top`

## Installation

1. Download the script:
```bash
curl -O https://raw.githubusercontent.com/elidholm/server-stats/master/src/server-stats.sh
```

2. Make the script executable:
```bash
chmod +x server-stats.sh
```

## Usage

Run the script with:

```bash
./server-stats.sh
```

Alternatively you can run the script directly from GitHub:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/elidholm/server-stats/master/src/server-stats.sh)"
```

The script will display a formatted output of all server statistics to the terminal.

## Example Output

```
Server Statistics Report - myserver
Generated on: Thu Apr 24 15:30:45 EDT 2025

==== OS Information ====
OS: Ubuntu 22.04.5 LTS (Jammy Jellyfish)
Kernel: Linux 6.8.0-57-generic

==== Uptime ====
Uptime: up 2 days, 2 hours, 25 minutes

==== CPU Usage ====
Total CPU Usage: 15.8%

==== Memory Usage ====
Total Memory: 31520 MB
Used Memory: 11640 MB (36.93%)
Free Memory: 4820 MB
Available Memory: 17771 MB

Total Swap Memory: 1955 MB
Used Swap Memory: 149 MB (7.62%)
Free Swap Memory: 1806 MB
...
```

## Project URL
This is a project from the [Roadmap.sh](https://roadmap.sh) community. You can find more information and contribute to the project at:

> <https://roadmap.sh/projects/server-stats>

## License

This project is open source and available under the Apache-2.0 License.

## Author

Created by Edvin Lidholm on April 24, 2025
