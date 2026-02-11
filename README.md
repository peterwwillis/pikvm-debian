# PiKVM for Raspberry Pi OS (Debian)

[![Build Status](https://github.com/peterwwillis/pikvm-debian/workflows/Build%20and%20Test%20PiKVM%20Debian/badge.svg)](https://github.com/peterwwillis/pikvm-debian/actions)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Platform](https://img.shields.io/badge/platform-Raspberry%20Pi%204B-red.svg)](https://www.raspberrypi.org/)

This project reimplements PiKVM for Raspberry Pi OS (Debian-based) instead of the original Arch Linux implementation.

## Overview

PiKVM is a Raspberry Pi-based KVM (Keyboard, Video, Mouse) over IP solution that allows you to remotely control computers. This project aims to create a simplified, Debian-based installation that works on Raspberry Pi 4B.

## Target Hardware

- Raspberry Pi 4B
- HDMI to CSI-2 capture device (e.g., TC358743-based board)
- MicroSD card (16GB+)
- USB cables for KVM connection
- Optional: GPIO for ATX power control

## Core Components

1. **kvmd** - Main PiKVM daemon that orchestrates all functions
2. **ustreamer** - Lightweight MJPEG-HTTP video streamer for HDMI capture
3. **Web UI** - Browser-based interface for KVM control
4. **nginx** - Web server for serving the UI and APIs

## Project Structure

```
.
├── scripts/           # Installation and configuration scripts
├── docs/              # Documentation and research notes
├── builds/            # Build scripts for custom packages
└── .github/           # GitHub Actions workflows
```

## Quick Start

### One-Command Installation

```bash
git clone https://github.com/peterwwillis/pikvm-debian.git
cd pikvm-debian
sudo ./scripts/install-all.sh
```

### Manual Installation

For step-by-step installation:

```bash
sudo ./scripts/install-packages.sh
sudo ./scripts/build-ustreamer.sh
sudo ./scripts/install-kvmd.sh
sudo ./scripts/configure-system.sh
sudo reboot
```

After reboot, enable and start services:

```bash
sudo systemctl enable pikvm-usb-gadget ustreamer kvmd nginx
sudo systemctl start pikvm-usb-gadget ustreamer kvmd nginx
```

Access the web interface at `http://<raspberry-pi-ip>/`

For detailed instructions, see the [Installation Guide](docs/installation-guide.md).

## Documentation

- **[Installation Guide](docs/installation-guide.md)** - Complete setup instructions
- **[Quick Reference](docs/quick-reference.md)** - Common commands and operations
- **[Troubleshooting](docs/troubleshooting.md)** - Solutions to common problems
- **[Research Notes](docs/research-notes.md)** - Technical background and architecture
- **[Contributing](CONTRIBUTING.md)** - How to contribute to the project
- **[Changelog](CHANGELOG.md)** - Version history and changes

## Features

✅ **Implemented:**
- Video streaming via ustreamer (MJPEG over HTTP)
- Keyboard emulation (USB HID)
- Mouse emulation (USB HID)
- Mass storage device emulation (virtual media)
- Web-based control interface
- systemd service integration
- Automated installation scripts

🚧 **Planned:**
- ATX power control via GPIO
- HTTPS/SSL setup automation
- Enhanced authentication
- Wake-on-LAN support
- VNC server integration
- Additional hardware platform support

## Requirements

### Hardware
- Raspberry Pi 4B (4GB or 8GB RAM recommended)
- HDMI to CSI-2 capture device (e.g., TC358743-based)
- MicroSD card (16GB+)
- USB cables for power and data
- Network connectivity (Ethernet or WiFi)

### Software
- Raspberry Pi OS (64-bit, Debian Bookworm or newer)
- Python 3.8+
- Build tools (automatically installed by scripts)

## Differences from Original PiKVM

This project differs from the official PiKVM in several ways:

- **Base OS:** Uses Raspberry Pi OS (Debian) instead of custom Arch Linux
- **Installation:** Simple shell scripts instead of pre-built OS image
- **Packages:** Uses Debian packages and builds from source where needed
- **Scope:** Focuses on core KVM functionality, simpler setup
- **Audience:** Designed for users familiar with Debian/Raspberry Pi OS

The goal is to provide a more accessible, maintainable alternative for users who prefer Debian-based systems.

## License

This project builds upon PiKVM, which is licensed under GPLv3. This derivative work maintains the same license.

## References

- [Original PiKVM Project](https://github.com/pikvm)
- [PiKVM Documentation](https://docs.pikvm.org/)
- [kvmd Repository](https://github.com/pikvm/kvmd)
- [ustreamer Repository](https://github.com/pikvm/ustreamer)
