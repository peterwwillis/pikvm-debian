#!/bin/bash
# Configure Raspberry Pi OS for PiKVM
# This script sets up USB OTG, kernel modules, and system settings

set -e

echo "================================"
echo "Configuring Raspberry Pi for PiKVM"
echo "================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Check if running on Raspberry Pi
if [ ! -f /boot/config.txt ] && [ ! -f /boot/firmware/config.txt ]; then
    echo "Warning: /boot/config.txt not found. Are you running on a Raspberry Pi?"
    echo "Continue anyway? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Determine boot partition location
BOOT_CONFIG="/boot/config.txt"
BOOT_CMDLINE="/boot/cmdline.txt"
if [ -f /boot/firmware/config.txt ]; then
    BOOT_CONFIG="/boot/firmware/config.txt"
    BOOT_CMDLINE="/boot/firmware/cmdline.txt"
fi

echo "Step 1: Configuring USB OTG in $BOOT_CONFIG..."
# Backup config.txt
cp "$BOOT_CONFIG" "${BOOT_CONFIG}.backup.$(date +%Y%m%d-%H%M%S)"

# Enable USB OTG
if ! grep -q "dtoverlay=dwc2" "$BOOT_CONFIG"; then
    {
        echo ""
        echo "# PiKVM USB OTG configuration"
        echo "dtoverlay=dwc2,dr_mode=peripheral"
    } >> "$BOOT_CONFIG"
    echo "Added dwc2 overlay to $BOOT_CONFIG"
else
    echo "dwc2 overlay already configured"
fi

echo ""
echo "Step 2: Configuring kernel modules in $BOOT_CMDLINE..."
# Backup cmdline.txt
cp "$BOOT_CMDLINE" "${BOOT_CMDLINE}.backup.$(date +%Y%m%d-%H%M%S)"

# Add modules-load=dwc2 to cmdline if not present
if ! grep -q "modules-load=dwc2" "$BOOT_CMDLINE"; then
    sed -i 's/$/ modules-load=dwc2/' "$BOOT_CMDLINE"
    echo "Added dwc2 module to kernel command line"
else
    echo "dwc2 module already in kernel command line"
fi

echo ""
echo "Step 3: Configuring kernel modules in /etc/modules..."
# Add required modules to /etc/modules
MODULES=(
    "dwc2"
    "libcomposite"
    "g_multi"
)

for module in "${MODULES[@]}"; do
    if ! grep -q "^$module$" /etc/modules; then
        echo "$module" >> /etc/modules
        echo "Added $module to /etc/modules"
    else
        echo "$module already in /etc/modules"
    fi
done

echo ""
echo "Step 4: Creating USB gadget configuration script..."
cat > /usr/local/bin/pikvm-usb-gadget << 'EOF'
#!/bin/bash
# USB Gadget configuration for PiKVM
# This script sets up USB keyboard, mouse, and mass storage emulation

set -e

GADGET_DIR="/sys/kernel/config/usb_gadget/pikvm"

# Clean up any existing gadget
if [ -d "$GADGET_DIR" ]; then
    echo "Removing existing gadget configuration..."
    # Unbind from UDC
    echo "" > "$GADGET_DIR/UDC" 2>/dev/null || true
    # Remove configurations
    rm -rf "$GADGET_DIR/configs/c.1/hid.usb0" 2>/dev/null || true
    rm -rf "$GADGET_DIR/configs/c.1/hid.usb1" 2>/dev/null || true
    rm -rf "$GADGET_DIR/configs/c.1/mass_storage.usb0" 2>/dev/null || true
    rm -rf "$GADGET_DIR/functions/hid.usb0" 2>/dev/null || true
    rm -rf "$GADGET_DIR/functions/hid.usb1" 2>/dev/null || true
    rm -rf "$GADGET_DIR/functions/mass_storage.usb0" 2>/dev/null || true
    rm -rf "$GADGET_DIR/configs/c.1/strings/0x409" 2>/dev/null || true
    rm -rf "$GADGET_DIR/configs/c.1" 2>/dev/null || true
    rm -rf "$GADGET_DIR/strings/0x409" 2>/dev/null || true
    rmdir "$GADGET_DIR" 2>/dev/null || true
fi

# Create gadget
mkdir -p "$GADGET_DIR"
cd "$GADGET_DIR"

# Set vendor and product IDs
echo 0x1d6b > idVendor  # Linux Foundation
echo 0x0104 > idProduct # Multifunction Composite Gadget
echo 0x0100 > bcdDevice # v1.0.0
echo 0x0200 > bcdUSB    # USB 2.0

# Set device strings
mkdir -p strings/0x409
echo "PiKVM" > strings/0x409/manufacturer
echo "Composite KVM Device" > strings/0x409/product
echo "$(cat /proc/cpuinfo | grep Serial | cut -d' ' -f2)" > strings/0x409/serialnumber

