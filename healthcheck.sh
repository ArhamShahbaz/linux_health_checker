#!/bin/bash
# Server Health Check Script

# ---------- SETTINGS (CHANGE these if you want) ----------
LOG_DIR="/opt/healthcheck/healthcheck-logs"   # CHANGE: where reports are saved
SERVICES="ssh nginx"               # CHANGE: services to check
DISK_LIMIT=80                      # CHANGE: warn if disk is above this %
# ----------------------------------------------------------

DATE=$(date +%Y-%m-%d)
LOG_FILE="$LOG_DIR/health-$DATE.log"

mkdir -p "$LOG_DIR"

{
echo "===== Health Report: $(date) ====="

echo ""
echo "--- DISK USAGE ---"
df -h

echo ""
echo "--- MEMORY USAGE ---"
free -h

echo ""
echo "--- TOP 5 PROCESSES (by memory) ---"
ps aux --sort=-%mem | head -n 6

echo ""
echo "--- SERVICES ---"
for s in $SERVICES; do
  if systemctl is-active --quiet "$s"; then
    echo "$s: RUNNING"
  else
    echo "$s: NOT RUNNING"
  fi
done

echo ""
USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
if [ "$USAGE" -gt "$DISK_LIMIT" ]; then
  echo "WARNING: Disk is ${USAGE}% full!"
else
  echo "Disk OK (${USAGE}% used)"
fi
} >> "$LOG_FILE"