# Troubleshooting Guide

Common issues and solutions when running PiKVM on Raspberry Pi OS (Debian).

## General Debugging

### Check All Service Status

```bash
sudo systemctl status pikvm-usb-gadget
sudo systemctl status ustreamer
sudo systemctl status kvmd
sudo systemctl status nginx
```

### View Live Logs

```bash
# All PiKVM-related services
sudo journalctl -f -u pikvm-usb-gadget -u ustreamer -u kvmd -u nginx

# Individual services
sudo journalctl -u ustreamer -f
sudo journalctl -u kvmd -f
```

## USB Gadget Issues

### Problem: USB gadget not detected by target computer

**Symptoms:**
- Target computer doesn't recognize keyboard/mouse
- No USB device appears in target computer's device manager

**Solutions:**

1. Check if USB gadget service is running:
   ```bash
   sudo systemctl status pikvm-usb-gadget
   ```

2. Verify USB OTG configuration in boot config:
   ```bash
   grep dwc2 /boot/config.txt
   grep dwc2 /boot/cmdline.txt
   ```

3. Check if gadget is configured:
   ```bash
   ls -la /sys/kernel/config/usb_gadget/pikvm/
   ```

4. Check if UDC is available:
   ```bash
   ls /sys/class/udc/
   ```

5. Manually run the gadget script:
   ```bash
   sudo /usr/local/bin/pikvm-usb-gadget
   ```

6. Check kernel modules:
   ```bash
   lsmod | grep dwc2
   lsmod | grep libcomposite
   ```

7. Reload modules if needed:
   ```bash
   sudo modprobe dwc2
   sudo modprobe libcomposite
   ```

### Problem: USB gadget script fails

**Error:** "No UDC found"

