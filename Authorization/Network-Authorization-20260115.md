# ARES Wireless Testing Authorization

**Date**: January 15, 2026
**Authorization**: Granted by Network Owner
**Scope**: All detected networks belong to user

---

## ✅ Authorized Networks for Testing

All networks detected in reconnaissance scan are **OWNED by user** and **AUTHORIZED for security testing**:

### User's Networks (All Authorized ✅)

1. **Airtel_vish_0615** (Dual-band)
   - 2.4 GHz: FC:9F:2A:27:66:1F, Channel 11
   - 5 GHz: FC:9F:2A:27:66:20, Channel 36
   - Signal: -51 dBm (Excellent)
   - Owner: User ✅

2. **Airtel_PAISLEY**
   - BSSID: 24:43:E2:BB:56:E0
   - Channel: 6 (2.4 GHz)
   - Signal: -87 dBm (Weak)
   - Owner: User ✅

3. **Airtel_neer_3257**
   - BSSID: F8:0D:A9:B5:D2:AA
   - Channel: 1 (2.4 GHz)
   - Signal: -78 dBm (Fair)
   - Owner: User ✅

4. **Airtel showroom**
   - BSSID: B4:A7:C6:13:4E:09
   - Channel: 1 (2.4 GHz)
   - Signal: -84 dBm (Weak)
   - Owner: User ✅

5. **Dharmani Office** (Multiple BSSIDs)
   - 2.4 GHz: 10:27:F5:CD:07:73, Channel 10
   - 5 GHz: 10:27:F5:CD:07:72, Channel 161
   - Signal: -61 dBm (Good)
   - Owner: User ✅

6. **Dharmani Guest** (Multiple BSSIDs)
   - BSSID 1: 12:27:F5:DD:07:73, Channel 10
   - BSSID 2: 9E:C2:F4:0D:77:FE, Channel 3
   - Signal: -61 dBm (Good)
   - Owner: User ✅

7. **Hidden SSID**
   - BSSID: EE:9F:2A:27:66:20
   - Channel: 36 (5 GHz)
   - Signal: -51 dBm (Excellent)
   - Owner: User ✅

---

## 🎯 Authorization Scope

**Authorized Activities**:
- ✅ Wireless reconnaissance and monitoring
- ✅ Handshake capture from own networks
- ✅ Password strength testing (offline cracking)
- ✅ Rogue AP testing (evil twin scenarios)
- ✅ Deauthentication testing
- ✅ Security vulnerability assessment
- ✅ Configuration hardening recommendations

**Time Window**: Unlimited (own infrastructure)

**Geographic Scope**: All locations where networks are deployed

**Data Handling**:
- Captures stored securely on ARES cluster
- Passwords documented for security review
- Findings used to improve security posture

---

## 🚀 Approved ARES Operations

### Priority 1: Password Strength Assessment

**Objective**: Test all networks to identify weak passwords

**Process**:
1. Capture WPA2 handshakes from each network
2. Attempt offline cracking with ARES GPU Server
3. Document password strength (time to crack)
4. Generate recommendations for weak passwords

### Priority 2: Security Configuration Audit

**Objective**: Identify misconfigured networks

**Focus Areas**:
- Mixed WPA/WPA2 detection (disable WPA/TKIP)
- Channel congestion analysis
- Signal strength optimization
- Hidden SSID analysis (effectiveness)

### Priority 3: Penetration Testing

**Objective**: Test defenses against common attacks

**Scenarios**:
- Evil twin / rogue AP attacks
- Client isolation testing
- WPS vulnerability testing (if enabled)
- Router admin interface security

---

## 📋 Testing Plan

### Phase 1: Tool Installation (Today)
- [ ] Install aircrack-ng suite on router
- [ ] Deploy ARES control scripts
- [ ] Test monitor mode functionality
- [ ] Verify packet injection capability

### Phase 2: First Target - Airtel_vish_0615 (Today)
**Why**: Best signal (-51 dBm), mixed WPA/WPA2 (vulnerable)

- [ ] Capture WPA2 handshake
- [ ] Transfer to ARES GPU Server
- [ ] Crack password with 4x RX570
- [ ] Document time to crack
- [ ] Generate security recommendations

### Phase 3: Comprehensive Assessment (This Week)
- [ ] Test all 7 networks
- [ ] Create password strength matrix
- [ ] Identify weakest configurations
- [ ] Deploy security fixes
- [ ] Re-test after hardening

### Phase 4: Ongoing Monitoring (Continuous)
- [ ] Automated weekly scans
- [ ] Detect new unauthorized devices
- [ ] Monitor for rogue APs
- [ ] Alert on security downgrades

---

## ✅ Authorization Confirmed

**Owner**: User (vibhavaggarwal)
**Networks**: All detected networks
**Status**: Fully Authorized ✅
**Date**: January 15, 2026

**Proceeding with ARES wireless security testing on authorized infrastructure.**
