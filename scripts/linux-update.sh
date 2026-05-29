#!/bin/bash
# =============================================================
# Linux System Maintenance Script
# Author : Aman Nanda
# Purpose: Automated patching, health check, and log report
# Tested : Kali Linux (VMware home lab)
# =============================================================

LOG_DIR="$HOME/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/sysadmin-report-$(date +%F).log"
HOSTNAME=$(hostname)
DATE=$(date "+%Y-%m-%d %H:%M:%S")

log() { echo "[$DATE] $1" | tee -a "$LOG_FILE"; }

log "===== System Maintenance Started on $HOSTNAME ====="
log "Log file: $LOG_FILE"

# --- Package updates ---
log "--- Updating package lists ---"
sudo apt update -y 2>&1 | tee -a "$LOG_FILE"

log "--- Upgrading installed packages ---"
UPGRADED=$(sudo apt upgrade -y 2>&1 | grep "upgraded" | tail -1)
log "Result: ${UPGRADED:-No upgrades needed}"

sudo apt autoremove -y >> "$LOG_FILE" 2>&1

# --- Disk health ---
log "--- Disk Usage ---"
df -h | tee -a "$LOG_FILE"

DISK_USE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
if [ "$DISK_USE" -gt 80 ]; then
  log "WARNING: Root disk usage at ${DISK_USE}% — exceeds 80% threshold"
else
  log "OK: Root disk usage at ${DISK_USE}% (threshold: 80%)"
fi

# --- Memory ---
log "--- Memory Usage ---"
free -h | tee -a "$LOG_FILE"

MEM_FREE=$(free | awk '/^Mem:/ {printf "%.0f", $4/$2*100}')
log "Free memory: ${MEM_FREE}% available"

# --- Running services check ---
log "--- Critical Service Status ---"
for svc in ssh ufw cron; do
  STATUS=$(systemctl is-active "$svc" 2>/dev/null)
  if [ "$STATUS" != "active" ]; then
    log "WARNING: Service $svc is $STATUS"
  else
    log "OK: Service $svc is $STATUS"
  fi
done

# --- Open ports audit ---
log "--- Listening Ports ---"
PORT_OUTPUT=$(ss -tlnp 2>/dev/null)
echo "$PORT_OUTPUT" | tee -a "$LOG_FILE"

PORT_COUNT=$(echo "$PORT_OUTPUT" | grep -c "LISTEN" || true)
if [ "$PORT_COUNT" -eq 0 ]; then
  log "OK: No open listening ports found — clean system"
else
  log "INFO: $PORT_COUNT listening port(s) detected — review above"
fi
log "===== Maintenance Complete. Report saved to: $LOG_FILE ====="
echo ""
echo "Full report: $LOG_FILE"
