# ARES Device Capabilities Matrix

**Last Updated**: January 16, 2026, 06:30 IST

---

## Quick Reference Table

| Device | WiFi | 2.4G | 5G | Monitor | Inject | TX Power | Location | Status |
|--------|------|------|----|---------| -------|----------|----------|--------|
| Router | ✅ 2x | ✅ | ✅ | ✅ | ✅ | 20 dBm | Factory | ✅ Ready |
| Office | ✅ | ✅ | ✅ | ✅ | ⚠️ | 31 dBm | Office | ⚠️ Ch34 |
| Lab | ✅ USB | ✅ | ✅ | ✅ | ⚠️ | 20 dBm | Lab | ⚠️ Ch10 |
| GPU | ❌ | ❌ | ❌ | ❌ | ❌ | - | GPU Room | ❌ N/A |
| Admin | ✅ | ✅ | ✅ | ⚠️ | ⚠️ | 30 dBm | Admin | ⚠️ Setup |

---

## Device Details

### 1. Router (OpenWrt)

```yaml
Device: GL.iNet OpenWrt Router
IP: 10.0.0.81
Hostname: ares-router.local
Location: Factory floor

Hardware:
  CPU: MIPS
  RAM: 57 MB
  WiFi Chips: 2x (MediaTek likely)

WiFi Radio 1 (phy0):
  Band: 2.4 GHz
  Channels: 1-14
  Interface: phy0-ap0 (default AP)
  Monitor: ✅ Supported (create mon0)
  TX Power: 20.00 dBm
  Injection: ✅ aireplay-ng tested

WiFi Radio 2 (phy1):
  Band: 5 GHz
  Channels: 36-165 (region dependent)
  Interface: phy1-ap0 (default AP)
  Monitor: ✅ Supported
  TX Power: 20.00 dBm
  Injection: ✅ aireplay-ng tested

Software:
  OS: OpenWrt 22.03
  Kernel: 5.15.150
  Tools: airodump-ng, aireplay-ng, aircrack-ng

Access:
  SSH: ssh root@10.0.0.81 (password: Rama1994#)
  mDNS: ssh root@ares-router.local
  ZeroTier: 10.73.168.3

Status: ✅ FULLY OPERATIONAL
```

### 2. Office Server

```yaml
Device: Kali Linux Server (likely Raspberry Pi)
IP: 10.0.0.176
Hostname: office-server.local
Location: Office Floor

Hardware:
  Platform: ARM (Raspberry Pi likely)
  WiFi: Built-in or USB adapter

WiFi Interface (wlan0):
  PHY: phy#0
  MAC: b8:27:eb:74:f2:6c
  Bands: 2.4 GHz + 5 GHz
  Current Channel: 34 (5170 MHz)
  Current Mode: Monitor
  TX Power: 31.00 dBm (HIGHEST!)
  Injection: ⚠️ Needs testing

Software:
  OS: Kali Linux
  Kernel: Recent (check with uname -r)
  Tools: Full aircrack-ng suite available

Access:
  SSH: ssh office-server (kali user)
  ZeroTier: 10.73.168.34

Current State:
  ⚠️ Locked to Channel 34 (5 GHz)
  ⚠️ Needs reconfiguration for 2.4 GHz ops
  ✅ Monitor mode already active

Status: ⚠️ NEEDS RECONFIGURATION
```

### 3. Lab Server (IBM x3650)

```yaml
Device: IBM System x3650 Server
IP: 10.0.0.192
Hostname: lab-server.local
Location: Lab Floor

Hardware:
  Model: IBM x3650 (Type 7979B9A)
  CPU: 2x Intel Xeon X5450 @ 3.00GHz
  RAM: 3 GB
  WiFi: TP-Link AC600 USB Adapter

WiFi Adapter (USB):
  Model: TP-Link AC600 (Archer T2U Nano)
  Chipset: Realtek RTL8811AU
  USB ID: 2357:011e
  Interface: wlx3460f9927ab3
  MAC: 34:60:f9:92:7a:b3

WiFi Capabilities:
  PHY: phy#0
  Bands: 2.4 GHz + 5 GHz (802.11ac)
  Current Channel: 10 (2457 MHz)
  Current Mode: Monitor
  TX Power: 20.00 dBm
  Injection: ⚠️ Needs testing (RTL8811AU driver)

Software:
  OS: Ubuntu 24.04.3 LTS
  Kernel: 6.8.0-90-generic
  Tools: iw, aircrack-ng suite (check availability)

Access:
  SSH: ssh lab-server
  ZeroTier: 10.73.168.19

Current State:
  ⚠️ Locked to Channel 10 (2.4 GHz)
  ⚠️ USB adapter (removable/portable)
  ✅ Monitor mode already active

Status: ⚠️ NEEDS RECONFIGURATION
Notes: USB adapter can be moved to other devices if needed
```

