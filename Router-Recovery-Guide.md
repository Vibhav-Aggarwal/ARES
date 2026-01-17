# Router WiFi Recovery Guide
**Issue**: Router accessible via ZeroTier but local WiFi still down
**Solution**: Re-enable WiFi through current shell session

---

## Current Status

✅ **Connected**: Router accessible via ZeroTier proxy
❌ **Local WiFi**: Still disabled from earlier `wifi down` command
❌ **SSH 10.0.0.81**: Connection timeout (WiFi interfaces down)

---

## Recovery Commands

Execute these commands in your current router shell session:

```bash
# 1. Check current WiFi status
wifi status

# 2. Enable WiFi
wifi up

# 3. Wait 10 seconds for interfaces to come up
sleep 10

# 4. Verify WiFi radios are up
wifi status

# 5. Check physical interfaces
iw dev

# 6. Verify you can see the router's own networks
iw dev phy0-ap0 scan | grep -E "SSID|freq|signal" | head -20

# 7. Restart network if needed
/etc/init.d/network restart

# 8. Test SSH from local network (from laptop)
# On laptop terminal:
ssh root@10.0.0.81
```

---

## Expected Output After `wifi up`

```json
{
  "radio0": {
    "up": true,
    "pending": false,
    "autostart": true,
    "disabled": false,
    "config": {
      "channel": "auto",
      "country": "US",
      "htmode": "HE20"
    },
    "interfaces": [
      {
        "section": "default_radio0",
        "ifname": "phy0-ap0",
        "config": {
          "mode": "ap",
          "ssid": "OpenWrt"
        }
      }
    ]
  },
  "radio1": {
    "up": true,
    "pending": false,
    "autostart": true,
    "disabled": false
  }
}
```

---

## If WiFi Still Not Working

```bash
# Option A: Restart wireless daemon
/etc/init.d/wireless restart

# Option B: Full network restart
/etc/init.d/network restart

# Option C: Reboot router (last resort)
reboot
```

---

## Verify Recovery

Once WiFi is back up, test from laptop:

```bash
# Test 1: Ping router
ping -c 3 10.0.0.81

# Test 2: SSH to router
ssh root@10.0.0.81

# Test 3: Verify monitor mode capability
ssh root@10.0.0.81 "iw phy phy0 info | grep -A 5 'Supported interface modes'"
```

---

## Next Steps After Recovery

Once router WiFi is restored:

1. ✅ Router available for testing
2. ⚠️ But remember: Airtel networks have NO clients
3. ⚠️ Need to fix Admin Server for Dharmani testing

**Recommendation**: Even with router working, focus on fixing Admin Server for Dharmani Office testing (guaranteed clients).

---

**Status**: Waiting for WiFi recovery
**Next**: Execute `wifi up` in current router shell
