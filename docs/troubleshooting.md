# Troubleshooting Log

## Issue: Permission Denied on Log File

**Date:** 2026-05-29
**Script:** scripts/linux-update.sh
**Environment:** Kali Linux VM (VMware home lab)

### Problem
Script failed with this error on every line:
tee: /var/log/sysadmin-report.log: Permission denied

### Root Cause
/var/log/ is owned by root on Linux.
A normal user cannot write files there without sudo.

### Fix
Changed log path from /var/log/ to $HOME/logs/
Added mkdir -p to auto-create the folder.

### What I Learned
- Linux file permissions: /var/log is root-owned
- Always test scripts as the user who will actually run them
- Use $HOME for user-level logging

### Other Findings During This Lab
- SSH service was inactive → started it with systemctl start ssh
- UFW firewall was inactive → enabled it with ufw enable
- Disk usage at 42% → healthy, below 80% threshold
- No unexpected open ports found
