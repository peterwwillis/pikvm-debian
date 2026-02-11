#!/bin/bash
# Master installation script for PiKVM on Raspberry Pi OS
# This script runs all installation steps in order

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "======================================"
echo "PiKVM Debian - Master Installation"
echo "======================================"
echo ""
echo "This script will install PiKVM on your Raspberry Pi OS system."
echo "It will perform the following steps:"
echo "  1. Install system packages"
echo "  2. Build and install ustreamer"
echo "  3. Install kvmd daemon"
echo "  4. Configure system for USB OTG"
echo ""
echo "WARNING: This script must be run as root (use sudo)"
echo "WARNING: Your system will need to be rebooted after configuration"
echo ""
echo "Continue? (y/N)"
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "ERROR: Please run as root (use sudo)"
    exit 1
fi

echo ""
echo "Step 1/4: Installing system packages..."
"$SCRIPT_DIR/install-packages.sh"

echo ""
echo "Step 2/4: Building ustreamer..."
"$SCRIPT_DIR/build-ustreamer.sh"

echo ""
echo "Step 3/4: Installing kvmd..."
"$SCRIPT_DIR/install-kvmd.sh"

echo ""
echo "Step 4/4: Configuring system..."
"$SCRIPT_DIR/configure-system.sh"

echo ""
echo "======================================"
echo "Installation Complete!"
echo "======================================"
echo ""
echo "IMPORTANT: You must reboot your Raspberry Pi now!"
echo ""
echo "After reboot, enable and start the services:"
echo "  sudo systemctl enable pikvm-usb-gadget ustreamer kvmd nginx"
echo "  sudo systemctl start pikvm-usb-gadget ustreamer kvmd nginx"
echo ""
echo "Then access the web interface at: http://$(hostname -I | cut -d' ' -f1)/"
echo ""
echo "Reboot now? (y/N)"
read -r reboot_response
if [[ "$reboot_response" =~ ^[Yy]$ ]]; then
    echo "Rebooting in 5 seconds... (Press Ctrl+C to cancel)"
    sleep 5
    reboot
else
    echo "Please reboot manually when ready: sudo reboot"
fi
