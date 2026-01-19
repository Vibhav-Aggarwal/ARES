#!/bin/bash
# ARES Router Health Monitor
# Monitors router and reports crashes to Lab server and cloud
# Enhanced with webhook and multi-channel alerting

ROUTER_IP="10.0.0.81"
ROUTER_ZT_IP="10.73.168.3"
LAB_SERVER="lab-server.vibhavaggarwal.com"
CLOUD_SERVER="vibhav-home-server"
LOG_FILE="/tmp/ares_router_monitor.log"
ALERT_FILE="/tmp/ares_router_alerts.log"

# Alert configuration (override via environment variables)
WEBHOOK_URL="${ARES_WEBHOOK_URL:-}"
WEBHOOK_ENABLED="${ARES_WEBHOOK_ENABLED:-false}"
ALERT_COOLDOWN="${ARES_ALERT_COOLDOWN:-300}"  # 5 min default between alerts
LAST_ALERT_FILE="/tmp/ares_last_alert_time"

# Colors for logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a ${LOG_FILE}
}

should_send_alert() {
    # Check if enough time has passed since last alert (cooldown)
    if [ ! -f "${LAST_ALERT_FILE}" ]; then
        return 0  # No previous alert, send it
    fi

    local LAST_ALERT=$(cat "${LAST_ALERT_FILE}")
    local NOW=$(date +%s)
    local ELAPSED=$((NOW - LAST_ALERT))

    if [ "${ELAPSED}" -ge "${ALERT_COOLDOWN}" ]; then
        return 0  # Cooldown expired, send alert
    else
        log "Alert cooldown active (${ELAPSED}s / ${ALERT_COOLDOWN}s)"
        return 1  # Still in cooldown
    fi
}

send_webhook_alert() {
    local SEVERITY="$1"
    local MESSAGE="$2"
    local STATE="$3"

    if [ "${WEBHOOK_ENABLED}" != "true" ] || [ -z "${WEBHOOK_URL}" ]; then
        return
    fi

    # Determine color based on severity
    case "${SEVERITY}" in
        critical) COLOR="16711680" ;;  # Red
        warning)  COLOR="16776960" ;;  # Yellow
        info)     COLOR="65280" ;;     # Green
        *)        COLOR="8421504" ;;   # Gray
    esac

    # Create JSON payload
    local PAYLOAD=$(cat <<EOF
{
  "embeds": [{
    "title": "🔴 ARES Router Alert",
    "description": "${MESSAGE}",
    "color": ${COLOR},
    "fields": [
      {
        "name": "State",
        "value": "${STATE}",
        "inline": true
      },
      {
        "name": "Router",
        "value": "${ROUTER_IP}",
        "inline": true
      },
      {
        "name": "Timestamp",
        "value": "$(date '+%Y-%m-%d %H:%M:%S')",
        "inline": false
      }
    ],
    "footer": {
      "text": "ARES Router Monitor"
    }
  }]
}
EOF
)

    # Send webhook (suppress output to avoid log spam)
    curl -s -X POST "${WEBHOOK_URL}" \
        -H "Content-Type: application/json" \
        -d "${PAYLOAD}" > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        log "Webhook alert sent successfully"
    else
        log "Webhook alert failed"
    fi
}

alert() {
    local MESSAGE="$1"
    local SEVERITY="${2:-warning}"  # Default to warning

    echo -e "${RED}[ALERT]${NC} ${MESSAGE}" | tee -a ${ALERT_FILE}
    log "ALERT: ${MESSAGE}"

    # Check cooldown
    if ! should_send_alert; then
        return
    fi

    # Update last alert time
    date +%s > "${LAST_ALERT_FILE}"

    # Send alert to Lab server
    ssh ${LAB_SERVER} "echo '[$(date)] ROUTER ALERT: ${MESSAGE}' >> /tmp/ares_router_alerts.log" 2>/dev/null

    # Send alert to cloud server
    ssh ${CLOUD_SERVER} "echo '[$(date)] ROUTER ALERT: ${MESSAGE}' >> /tmp/ares_router_alerts.log" 2>/dev/null

    # Send webhook alert if enabled
    send_webhook_alert "${SEVERITY}" "${MESSAGE}" "${STATE:-UNKNOWN}"
}

check_router_status() {
    local TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    # Check ping (office network)
    if ping -c 1 -W 2 ${ROUTER_IP} > /dev/null 2>&1; then
        PING_OFFICE="✓"
    else
        PING_OFFICE="✗"
    fi

    # Check ping (ZeroTier)
    if ping -c 1 -W 2 ${ROUTER_ZT_IP} > /dev/null 2>&1; then
        PING_ZT="✓"
    else
        PING_ZT="✗"
    fi

    # Check SSH
    if ssh -o ConnectTimeout=2 -o BatchMode=yes root@${ROUTER_IP} 'exit' 2>/dev/null; then
        SSH_STATUS="✓"
    else
        SSH_STATUS="✗"
    fi

    # Determine health state
    if [ "${PING_OFFICE}" = "✓" ] && [ "${SSH_STATUS}" = "✓" ]; then
        STATE="HEALTHY"
    elif [ "${PING_OFFICE}" = "✓" ] && [ "${SSH_STATUS}" = "✗" ]; then
        STATE="DEGRADED"
    else
        STATE="DOWN"
    fi

    echo "${TIMESTAMP}|${STATE}|Ping(Office):${PING_OFFICE}|Ping(ZT):${PING_ZT}|SSH:${SSH_STATUS}"
}

