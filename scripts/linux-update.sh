#!/bin/bash
echo "=== Linux Patch Management Demo ==="
sudo apt update && sudo apt upgrade -y
echo "Disk usage:"
df -h /
echo "Memory usage:"
free -h