**Solution:**
- This usually means USB OTG is not properly enabled
- Verify `/boot/config.txt` has `dtoverlay=dwc2,dr_mode=peripheral`
- Verify `/boot/cmdline.txt` has `modules-load=dwc2`
- Reboot is required after changing boot configuration
- Check if running on actual Raspberry Pi hardware (won't work in VM)

## Video Streaming Issues

### Problem: No video stream / black screen

**Symptoms:**
- Web interface loads but video area is black
- ustreamer service fails to start

**Solutions:**

1. Check if video device exists:
   ```bash
   ls -la /dev/video*
   ```

2. List available video devices:
   ```bash
   v4l2-ctl --list-devices
   ```

3. Check device capabilities:
   ```bash
   v4l2-ctl -d /dev/video0 --all
   ```

4. Test video capture manually:
   ```bash
   v4l2-ctl -d /dev/video0 --set-fmt-video=width=1920,height=1080
   ```

5. Check ustreamer logs:
   ```bash
   sudo journalctl -u ustreamer -f
   ```

6. Try running ustreamer manually:
   ```bash
   sudo /usr/local/bin/ustreamer --device=/dev/video0 --host=127.0.0.1 --port=8080
   ```

7. Verify HDMI capture device is properly connected to CSI-2 port

8. Check if CSI camera interface is enabled:
   ```bash
   grep camera /boot/config.txt
   ```

### Problem: Video device not detected

**Solution:**
- Ensure HDMI capture board is properly seated in CSI-2 connector
- Check if target computer is outputting HDMI signal
- Some capture devices require specific dtoverlay in `/boot/config.txt`
- For TC358743-based devices, you may need:
  ```
  dtoverlay=tc358743
  ```

## kvmd Service Issues

### Problem: kvmd fails to start

**Solutions:**

1. Check kvmd logs:
   ```bash
   sudo journalctl -u kvmd -f
   ```

2. Verify configuration files:
   ```bash
   ls -la /etc/kvmd/
   ```

3. Check kvmd user and permissions:
   ```bash
   id kvmd
   ls -la /var/lib/kvmd/
   ls -la /var/log/kvmd/
   ```

4. Test kvmd manually:
   ```bash
   sudo -u kvmd /usr/local/bin/kvmd
   ```

5. Verify Python dependencies:
   ```bash
   pip3 list | grep aio
   ```

6. Check if ports are available:
   ```bash
   sudo netstat -tlnp | grep 8081
   ```

### Problem: kvmd starts but can't communicate with hardware

**Solutions:**

1. Check user group memberships:
   ```bash
   groups kvmd
   ```

2. Add kvmd to necessary groups:
   ```bash
   sudo usermod -a -G video,gpio,i2c,spi kvmd
   sudo systemctl restart kvmd
   ```

3. Check device permissions:
   ```bash
   ls -la /dev/video*
   ls -la /dev/gpiochip*
   ```

## Web Interface Issues

### Problem: Cannot access web interface

**Symptoms:**
- Browser can't connect to Raspberry Pi IP
- Connection refused or timeout

**Solutions:**

1. Check nginx status:
   ```bash
   sudo systemctl status nginx
   ```

2. Test nginx configuration:
   ```bash
   sudo nginx -t
   ```

3. Check if nginx is listening:
   ```bash
   sudo netstat -tlnp | grep nginx
   ```

4. Verify nginx site is enabled:
   ```bash
   ls -la /etc/nginx/sites-enabled/
   ```

5. Check nginx logs:
   ```bash
   sudo tail -f /var/log/nginx/error.log
   sudo tail -f /var/log/nginx/access.log
   ```

6. Verify firewall settings:
   ```bash
   sudo iptables -L -n
   ```

7. Try accessing directly:
   ```bash
   curl http://localhost/
   ```

### Problem: Web interface loads but features don't work

**Solutions:**

1. Check browser console for JavaScript errors (F12 in most browsers)

2. Verify all services are running:
   ```bash
   sudo systemctl status kvmd ustreamer nginx
   ```

3. Check API connectivity:
   ```bash
   curl http://localhost:8081/api/info
   ```

4. Verify WebSocket connections are working (check browser console)

## Mass Storage Device Issues

### Problem: Virtual media not working

**Solutions:**

1. Check if mass storage image exists:
   ```bash
   ls -la /var/lib/kvmd/msd/
   ```

2. Verify USB gadget includes mass storage:
   ```bash
   ls -la /sys/kernel/config/usb_gadget/pikvm/functions/
   ```

3. Check mass storage configuration:
   ```bash
   cat /sys/kernel/config/usb_gadget/pikvm/functions/mass_storage.usb0/lun.0/file
   ```

4. Manually mount/unmount:
   ```bash
   echo "/path/to/image.iso" | sudo tee /sys/kernel/config/usb_gadget/pikvm/functions/mass_storage.usb0/lun.0/file
   ```

## Performance Issues

### Problem: Video streaming is laggy

**Solutions:**

1. Check CPU usage:
   ```bash
   htop
   ```

2. Check network bandwidth

3. Lower video resolution in ustreamer config

4. Ensure you're using hardware encoding:
   ```bash
   sudo systemctl status ustreamer
   # Should see --encoder=HW in command line
   ```

5. Check for thermal throttling:
   ```bash
   vcgencmd measure_temp
   vcgencmd get_throttled
   ```

### Problem: High CPU usage

**Solutions:**

1. Ensure hardware encoding is enabled in ustreamer

2. Reduce video quality/resolution

3. Check for runaway processes:
   ```bash
   top
   ```

4. Ensure proper cooling (add heatsink/fan if needed)

## Installation Issues

### Problem: Script fails with permission error

**Solution:**
- Ensure you're running scripts with sudo:
  ```bash
  sudo ./scripts/install-all.sh
  ```

### Problem: Package installation fails

**Solutions:**

1. Update package cache:
   ```bash
   sudo apt update
   ```

2. Fix broken dependencies:
   ```bash
   sudo apt --fix-broken install
   ```

3. Check available disk space:
   ```bash
   df -h
   ```

### Problem: Build fails during compilation

**Solutions:**

1. Ensure all build dependencies are installed:
   ```bash
   sudo apt install build-essential
   ```

2. Check for error messages in build output

3. Ensure you have enough disk space

4. Try cleaning and rebuilding:
   ```bash
   cd /tmp/pikvm-build/ustreamer
   make clean
   make
   ```

## Hardware-Specific Issues

### Raspberry Pi 4 USB-C Power

- If using USB-C port for both power and data, use a powered USB hub
- Alternatively, use separate power supply and USB-A port for data

### HDMI Capture Device Compatibility

- Not all HDMI capture devices work with Raspberry Pi
- Recommended: TC358743-based devices (Auvidea B101, etc.)
- Some cheap USB capture devices won't work for this purpose

### GPIO for ATX Control

- Not implemented in basic installation
- Requires additional configuration and wiring
- See PiKVM documentation for GPIO setup

## Getting More Help

1. Check system logs:
   ```bash
   sudo journalctl -xe
   ```

2. Check dmesg for hardware issues:
   ```bash
   sudo dmesg | tail -50
   ```

3. Review PiKVM official documentation: https://docs.pikvm.org/

4. Check GitHub issues for similar problems

5. Provide detailed information when asking for help:
   - Hardware setup (Pi model, capture device)
   - Software versions
   - Complete error messages
   - Relevant log outputs