### 4. GPU Server

```yaml
Device: Custom Mining Rig
IP: 10.0.0.71
Hostname: gpu-server.local
Location: GPU Server Room

Hardware:
  CPU: Intel Celeron 877 @ 1.40GHz
  RAM: 4 GB
  GPUs: 4x AMD RX 570 4GB
  WiFi: ❌ NONE
  Network: Ethernet only (enp2s0)

GPU Capabilities:
  Model: PowerColor Red Dragon RX 570
  Count: 4x
  OpenCL: ✅ Supported
  Hashcat: ✅ 50+ GH/s (WPA cracking)
  Driver: amdgpu + Legacy OpenCL

Software:
  OS: Ubuntu 24.04.3 LTS
  Kernel: 6.14.0-37-generic (HWE)
  Tools: hashcat, OpenCL

Access:
  SSH: ssh gpu-server
  ZeroTier: 10.73.168.125

WiFi Status: ❌ NOT AVAILABLE
GPU Status: ✅ FULLY OPERATIONAL for hash cracking

Purpose: Receive hashes from other devices for GPU cracking
```

### 5. Admin Server (Alienware)

```yaml
Device: Alienware 17 R2 Laptop
IP: 10.0.0.xxx (dynamic)
Hostname: admin-server.local
Location: Admin Floor

Hardware:
  Model: Alienware 17 R2
  CPU: Intel i7-4720HQ
  GPU: GTX 970M 3GB (CUDA - different from GPU server)
  WiFi: Built-in PCIe

WiFi Card:
  Model: Qualcomm Atheros QCA6174
  Standard: 802.11ac
  Interface: wlp3s0
  PHY: phy#0
  MAC: 34:68:95:59:0d:67

WiFi Capabilities:
  Bands: 2.4 GHz + 5 GHz
  Current: Connected to Dharmani Office+ (5 GHz)
  Current Channel: 161 (5805 MHz)
  Current Mode: Managed
  TX Power: 30.00 dBm (EXCELLENT)
  Monitor: ⚠️ Supported but needs setup
  Injection: ⚠️ Needs testing

Software:
  OS: Ubuntu 24.04
  Kernel: Recent
  Tools: iw, wireless-tools (check aircrack-ng)

Access:
  SSH: ssh admin-server
  ZeroTier: 10.73.168.32

Current State:
  ⚠️ Managed mode (active WiFi connection)
  ⚠️ Needs disconnect + monitor setup
  ⚠️ Currently connected to production network

Status: ⚠️ NEEDS MONITOR MODE SETUP
Notes: Best signals for Dharmani networks
       Disconnect from Office+ before WiFi ops
```

---

## Configuration Commands

### Router: Setup Monitor Mode

```bash
# SSH to router
ssh root@10.0.0.81

# Stop WiFi APs
wifi down
sleep 2

# Create monitor interface (2.4 GHz example)
iw phy phy0 interface add mon0 type monitor
ip link set mon0 up
iw dev mon0 set channel 6

# Verify
iw dev mon0 info

# When done - cleanup
iw dev mon0 del
wifi up
```

### Office Server: Reconfigure for 2.4 GHz

```bash
# SSH to Office Server
ssh office-server

# Current state: Monitor on Ch 34 (5 GHz)
iw dev wlan0 info

# Change to 2.4 GHz
sudo ip link set wlan0 down
sudo iw dev wlan0 set type managed
sudo ip link set wlan0 up
sudo iw dev wlan0 scan  # Get available networks

# Back to monitor on 2.4 GHz
sudo ip link set wlan0 down
sudo iw dev wlan0 set type monitor
sudo ip link set wlan0 up
sudo iw dev wlan0 set channel 11  # Or target channel

# Verify
iw dev wlan0 info
```

### Lab Server: Change Channel

