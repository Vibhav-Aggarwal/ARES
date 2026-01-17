# ARES Router Monitor - Enhanced Alerting

## Overview

The router monitor now supports multiple alert channels with configurable severity levels and cooldown periods to prevent alert spam.

---

## Alert Channels

### 1. SSH Logging (Always Active)
- Logs sent to Lab Server: `/tmp/ares_router_alerts.log`
- Logs sent to Cloud Server: `/tmp/ares_router_alerts.log`

### 2. Webhook Alerts (Optional)
- Supports Discord, Slack, or any webhook-compatible service
- Rich formatting with color-coded severity
- Includes state, router IP, and timestamp

---

## Configuration

### Environment Variables

```bash
# Enable webhook alerts
export ARES_WEBHOOK_ENABLED=true

# Set webhook URL (Discord/Slack/custom)
export ARES_WEBHOOK_URL="https://discord.com/api/webhooks/YOUR_WEBHOOK_URL"

# Alert cooldown (seconds) - prevents spam
export ARES_ALERT_COOLDOWN=300  # Default: 5 minutes
```

---

## Severity Levels

| Level | Color | Use Case |
|-------|-------|----------|
| `critical` | 🔴 Red | Router DOWN, complete failure |
| `warning` | 🟡 Yellow | Router DEGRADED, SSH issues |
| `info` | 🟢 Green | Router RECOVERED |

---

## Setup Examples

### Discord Webhook

1. Create webhook in Discord server settings
2. Copy webhook URL
3. Configure environment:

```bash
export ARES_WEBHOOK_ENABLED=true
export ARES_WEBHOOK_URL="https://discord.com/api/webhooks/123456/abcdef"
bash router_monitor.sh
```

### Slack Webhook

1. Create incoming webhook in Slack app settings
2. Get webhook URL
3. Configure environment:

```bash
export ARES_WEBHOOK_ENABLED=true
export ARES_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
bash router_monitor.sh
```

### Custom Webhook

Any service that accepts JSON POST requests with this format:

```json
{
  "embeds": [{
    "title": "🔴 ARES Router Alert",
    "description": "Router DOWN: Complete network failure",
    "color": 16711680,
    "fields": [
      {"name": "State", "value": "DOWN", "inline": true},
      {"name": "Router", "value": "10.0.0.81", "inline": true},
      {"name": "Timestamp", "value": "2026-01-17 15:30:00", "inline": false}
    ],
    "footer": {"text": "ARES Router Monitor"}
  }]
}
```

---

## Alert Cooldown

To prevent alert spam, the monitor enforces a cooldown period between alerts:

- **Default:** 5 minutes (300 seconds)
- **Configurable:** Set `ARES_ALERT_COOLDOWN` in seconds
- **Behavior:** Only one alert per cooldown period
- **State file:** `/tmp/ares_last_alert_time`

Example: Set 10 minute cooldown:
```bash
export ARES_ALERT_COOLDOWN=600
```

---

## Systemd Service (Recommended)

Create `/etc/systemd/system/ares-router-monitor.service`:

```ini
[Unit]
Description=ARES Router Health Monitor
After=network.target

[Service]
Type=simple
User=vibhavaggarwal
WorkingDirectory=/home/vibhavaggarwal/ares
Environment="ARES_WEBHOOK_ENABLED=true"
Environment="ARES_WEBHOOK_URL=https://discord.com/api/webhooks/YOUR_URL"
Environment="ARES_ALERT_COOLDOWN=300"
ExecStart=/bin/bash /home/vibhavaggarwal/ares/router_monitor.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable ares-router-monitor
sudo systemctl start ares-router-monitor
```

Check status:
```bash
sudo systemctl status ares-router-monitor
journalctl -u ares-router-monitor -f
```

---

## Testing Alerts

### Test webhook manually:

```bash
export ARES_WEBHOOK_ENABLED=true
export ARES_WEBHOOK_URL="YOUR_WEBHOOK_URL"

# Send test alert
bash -c 'source router_monitor.sh && alert "Test alert from ARES" "info"'
```

### Trigger alerts by simulating failure:

```bash
# 1. Block router temporarily (will trigger DOWN alert)
sudo iptables -A OUTPUT -d 10.0.0.81 -j DROP

# 2. Wait 30 seconds for monitor to detect

# 3. Restore access (will trigger RECOVERED alert)
sudo iptables -D OUTPUT -d 10.0.0.81 -j DROP
```

---

## Logs

- **Monitor logs:** `/tmp/ares_router_monitor.log`
- **Alert logs:** `/tmp/ares_router_alerts.log`
- **Crash reports:** `/tmp/ares_crash_report_YYYYMMDD_HHMMSS.txt`

---

## Troubleshooting

### Webhooks not sending

1. Check if enabled:
   ```bash
   echo $ARES_WEBHOOK_ENABLED
   ```

2. Verify URL is set:
   ```bash
   echo $ARES_WEBHOOK_URL
   ```

3. Test curl manually:
   ```bash
   curl -X POST "YOUR_WEBHOOK_URL" \
     -H "Content-Type: application/json" \
     -d '{"content": "Test message"}'
   ```

### Alert spam

- Increase cooldown period:
  ```bash
  export ARES_ALERT_COOLDOWN=900  # 15 minutes
  ```

- Check last alert time:
  ```bash
  cat /tmp/ares_last_alert_time
  date -r $(cat /tmp/ares_last_alert_time)
  ```

---

## Advanced: Multi-Channel Setup

Run multiple instances for different alert priorities:

```bash
# Critical alerts: Short cooldown, Discord
ARES_WEBHOOK_URL="discord_webhook" \
ARES_ALERT_COOLDOWN=60 \
bash router_monitor.sh &

# Info alerts: Long cooldown, Slack
ARES_WEBHOOK_URL="slack_webhook" \
ARES_ALERT_COOLDOWN=1800 \
bash router_monitor_info.sh &
```

---

**Last Updated:** 2026-01-17
**Version:** 2.0 (Enhanced Alerting)
