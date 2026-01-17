# Project ARES - AI Development Guide

**Wireless Security Assessment & Router Monitoring**

This file helps Claude Code understand the project structure, conventions, and workflows for efficient development.

---

## 🎯 Project Overview

**Purpose:** Wireless security assessment tools and router health monitoring system
**Tech Stack:** Bash, Aircrack-ng suite, Network monitoring tools
**Status:** Active - Router monitoring operational
**Priority:** Medium
**Security Context:** Authorized security testing only

---

## 📁 Project Structure

```
ares/
├── ares_control.sh        # Main control script for wireless ops
├── router_monitor.sh      # Router health monitoring
└── CLAUDE.md             # This file
```

---

## 🔧 Development Environment

### Local Setup
```bash
cd ~/Projects/ares

# Check scripts
ls -la *.sh

# Make executable
chmod +x *.sh
```

### Server Deployment
- **Location:** lab-server:/home/vibhavaggarwal/ares
- **Hardware:** TP-Link AC600 USB WiFi (RTL8811AU)
- **Interface:** wlx3460f9927ab3
- **Purpose:** Security assessment node

---

## 🚀 Workflow for Claude Code

### Making Changes
```bash
# 1. Navigate to project
cd ~/Projects/ares

# 2. Read current script
cat router_monitor.sh

# 3. Make changes using Edit tool
# IMPORTANT: Preserve bash syntax, error handling

# 4. Test syntax
bash -n router_monitor.sh

# 5. Test execution (dry run if possible)
# Be careful with wireless operations

# 6. Commit
git add .
git commit -m "feat: description"

# 7. Deploy
~/Projects/.meta/deploy.sh deploy ares
```

### Common Tasks

**Improve Monitoring:**
1. Read `router_monitor.sh`
2. Understand state machine (HEALTHY/DEGRADED/DOWN)
3. Add new checks or alerts
4. Test locally first
5. Deploy to lab server

**Add New Feature:**
1. Follow existing patterns (log functions, error handling)
2. Use readonly variables for configuration
3. Add usage help if new command
4. Test thoroughly before deploy

---

## 📊 Script Components

### router_monitor.sh
**Purpose:** Monitor router health and detect crashes

**Key Functions:**
- `check_router_status()` - Ping & SSH checks
- `check_router_crash()` - State transition detection
- `diagnose_crash()` - Post-crash diagnostics
- `determine_crash_cause()` - Root cause analysis

**States:**
- `HEALTHY` - All checks pass
- `DEGRADED` - Network alive, SSH down
- `DOWN` - Complete failure

### ares_control.sh
**Purpose:** Wireless security assessment controls

**⚠️ IMPORTANT:** Only for authorized security testing
- Monitor mode management
- Interface control
- Network assessment

---

## 🔍 Code Patterns

### Logging Functions
```bash
log_info "Message"
log_success "Success message"
log_warning "Warning message"
log_error "Error message"
log_alert "Critical alert"
```

### Color Constants
```bash
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'  # No Color
```

### Error Handling
```bash
if command; then
    log_success "Operation succeeded"
else
    log_error "Operation failed"
    return 1
fi
```

---

## 🧪 Testing

### Syntax Check
```bash
# Check for syntax errors
bash -n router_monitor.sh
bash -n ares_control.sh
```

### Dry Run
```bash
# Test monitoring (read-only)
bash router_monitor.sh  # Will check router status
```

### Production Testing
```bash
ssh lab-server "cd /home/vibhavaggarwal/ares && bash router_monitor.sh"
```

---

## 🚨 Common Issues

### Issue: Script Permission Denied
**Solution:**
```bash
chmod +x *.sh
```

### Issue: Network Tools Not Found
**Solution:** Install dependencies
```bash
ssh lab-server "sudo apt-get install wakeonlan aircrack-ng"
```

### Issue: Wireless Interface Not Found
**Solution:** Check USB adapter
```bash
ssh lab-server "lsusb | grep Realtek"
ssh lab-server "ip link show | grep wlx"
```

---

## 📝 Code Standards

### Commit Messages
- `feat:` - New monitoring feature
- `fix:` - Bug fix in detection logic
- `refactor:` - Code cleanup
- `docs:` - Documentation update

### Bash Best Practices
- Use `set -e` for error handling
- Quote all variables: `"$VAR"`
- Use readonly for constants
- Clear function names
- Comment complex logic
- Use local variables in functions

---

## 🎯 Future Enhancements

### Planned Features
1. **Advanced Diagnostics**
   - Memory pressure detection
   - Temperature monitoring
   - Network throughput analysis

2. **Automated Recovery**
   - Auto-reboot on crash
   - Service restart attempts
   - Fallback configurations

3. **Alerting**
   - Email notifications
   - Webhook integration
   - Telegram alerts

---

## 🔗 Dependencies

### System Packages
```
aircrack-ng      # Wireless tools
wakeonlan        # WoL functionality
iw               # Wireless configuration
```

### Network Access
- SSH to router (root@10.0.0.81)
- Ping access (office network)
- ZeroTier access (10.73.168.3)

---

## 🛡️ Security Considerations

### Authorization
- Only use on authorized networks
- Lab server for testing only
- Document all wireless operations
- Follow responsible disclosure

### Best Practices
- Never run on production networks without permission
- Monitor mode can disrupt WiFi
- Keep logs for accountability
- Disable when not needed

---

## 🤖 Claude Code Optimization Tips

1. **Bash syntax is strict** - Always validate with `bash -n`
2. **Test in isolation** - Don't break running monitors
3. **Preserve error handling** - Keep existing safety checks
4. **Read before edit** - Understand state machines
5. **Comment complex logic** - Help future maintenance

---

## 📞 Quick Commands

```bash
# Start development
cd ~/Projects/ares

# Syntax check
bash -n router_monitor.sh

# Deploy
~/Projects/.meta/deploy.sh deploy ares

# Check running on server
ssh lab-server "ps aux | grep router_monitor"

# View logs
ssh lab-server "tail -f /tmp/ares_router_monitor.log"

# Stop monitoring
ssh lab-server "pkill -f router_monitor.sh"
```

---

## 🔧 Useful Snippets

### Check Router Status
```bash
ssh lab-server "ping -c 1 10.0.0.81 && echo 'Router reachable'"
```

### Wake Router
```bash
ssh lab-server "wakeonlan 88:a2:9e:09:e3:b4"
```

### Check Wireless Interface
```bash
ssh lab-server "iwconfig wlx3460f9927ab3"
```

---

**Last Updated:** 2026-01-17
**Maintained by:** Claude Code
**Security Notice:** Authorized use only
