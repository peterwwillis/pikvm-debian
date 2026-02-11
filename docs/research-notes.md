# PiKVM Research Notes

## Architecture Overview

### Core Components

1. **kvmd (PiKVM Daemon)**
   - Central orchestration daemon written in Python
   - Manages hardware connections (HDMI capture, USB emulation, GPIO)
   - Provides REST API and WebSocket interfaces
   - Plugin-based architecture for different hardware configurations
   - Handles virtual media (mass storage device emulation)
   - Manages ATX power control via GPIO
   
2. **ustreamer**
   - Lightweight MJPEG-HTTP video streamer
   - Captures video from V4L2 devices (HDMI capture)
   - Optimized for low latency
   - Written in C for performance
   - Repository: https://github.com/pikvm/ustreamer

3. **Web Frontend**
   - Browser-based KVM interface
   - Communicates with kvmd via REST API and WebSockets
   - Provides keyboard/mouse control, video display, virtual media management

4. **nginx**
   - Web server for hosting the UI
   - Reverse proxy for kvmd API
   - SSL/TLS termination

### System Dependencies

#### Debian System Packages
```
python3 (>=3.8)
python3-pip
python3-setuptools
nginx
dnsmasq
iptables
iproute2
v4l-utils
```

#### Python Dependencies
```
aiohttp - Async HTTP server/client
aiofiles - Async file operations
passlib - Password hashing
pyotp - TOTP/two-factor auth
python-pam - PAM authentication
periphery - GPIO/I2C/SPI/Serial access
pyserial - Serial port access
spidev - SPI interface
libgpiod - GPIO access
async-lru - Async caching (Debian 12+)
```

### Hardware Requirements

- **Raspberry Pi 4B** (recommended for performance)
- **HDMI to CSI-2 bridge** (e.g., TC358743-based)
  - Connects host computer's HDMI output to Pi's camera interface
  - Provides V4L2 device for video capture
- **USB connection** from Pi to host for KVM emulation
- **MicroSD card** (16GB minimum, 32GB recommended)
- **Power supply** for Pi (independent from host)
- **Optional:** GPIO connections for ATX power control

### Video Capture

- Uses V4L2 (Video4Linux2) framework
- HDMI capture device appears as `/dev/video0` (or similar)
- ustreamer reads from V4L2 device and streams MJPEG
- kvmd serves the video stream to web UI

### USB Emulation

PiKVM uses USB OTG functionality to emulate:
- **Keyboard** (USB HID)
- **Mouse** (USB HID)
- **Mass Storage** (USB MSD for virtual media)
- **Serial console** (optional, USB CDC ACM)

Configuration typically done via:
- `/boot/config.txt` - Enable dwc2 USB OTG
- `/boot/cmdline.txt` - USB gadget modules
- `/etc/modules` - Load required kernel modules

### Key Configuration Files

Based on PiKVM architecture:
```
/etc/kvmd/main.yaml - Main kvmd configuration
/etc/kvmd/override.yaml - User overrides
/etc/nginx/nginx.conf - Web server config
/etc/systemd/system/kvmd.service - kvmd service
/etc/systemd/system/kvmd-nginx.service - nginx service
/etc/systemd/system/ustreamer.service - video streaming service
```

### Build Requirements

#### For ustreamer (from source)
```
build-essential
libevent-dev
libjpeg-dev
libbsd-dev
```

#### For kvmd (from source)
```
python3-dev
python3-setuptools
python3-wheel
```

### Installation Strategy

1. **Phase 1: System Preparation**
   - Update system packages
   - Install base dependencies
   - Configure USB OTG

2. **Phase 2: Build Custom Packages**
   - Build ustreamer from source
   - Install kvmd and dependencies
   - Build any other required components

3. **Phase 3: System Configuration**
   - Configure kvmd
   - Set up nginx
   - Configure video capture
   - Set up systemd services

4. **Phase 4: Testing & Validation**
   - Test video streaming
   - Test keyboard/mouse emulation
   - Test virtual media
   - Test web UI

## References

- [PiKVM GitHub Organization](https://github.com/pikvm)
- [kvmd Repository](https://github.com/pikvm/kvmd)
- [ustreamer Repository](https://github.com/pikvm/ustreamer)
- [PiKVM Packages](https://github.com/pikvm/packages)
- [kvmd-debian port](https://github.com/hzyitc/kvmd-debian)
- [PiKVM Documentation](https://docs.pikvm.org/)