```bash
# SSH to Lab Server
ssh lab-server

# Current: Monitor on Ch 10
iw dev wlx3460f9927ab3 info

# Change channel
ip link set wlx3460f9927ab3 down
iw dev wlx3460f9927ab3 set channel 6  # Target channel
ip link set wlx3460f9927ab3 up

# Verify
iw dev wlx3460f9927ab3 info
```

### Admin Server: Setup Monitor Mode

```bash
# SSH to Admin Server
ssh admin-server

# Disconnect from current network
sudo nmcli device disconnect wlp3s0

# Setup monitor mode
sudo ip link set wlp3s0 down
sudo iw dev wlp3s0 set type monitor
sudo ip link set wlp3s0 up
sudo iw dev wlp3s0 set channel 11  # Target channel

# Verify
iw dev wlp3s0 info

# Test packet injection (if needed)
sudo aireplay-ng --test wlp3s0

# When done - restore managed mode
sudo ip link set wlp3s0 down
sudo iw dev wlp3s0 set type managed
sudo ip link set wlp3s0 up
sudo nmcli device connect wlp3s0  # Auto-reconnect
```

---

## Packet Injection Testing

### Test Command

```bash
# On each WiFi device, test injection capability
aireplay-ng --test <interface>

# Expected output if working:
# Trying broadcast probe requests...
# Injection is working!
# Found X APs

# If not working:
# Injection failed - check driver/chipset
```

### Known Compatibility

```
✅ Router (phy0/phy1):     Confirmed working
⚠️  Office Server (wlan0):  Needs testing
⚠️  Lab Server (USB):       RTL8811AU - may need rtl8812au driver
⚠️  Admin Server (wlp3s0):  QCA6174 - usually works but test needed
```

---

## Network Topology

```
Factory Building
├── Factory Floor
│   └── Router (10.0.0.81) - 2x WiFi radios
│       ├─ Best for: Airtel_vish_0615 (-45 dBm)
│       └─ Can reach: Most 2.4/5 GHz networks
│
├── Office Floor
│   └── Office Server (10.0.0.176) - wlan0
│       ├─ Currently: Ch 34 (5 GHz monitor)
│       └─ Needs: Reconfiguration for 2.4 GHz
│
├── Lab Floor
│   └── Lab Server (10.0.0.192) - USB WiFi
│       ├─ Currently: Ch 10 (2.4 GHz monitor)
│       └─ Can: Move USB adapter to other devices
│
├── Admin Floor
│   └── Admin Server (admin-server) - wlp3s0
│       ├─ Best for: Dharmani Office/Guest (-41/-45 dBm)
│       ├─ Currently: Connected to Office+ (production)
│       └─ Needs: Disconnect + monitor setup
│
└── GPU Room
    └── GPU Server (10.0.0.71) - No WiFi
        └─ Purpose: Hash cracking only (50+ GH/s)
```

---

## Recommended Device by Target

Based on actual signal measurements:

```
Target: Airtel_vish_0615
Device: ✅ Router (Factory)
Signal: -45 dBm ⭐⭐⭐⭐⭐
Reason: 44 dB better than Admin

Target: Dharmani Office
Device: ✅ Admin Server (Admin Floor)
Signal: -41 dBm ⭐⭐⭐⭐⭐
Reason: 19 dB better than Router

Target: Dharmani Guest
Device: ✅ Admin Server (Admin Floor)
Signal: -45 dBm ⭐⭐⭐⭐⭐
Reason: 15 dB better than Router + likely has clients

Target: Airtel_neer_3257
Device: ⚠️  Admin Server (weak -76 dBm)
Signal: -76 dBm ⭐⭐
Reason: 5 dB better than Router but both weak
```

---

## Priority Actions

### High Priority

1. ✅ Test packet injection on Office/Lab/Admin devices
2. ✅ Setup Admin Server monitor mode (best signals)
3. ✅ Reconfigure Office Server for 2.4 GHz operations

### Medium Priority

4. ⚠️  Scan from Office/Lab servers for signal comparison
5. ⚠️  Test RTL8811AU driver on Lab Server USB adapter
6. ⚠️  Map exact physical locations of all devices

### Low Priority

7. 📝 Create automated device configuration scripts
8. 📝 Test simultaneous captures from multiple devices
9. 📝 USB adapter portability testing (move Lab adapter)

---

**Document Status**: ✅ Complete
**Next Update**: After injection testing complete
