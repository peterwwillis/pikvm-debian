# PiKVM for Raspberry Pi OS (Debian)

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

## Installation

(To be implemented)

```bash
# Basic installation flow
sudo ./scripts/install-packages.sh
sudo ./scripts/configure-system.sh
sudo ./scripts/setup-services.sh
```

## Differences from Original PiKVM

- Uses Debian packages instead of Arch packages
- Simplified installation process
- Focuses on core KVM functionality
- Built for Raspberry Pi OS (Debian-based)

## Development Status

This project is currently under development. See the implementation checklist for current progress.

## License

This project builds upon PiKVM, which is licensed under GPLv3. This derivative work maintains the same license.

## References

- [Original PiKVM Project](https://github.com/pikvm)
- [PiKVM Documentation](https://docs.pikvm.org/)
- [kvmd Repository](https://github.com/pikvm/kvmd)
- [ustreamer Repository](https://github.com/pikvm/ustreamer)
