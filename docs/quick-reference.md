# Quick Reference Guide

Quick commands and references for PiKVM Debian.

## Installation (One Command)

```bash
sudo ./scripts/install-all.sh
```

## Service Management

### Start Services
```bash
sudo systemctl start pikvm-usb-gadget
sudo systemctl start ustreamer
sudo systemctl start kvmd
sudo systemctl start nginx
```

### Stop Services
```bash
sudo systemctl stop kvmd
sudo systemctl stop ustreamer
sudo systemctl stop nginx
```

### Restart Services
```bash
sudo systemctl restart kvmd
```

### Enable Services (start on boot)
```bash
sudo systemctl enable pikvm-usb-gadget ustreamer kvmd nginx
```

### Check Service Status
```bash
sudo systemctl status kvmd
sudo systemctl status ustreamer
sudo systemctl status nginx
sudo systemctl status pikvm-usb-gadget
```

## Logs

### View Live Logs
```bash
# All services
sudo journalctl -f -u pikvm-usb-gadget -u ustreamer -u kvmd -u nginx

# Individual service
sudo journalctl -u kvmd -f
```

### View Recent Logs
```bash
sudo journalctl -u kvmd -n 100
```

### View Logs Since Boot
```bash
sudo journalctl -u kvmd -b
```

## Configuration Files

### Main Configuration
- `/etc/kvmd/main.yaml` - Main kvmd config
- `/etc/kvmd/override.yaml` - User overrides (create this)

### Service Files
- `/etc/systemd/system/kvmd.service`
- `/etc/systemd/system/ustreamer.service`
- `/etc/systemd/system/pikvm-usb-gadget.service`

### Nginx
- `/etc/nginx/sites-available/kvmd`
- `/etc/nginx/sites-enabled/kvmd`

### USB Gadget
- `/usr/local/bin/pikvm-usb-gadget` - USB gadget setup script

## Hardware Verification

### Check Video Device
```bash
ls -la /dev/video*
v4l2-ctl --list-devices
v4l2-ctl -d /dev/video0 --all
```

### Check USB Gadget
```bash
ls -la /sys/kernel/config/usb_gadget/pikvm/
ls /sys/class/udc/
```

### Check GPIO
```bash
ls /dev/gpiochip*
gpiodetect
```

## Testing

### Test Video Stream
```bash
# Direct access to ustreamer
curl http://localhost:8080/snapshot
```

### Test kvmd API
```bash
curl http://localhost:8081/api/info
```

### Test Web Interface
```bash
curl http://localhost/
```

## Troubleshooting Commands

### System Resources
```bash
# CPU and memory
htop

# Temperature
vcgencmd measure_temp

# Throttling
vcgencmd get_throttled

# Disk space
df -h
```

### Network
```bash
# Show IP address
hostname -I

# Check listening ports
sudo netstat -tlnp

# Check specific port
sudo netstat -tlnp | grep 8081
```

### Kernel Modules
```bash
# List loaded modules
lsmod | grep dwc2
lsmod | grep libcomposite

# Load module
sudo modprobe dwc2

# Module info
modinfo dwc2
```

### USB Devices (on target computer)
```bash
# Linux
lsusb
dmesg | grep usb

# Windows
# Check Device Manager
```

## Updating

### Update Scripts
```bash
cd /path/to/pikvm-debian
git pull
```

### Update kvmd
```bash
cd /tmp/pikvm-build/kvmd
git pull
sudo pip3 install --break-system-packages -e .
sudo systemctl restart kvmd
```

### Update ustreamer
```bash
cd /tmp/pikvm-build/ustreamer
git pull
make clean
make
sudo make install
sudo systemctl restart ustreamer
```

## Backup Configuration

```bash
# Backup configs
sudo tar czf pikvm-config-backup-$(date +%Y%m%d).tar.gz \
    /etc/kvmd \
    /etc/nginx/sites-available/kvmd \
    /etc/systemd/system/kvmd.service \
    /etc/systemd/system/ustreamer.service \
    /usr/local/bin/pikvm-usb-gadget
```

## Restore Configuration

```bash
# Restore from backup
sudo tar xzf pikvm-config-backup-*.tar.gz -C /
sudo systemctl daemon-reload
sudo systemctl restart kvmd nginx ustreamer
```

## Uninstallation

```bash
# Stop and disable services
sudo systemctl stop kvmd ustreamer nginx pikvm-usb-gadget
sudo systemctl disable kvmd ustreamer pikvm-usb-gadget

# Remove services
sudo rm /etc/systemd/system/kvmd.service
sudo rm /etc/systemd/system/ustreamer.service
sudo rm /etc/systemd/system/pikvm-usb-gadget.service
sudo systemctl daemon-reload

# Remove files
sudo rm -rf /etc/kvmd
sudo rm -rf /var/lib/kvmd
sudo rm -rf /var/log/kvmd
sudo rm /usr/local/bin/ustreamer
sudo rm /usr/local/bin/pikvm-usb-gadget
sudo rm /etc/nginx/sites-available/kvmd
sudo rm /etc/nginx/sites-enabled/kvmd

# Remove user
sudo userdel kvmd

# Revert boot configuration
sudo nano /boot/config.txt  # Remove dwc2 overlay
sudo nano /boot/cmdline.txt # Remove modules-load=dwc2
sudo nano /etc/modules      # Remove dwc2, libcomposite, g_multi
```

## Performance Tuning

### Reduce Video Latency
Edit ustreamer service:
```bash
sudo nano /etc/systemd/system/ustreamer.service
```

Add flags:
```
--drop-same-frames=30
--workers=4
--quality=80
```

### Adjust kvmd Settings
Create override config:
```bash
sudo nano /etc/kvmd/override.yaml
```

```yaml
kvmd:
    streamer:
        quality: 80
        resolution:
            width: 1920
            height: 1080
```

Restart services:
```bash
sudo systemctl restart kvmd ustreamer
```

## Security

### Change Default Password
```bash
# If using basic auth
sudo htpasswd /etc/kvmd/htpasswd admin
```

### Enable HTTPS
```bash
# Generate self-signed certificate
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/pikvm.key \
    -out /etc/nginx/ssl/pikvm.crt

# Update nginx config for SSL
sudo nano /etc/nginx/sites-available/kvmd
```

### Firewall
```bash
# Allow only necessary ports
sudo ufw allow 22/tcp  # SSH
sudo ufw allow 80/tcp  # HTTP
sudo ufw allow 443/tcp # HTTPS (if configured)
sudo ufw enable
```

## Useful Aliases

Add to `~/.bashrc`:

```bash
alias pikvm-status='sudo systemctl status pikvm-usb-gadget ustreamer kvmd nginx'
alias pikvm-logs='sudo journalctl -f -u pikvm-usb-gadget -u ustreamer -u kvmd -u nginx'
alias pikvm-restart='sudo systemctl restart kvmd ustreamer nginx'
alias pikvm-temp='vcgencmd measure_temp'
```

## Web Interface Default Access

- URL: `http://<raspberry-pi-ip>/`
- Configure authentication in kvmd config

## Common File Locations

| Item | Location |
|------|----------|
| Configuration | `/etc/kvmd/` |
| Data | `/var/lib/kvmd/` |
| Logs | `/var/log/kvmd/` |
| Virtual media | `/var/lib/kvmd/msd/` |
| ustreamer binary | `/usr/local/bin/ustreamer` |
| kvmd binary | `/usr/local/bin/kvmd` |
| USB gadget script | `/usr/local/bin/pikvm-usb-gadget` |
