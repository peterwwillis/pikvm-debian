#!/bin/bash
# Build ustreamer from source for PiKVM
# ustreamer is a lightweight MJPEG-HTTP streamer optimized for low latency

set -e

echo "================================"
echo "Building ustreamer"
echo "================================"
echo ""

# Configuration
USTREAMER_REPO="https://github.com/pikvm/ustreamer.git"
BUILD_DIR="/tmp/pikvm-build"
INSTALL_PREFIX="/usr/local"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

echo "Step 1: Creating build directory..."
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo ""
echo "Step 2: Cloning ustreamer repository..."
if [ -d "ustreamer" ]; then
    echo "Removing existing ustreamer directory..."
    rm -rf ustreamer
fi
git clone --depth 1 "$USTREAMER_REPO"
cd ustreamer

echo ""
echo "Step 3: Building ustreamer..."
make

echo ""
echo "Step 4: Installing ustreamer to $INSTALL_PREFIX..."
make install PREFIX="$INSTALL_PREFIX"

echo ""
echo "Step 5: Creating systemd service..."
cat > /etc/systemd/system/ustreamer.service << 'EOF'
[Unit]
Description=ustreamer - Lightweight MJPEG-HTTP streamer
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/ustreamer \
    --device=/dev/video0 \
    --host=127.0.0.1 \
    --port=8080 \
    --format=MJPEG \
    --encoder=HW \
    --persistent \
    --drop-same-frames=30
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

echo ""
echo "Step 6: Reloading systemd..."
systemctl daemon-reload

echo ""
echo "================================"
echo "ustreamer build complete!"
echo "================================"
echo ""
echo "Installation details:"
echo "  Binary: $INSTALL_PREFIX/bin/ustreamer"
echo "  Service: /etc/systemd/system/ustreamer.service"
echo ""
echo "Note: Service is not enabled by default."
echo "To enable and start:"
echo "  sudo systemctl enable ustreamer"
echo "  sudo systemctl start ustreamer"
echo ""
echo "Note: The service expects /dev/video0 to exist."
echo "Make sure your HDMI capture device is connected."