check_router_crash() {
    local STATUS=$(check_router_status)
    local STATE=$(echo ${STATUS} | cut -d'|' -f2)
    local DETAILS=$(echo ${STATUS} | cut -d'|' -f3-)

    log "Status: ${STATE} | ${DETAILS}"

    # Check if state changed from previous check
    if [ -f /tmp/ares_router_last_state ]; then
        LAST_STATE=$(cat /tmp/ares_router_last_state)
    else
        LAST_STATE="UNKNOWN"
    fi

    # Save current state
    echo "${STATE}" > /tmp/ares_router_last_state

    # Detect state transitions and alert with appropriate severity
    if [ "${LAST_STATE}" = "HEALTHY" ] && [ "${STATE}" = "DEGRADED" ]; then
        alert "Router DEGRADED: Network alive but SSH down - ${DETAILS}" "warning"
        diagnose_crash
    elif [ "${LAST_STATE}" = "HEALTHY" ] && [ "${STATE}" = "DOWN" ]; then
        alert "Router DOWN: Complete network failure - ${DETAILS}" "critical"
    elif [ "${LAST_STATE}" = "DEGRADED" ] && [ "${STATE}" = "DOWN" ]; then
        alert "Router DOWN: Degraded state escalated to complete failure - ${DETAILS}" "critical"
    elif [ "${STATE}" = "HEALTHY" ] && [ "${LAST_STATE}" != "HEALTHY" ]; then
        log "Router RECOVERED: ${LAST_STATE} → HEALTHY"
        alert "Router RECOVERED from ${LAST_STATE}" "info"
    fi
}

diagnose_crash() {
    log "Running crash diagnostics..."

    # Try to get uptime (if router responds)
    UPTIME=$(ssh -o ConnectTimeout=2 root@${ROUTER_IP} 'uptime' 2>/dev/null || echo "SSH unavailable")
    log "Uptime: ${UPTIME}"

    # Check memory usage before crash (if available)
    MEMORY=$(ssh -o ConnectTimeout=2 root@${ROUTER_IP} 'free -m' 2>/dev/null || echo "SSH unavailable")
    log "Memory: ${MEMORY}"

    # Get last 20 log lines (if available)
    LOGS=$(ssh -o ConnectTimeout=2 root@${ROUTER_IP} 'logread | tail -20' 2>/dev/null || echo "SSH unavailable")
    log "Last logs: ${LOGS}"

    # Check ARES processes (if SSH available)
    PROCESSES=$(ssh -o ConnectTimeout=2 root@${ROUTER_IP} 'ps | grep -E "airodump|aireplay"' 2>/dev/null || echo "SSH unavailable")
    log "ARES processes: ${PROCESSES}"

    # Generate crash report
    CRASH_REPORT="/tmp/ares_crash_report_$(date +%Y%m%d_%H%M%S).txt"
    cat > ${CRASH_REPORT} << EOF
ARES Router Crash Report
========================
Timestamp: $(date)
Previous State: ${LAST_STATE}
Current State: ${STATE}

Network Status:
- Office network ping: ${PING_OFFICE}
- ZeroTier ping: ${PING_ZT}
- SSH access: ${SSH_STATUS}

Diagnostics:
- Uptime: ${UPTIME}
- Memory: ${MEMORY}
- ARES Processes: ${PROCESSES}

Last System Logs:
${LOGS}

Likely Cause:
$(determine_crash_cause)

Recommendation:
- If DEGRADED: Services crashed, reboot router or restart services
- If DOWN: Complete failure, power cycle required
- Check if ARES operations (airodump/aireplay) were running
- Consider using Lab server for wireless ops instead of router
EOF

    log "Crash report saved: ${CRASH_REPORT}"

    # Send crash report to servers
    scp ${CRASH_REPORT} ${LAB_SERVER}:/tmp/ 2>/dev/null
    scp ${CRASH_REPORT} ${CLOUD_SERVER}:/tmp/ 2>/dev/null
}

determine_crash_cause() {
    if echo "${PROCESSES}" | grep -q "airodump\|aireplay"; then
        echo "ARES wireless operations likely caused crash (airodump/aireplay detected)"
    elif [ "${SSH_STATUS}" = "✗" ] && [ "${PING_OFFICE}" = "✓" ]; then
        echo "SSH service crashed while network stack alive (common with monitor mode)"
    else
        echo "Unknown - full system failure"
    fi
}

# Main monitoring loop
main() {
    log "ARES Router Monitor started (Enhanced Alerting v2.0)"
    log "Monitoring: ${ROUTER_IP} (office) | ${ROUTER_ZT_IP} (ZeroTier)"
    log "Alert cooldown: ${ALERT_COOLDOWN}s"

    if [ "${WEBHOOK_ENABLED}" = "true" ]; then
        log "Webhook alerts: ENABLED"
    else
        log "Webhook alerts: DISABLED (set ARES_WEBHOOK_ENABLED=true to enable)"
    fi

    while true; do
        check_router_crash
        sleep 30  # Check every 30 seconds
    done
}

# Run if called directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main
fi

# Flow test: 20:12:14
# Fix test: 20:17:20