# Create configuration
mkdir -p configs/c.1
mkdir -p configs/c.1/strings/0x409
echo "Config 1: Keyboard + Mouse + Mass Storage" > configs/c.1/strings/0x409/configuration
echo 250 > configs/c.1/MaxPower

# Create HID keyboard function
mkdir -p functions/hid.usb0
echo 1 > functions/hid.usb0/protocol       # Keyboard
echo 1 > functions/hid.usb0/subclass       # Boot interface
echo 8 > functions/hid.usb0/report_length  # 8-byte reports
# HID descriptor for keyboard
echo -ne "\x05\x01\x09\x06\xa1\x01\x05\x07\x19\xe0\x29\xe7\x15\x00\x25\x01\x75\x01\x95\x08\x81\x02\x95\x01\x75\x08\x81\x03\x95\x05\x75\x01\x05\x08\x19\x01\x29\x05\x91\x02\x95\x01\x75\x03\x91\x03\x95\x06\x75\x08\x15\x00\x25\x65\x05\x07\x19\x00\x29\x65\x81\x00\xc0" > functions/hid.usb0/report_desc

# Create HID mouse function
mkdir -p functions/hid.usb1
echo 2 > functions/hid.usb1/protocol       # Mouse
echo 1 > functions/hid.usb1/subclass       # Boot interface
echo 4 > functions/hid.usb1/report_length  # 4-byte reports
# HID descriptor for mouse
echo -ne "\x05\x01\x09\x02\xa1\x01\x09\x01\xa1\x00\x05\x09\x19\x01\x29\x03\x15\x00\x25\x01\x95\x03\x75\x01\x81\x02\x95\x01\x75\x05\x81\x03\x05\x01\x09\x30\x09\x31\x15\x81\x25\x7f\x75\x08\x95\x02\x81\x06\xc0\xc0" > functions/hid.usb1/report_desc

# Create mass storage function
mkdir -p functions/mass_storage.usb0
mkdir -p /var/lib/kvmd/msd
# Create a 1GB virtual disk image if it doesn't exist
if [ ! -f /var/lib/kvmd/msd/virtual.img ]; then
    dd if=/dev/zero of=/var/lib/kvmd/msd/virtual.img bs=1M count=1024 2>/dev/null
    mkfs.vfat /var/lib/kvmd/msd/virtual.img
fi
echo 1 > functions/mass_storage.usb0/stall
echo 0 > functions/mass_storage.usb0/lun.0/cdrom
echo 0 > functions/mass_storage.usb0/lun.0/ro
echo 0 > functions/mass_storage.usb0/lun.0/nofua
echo "/var/lib/kvmd/msd/virtual.img" > functions/mass_storage.usb0/lun.0/file

# Link functions to configuration
ln -s functions/hid.usb0 configs/c.1/
ln -s functions/hid.usb1 configs/c.1/
ln -s functions/mass_storage.usb0 configs/c.1/

# Find and enable UDC
UDC=$(ls /sys/class/udc | head -n1)
if [ -n "$UDC" ]; then
    echo "$UDC" > UDC
    echo "USB gadget configured successfully using $UDC"
else
    echo "Error: No UDC found"
    exit 1
fi
EOF

chmod +x /usr/local/bin/pikvm-usb-gadget

echo ""
echo "Step 5: Creating systemd service for USB gadget..."
cat > /etc/systemd/system/pikvm-usb-gadget.service << 'EOF'
[Unit]
Description=PiKVM USB Gadget Configuration
After=local-fs.target
Before=kvmd.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/bin/pikvm-usb-gadget

[Install]
WantedBy=multi-user.target
EOF

echo ""
echo "Step 6: Enabling services..."
systemctl daemon-reload
systemctl enable pikvm-usb-gadget.service

echo ""
echo "Step 7: Configuring user permissions..."
# Add kvmd user to necessary groups
usermod -a -G video,gpio,i2c,spi kvmd 2>/dev/null || echo "Some groups may not exist, continuing..."

echo ""
echo "================================"
echo "System configuration complete!"
echo "================================"
echo ""
echo "Configuration details:"
echo "  USB Gadget script: /usr/local/bin/pikvm-usb-gadget"
echo "  USB Gadget service: /etc/systemd/system/pikvm-usb-gadget.service"
echo "  Boot config: $BOOT_CONFIG (backed up)"
echo "  Cmdline config: $BOOT_CMDLINE (backed up)"
echo ""
echo "IMPORTANT: You must reboot for USB OTG changes to take effect!"
echo ""
echo "After reboot, enable and start services:"
echo "  sudo systemctl enable ustreamer kvmd nginx"
echo "  sudo systemctl start ustreamer kvmd nginx"
