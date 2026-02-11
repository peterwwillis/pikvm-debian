#!/bin/bash
# PiKVM Debian - Package Installation Script
# This script installs all required system packages for PiKVM on Raspberry Pi OS (Debian)

set -e  # Exit on error

echo "================================"
echo "PiKVM Debian Package Installation"
echo "================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Check architecture
ARCH=$(uname -m)
echo "Detected architecture: $ARCH"
if [[ "$ARCH" != "aarch64" && "$ARCH" != "armv7l" && "$ARCH" != "arm64" ]]; then
    echo "Warning: This script is designed for ARM architecture (Raspberry Pi)"
    echo "Detected: $ARCH"
    echo "Continue anyway? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo ""
echo "Step 1: Updating system packages..."
apt-get update
apt-get upgrade -y

echo ""
echo "Step 2: Installing base system packages..."
apt-get install -y \
    build-essential \
    git \
    sudo \
    nginx \
    dnsmasq \
    iptables \
    iproute2 \
    v4l-utils \
    python3 \
    python3-pip \
    python3-dev \
    python3-setuptools \
    python3-wheel

echo ""
echo "Step 3: Installing Python packages for kvmd..."
apt-get install -y \
    python3-aiohttp \
    python3-aiofiles \
    python3-passlib \
    python3-pyotp \
    python3-pam \
    python3-periphery \
    python3-serial \
    python3-spidev \
    python3-libgpiod

# Check Debian version for additional packages
DEBIAN_VERSION=$(cut -d. -f1 < /etc/debian_version)
if [ "$DEBIAN_VERSION" -ge 12 ]; then
    echo ""
    echo "Step 4: Installing additional packages for Debian 12+..."
    apt-get install -y python3-async-lru || echo "python3-async-lru not available, will install via pip"
fi

echo ""
echo "Step 5: Installing build dependencies for ustreamer..."
apt-get install -y \
    libevent-dev \
    libjpeg-dev \
    libbsd-dev

echo ""
echo "Step 6: Installing additional utilities..."
apt-get install -y \
    htop \
    vim \
    nano \
    curl \
    wget

echo ""
echo "================================"
echo "Package installation complete!"
echo "================================"
echo ""
echo "Next steps:"
echo "  1. Run ./scripts/build-ustreamer.sh to build the video streamer"
echo "  2. Run ./scripts/install-kvmd.sh to install the PiKVM daemon"
echo "  3. Run ./scripts/configure-system.sh to configure the system"
