#!/bin/bash
# PiKVM Debian - Status Check Script
# This script checks the status of all PiKVM components

echo "======================================"
echo "PiKVM Debian - System Status Check"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_service() {
    local service=$1
    local name=$2
    if systemctl is-active --quiet "$service"; then
        echo -e "${GREEN}✓${NC} $name is running"
        return 0
    else
        echo -e "${RED}✗${NC} $name is not running"
        return 1
    fi
}

check_file() {
    local file=$1
    local name=$2
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $name exists: $file"
        return 0
    else
        echo -e "${RED}✗${NC} $name not found: $file"
        return 1
    fi
}

check_directory() {
    local dir=$1
    local name=$2
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓${NC} $name exists: $dir"
        return 0
    else
        echo -e "${RED}✗${NC} $name not found: $dir"
        return 1
    fi
}

echo "System Information:"
echo "  Hostname: $(hostname)"
echo "  IP Address: $(hostname -I | cut -d' ' -f1)"
echo "  OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "  Kernel: $(uname -r)"
echo "  Architecture: $(uname -m)"
echo ""

echo "Service Status:"
check_service "pikvm-usb-gadget" "USB Gadget"
check_service "ustreamer" "Video Streamer"
check_service "kvmd" "PiKVM Daemon"
check_service "nginx" "Web Server"
echo ""

echo "Required Files:"
check_file "/usr/local/bin/ustreamer" "ustreamer binary"
check_file "/usr/local/bin/pikvm-usb-gadget" "USB gadget script"
check_file "/etc/systemd/system/kvmd.service" "kvmd service"
check_file "/etc/systemd/system/ustreamer.service" "ustreamer service"
check_file "/etc/nginx/sites-enabled/kvmd" "nginx kvmd config"
echo ""

echo "Configuration Directories:"
check_directory "/etc/kvmd" "kvmd config"
check_directory "/var/lib/kvmd" "kvmd data"
check_directory "/var/log/kvmd" "kvmd logs"
echo ""

echo "Hardware Checks:"
if [ -e /dev/video0 ]; then
    echo -e "${GREEN}✓${NC} Video capture device found: /dev/video0"
else
    echo -e "${YELLOW}⚠${NC} Video capture device not found (may not be connected)"
fi

if [ -d /sys/kernel/config/usb_gadget/pikvm ]; then
    echo -e "${GREEN}✓${NC} USB gadget configured"
else
    echo -e "${YELLOW}⚠${NC} USB gadget not configured"
fi

if [ -e /dev/gpiochip0 ]; then
    echo -e "${GREEN}✓${NC} GPIO available"
else
    echo -e "${YELLOW}⚠${NC} GPIO not available"
fi
echo ""

echo "Network Ports:"
if command -v netstat &> /dev/null; then
    echo "  Listening ports:"
    netstat -tln | grep -E ':(80|443|8080|8081)' || echo "  No PiKVM ports listening"
else
    echo "  netstat not available, skipping port check"
fi
echo ""

echo "Quick Access:"
IP=$(hostname -I | cut -d' ' -f1)
echo "  Web Interface: http://$IP/"
echo "  Video Stream: http://$IP/streamer"
echo "  API Endpoint: http://$IP/api/info"
echo ""

echo "Recent Log Entries (last 5):"
if systemctl is-active --quiet kvmd; then
    echo "--- kvmd logs ---"
    journalctl -u kvmd -n 5 --no-pager 2>/dev/null || echo "Cannot read kvmd logs"
fi
echo ""

echo "======================================"
echo "Status check complete"
echo "======================================"
echo ""
echo "For detailed logs, use:"
echo "  sudo journalctl -u kvmd -f"
echo "  sudo journalctl -u ustreamer -f"
