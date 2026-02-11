# Installation Guide - PiKVM on Raspberry Pi OS (Debian)

This guide walks you through installing PiKVM on Raspberry Pi OS (Debian-based) for Raspberry Pi 4B.

## Prerequisites

### Hardware
- Raspberry Pi 4B (4GB or 8GB RAM recommended)
- MicroSD card (16GB minimum, 32GB recommended)
- HDMI to CSI-2 capture device (e.g., TC358743-based board like Auvidea B101 or similar)
- USB-C cable for Pi power
- USB cable for connecting Pi to target computer
- Ethernet cable or WiFi for network connectivity
- Optional: GPIO connections for ATX power control

### Software
- Raspberry Pi OS (64-bit, Debian Bookworm or newer)
- Basic familiarity with Linux command line

## Installation Steps

### 1. Prepare Raspberry Pi OS

Flash Raspberry Pi OS to your MicroSD card using Raspberry Pi Imager:
1. Download and install [Raspberry Pi Imager](https://www.raspberrypi.com/software/)
2. Select "Raspberry Pi OS (64-bit)" under Operating System
3. Select your MicroSD card
4. Configure settings (hostname, SSH, WiFi if needed)
5. Write the image to the card

Boot the Raspberry Pi and ensure it's connected to the network.

### 2. Update System

```bash
sudo apt update
sudo apt upgrade -y
```

### 3. Clone This Repository

```bash
git clone https://github.com/peterwwillis/pikvm-debian.git
cd pikvm-debian
```

### 4. Install System Packages

Run the package installation script:

```bash
sudo ./scripts/install-packages.sh
```

This installs:
- Base system packages (nginx, python3, etc.)
- Python dependencies for kvmd
- Build tools for compiling ustreamer
- Video4Linux utilities

### 5. Build ustreamer

Build the video streaming component:

```bash
sudo ./scripts/build-ustreamer.sh
```

This will:
- Clone the ustreamer repository
- Compile it from source
- Install the binary to `/usr/local/bin/`
- Create a systemd service

### 6. Install kvmd

Install the main PiKVM daemon:

```bash
sudo ./scripts/install-kvmd.sh
```

This will:
- Clone the kvmd repository
- Install it via pip
- Create necessary directories and users
- Set up systemd services
- Configure nginx

### 7. Configure System for USB OTG

Configure the Raspberry Pi for USB gadget mode:

```bash
sudo ./scripts/configure-system.sh
```

This will:
- Enable USB OTG in boot configuration
- Set up kernel modules
- Create USB gadget configuration script
- Set up systemd service for USB gadget

**Important:** You must reboot after this step!

```bash
sudo reboot
```

### 8. Connect Hardware

After reboot:

1. **Connect HDMI capture device:**
   - Connect your HDMI capture board to the Raspberry Pi's CSI-2 camera port
   - Connect the HDMI input of the capture board to the target computer's HDMI output

2. **Connect USB:**
   - Connect a USB cable from the Raspberry Pi's USB-C port (or USB-A if not using it for power) to the target computer
   - This provides keyboard/mouse emulation

3. **Verify video device:**
   ```bash
   ls -la /dev/video*
   v4l2-ctl --list-devices
   ```
   You should see your HDMI capture device listed

### 9. Enable and Start Services

```bash
sudo systemctl enable pikvm-usb-gadget ustreamer kvmd nginx
sudo systemctl start pikvm-usb-gadget ustreamer kvmd nginx
```

### 10. Check Service Status

Verify all services are running:

```bash
sudo systemctl status pikvm-usb-gadget
sudo systemctl status ustreamer
sudo systemctl status kvmd
sudo systemctl status nginx
```

### 11. Access Web Interface

Open a web browser and navigate to:
- `http://<raspberry-pi-ip>/`
- Default credentials (if configured): admin/admin

## Troubleshooting

### Video Stream Not Working

Check if the capture device is detected:
```bash
v4l2-ctl --list-devices
```

Check ustreamer logs:
```bash
sudo journalctl -u ustreamer -f
```

### USB Gadget Not Working

Check if USB gadget is configured:
```bash
ls /sys/kernel/config/usb_gadget/pikvm/
```

Check gadget service logs:
```bash
sudo journalctl -u pikvm-usb-gadget -f
```

Manually run the USB gadget script:
```bash
sudo /usr/local/bin/pikvm-usb-gadget
```

### kvmd Not Starting

Check kvmd logs:
```bash
sudo journalctl -u kvmd -f
```

Check configuration:
```bash
ls -la /etc/kvmd/
```

### Nginx Not Working

Check nginx status:
```bash
sudo nginx -t
sudo systemctl status nginx
```

View nginx error logs:
```bash
sudo tail -f /var/log/nginx/error.log
```

## Configuration

### Main Configuration Files

- `/etc/kvmd/main.yaml` - Main kvmd configuration
- `/etc/kvmd/override.yaml` - User overrides (create this for custom settings)
- `/etc/nginx/sites-available/kvmd` - Nginx configuration
- `/usr/local/bin/pikvm-usb-gadget` - USB gadget setup script

### Customizing kvmd

Create an override configuration file:
```bash
sudo nano /etc/kvmd/override.yaml
```

Example override:
```yaml
kvmd:
    server:
        host: 0.0.0.0
        port: 8081
    
    streamer:
        host: 127.0.0.1
        port: 8080
```

Restart kvmd after changes:
```bash
sudo systemctl restart kvmd
```

## Next Steps

1. Set up HTTPS with Let's Encrypt or self-signed certificates
2. Configure ATX power control via GPIO
3. Set up authentication and user management
4. Configure virtual media (mass storage device)
5. Set up monitoring and logging

## Security Considerations

- Change default passwords immediately
- Enable HTTPS for production use
- Use firewall rules to restrict access
- Keep system and packages updated
- Consider using VPN for remote access

## Support

For issues and questions:
- Check the [troubleshooting section](#troubleshooting)
- Review logs with `journalctl`
- Refer to [PiKVM documentation](https://docs.pikvm.org/) for general concepts
- Open an issue on GitHub

## License

This project is licensed under GPLv3, same as the original PiKVM project.
