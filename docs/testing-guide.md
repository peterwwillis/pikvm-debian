# Testing and Verification Guide

This guide helps you test and verify your PiKVM installation is working correctly.

## Quick Status Check

Run the status check script:

```bash
./scripts/check-status.sh
```

This will show:
- Service status for all components
- Hardware detection
- Network configuration
- Quick access URLs

## Step-by-Step Testing

### 1. Verify Services Are Running

```bash
sudo systemctl status pikvm-usb-gadget
sudo systemctl status ustreamer
sudo systemctl status kvmd
sudo systemctl status nginx
```

All should show "active (running)".

### 2. Test Video Capture

#### Check Video Device

```bash
ls -la /dev/video*
```

Expected output: `/dev/video0` (or similar)

#### List Video Devices

```bash
v4l2-ctl --list-devices
```

Should show your HDMI capture device.

#### Get Video Device Info

```bash
v4l2-ctl -d /dev/video0 --all
```

Should show supported formats and resolutions.

#### Test Video Stream

```bash
# Get a snapshot
curl http://localhost:8080/snapshot -o test-snapshot.jpg

# View in browser (if X11 forwarded)
xdg-open test-snapshot.jpg
```

Or access directly in browser: `http://<pi-ip>:8080/`

### 3. Test USB Gadget

#### Check USB Gadget Configuration

```bash
ls -la /sys/kernel/config/usb_gadget/pikvm/
```

Should show gadget configuration directories.

#### Check Gadget Functions

```bash
ls -la /sys/kernel/config/usb_gadget/pikvm/functions/
```

Expected:
- `hid.usb0` (keyboard)
- `hid.usb1` (mouse)
- `mass_storage.usb0` (virtual media)

#### Check USB Connection (on target computer)

On the target computer, check if USB devices are detected:

**Linux:**
```bash
lsusb | grep "Linux Foundation"
dmesg | tail -20
```

**Windows:**
- Open Device Manager
- Look for "USB Composite Device" or similar
- Check for HID Keyboard Device
- Check for HID-compliant mouse

**macOS:**
```bash
system_profiler SPUSBDataType
```

### 4. Test Web Interface

#### Check Nginx

```bash
sudo nginx -t
curl http://localhost/
```

#### Access Web Interface

Open browser and navigate to:
```
http://<raspberry-pi-ip>/
```

You should see the PiKVM web interface.

### 5. Test Keyboard Emulation

#### Send Keyboard Test via API

```bash
# This requires kvmd API to be running
# Example: Send 'hello' keystrokes
curl -X POST http://localhost:8081/api/hid/keyboard/key \
  -H "Content-Type: application/json" \
  -d '{"key": "h", "state": true}'
```

#### Manual Test via Web UI

1. Access web interface
2. Click in keyboard area
3. Type on your keyboard
4. Keystrokes should appear on target computer

### 6. Test Mouse Emulation

#### Via Web UI

1. Access web interface
2. Move your mouse over video area
3. Click
4. Mouse should move on target computer

### 7. Test Virtual Media (Mass Storage)

#### Check Mass Storage Configuration

```bash
cat /sys/kernel/config/usb_gadget/pikvm/functions/mass_storage.usb0/lun.0/file
```

Should show path to virtual disk image.

#### Mount ISO via Web UI

1. Upload an ISO file via web interface
2. Mount it as virtual CD/DVD
3. Target computer should detect new drive

### 8. Test API Endpoints

```bash
# Get system info
curl http://localhost:8081/api/info

# Get streamer info
curl http://localhost:8081/api/streamer

# Get HID info
curl http://localhost:8081/api/hid
```

## Performance Testing

### Check CPU Usage

```bash
htop
# or
top
```

Look for:
- ustreamer process
- kvmd process
- nginx processes

### Check Temperature

```bash
vcgencmd measure_temp
```

Should be < 70°C under normal operation.

### Check Throttling

```bash
vcgencmd get_throttled
```

`throttled=0x0` means no throttling.

### Check Video Latency

1. Display a timer on target computer
2. View via PiKVM web interface
3. Compare with actual timer
4. Latency should be < 100ms typically

## Network Testing

### Check Listening Ports

```bash
sudo netstat -tlnp | grep -E ':(80|443|8080|8081)'
```

Expected:
- `:80` - nginx
- `:8080` - ustreamer
- `:8081` - kvmd

### Test from Remote Computer

```bash
# From another computer on network
ping <raspberry-pi-ip>
curl http://<raspberry-pi-ip>/
```

## Automated Testing Script

Create a test script:

```bash
#!/bin/bash
# automated-test.sh

echo "Running automated PiKVM tests..."

# Test 1: Services
echo "Test 1: Checking services..."
systemctl is-active --quiet pikvm-usb-gadget && echo "✓ USB Gadget OK" || echo "✗ USB Gadget FAILED"
systemctl is-active --quiet ustreamer && echo "✓ ustreamer OK" || echo "✗ ustreamer FAILED"
systemctl is-active --quiet kvmd && echo "✓ kvmd OK" || echo "✗ kvmd FAILED"
systemctl is-active --quiet nginx && echo "✓ nginx OK" || echo "✗ nginx FAILED"

# Test 2: Video device
echo "Test 2: Checking video device..."
[ -e /dev/video0 ] && echo "✓ Video device OK" || echo "✗ Video device FAILED"

# Test 3: USB gadget
echo "Test 3: Checking USB gadget..."
[ -d /sys/kernel/config/usb_gadget/pikvm ] && echo "✓ USB gadget OK" || echo "✗ USB gadget FAILED"

# Test 4: Network endpoints
echo "Test 4: Checking network endpoints..."
curl -s http://localhost:8080/ > /dev/null && echo "✓ ustreamer endpoint OK" || echo "✗ ustreamer endpoint FAILED"
curl -s http://localhost:8081/api/info > /dev/null && echo "✓ kvmd API OK" || echo "✗ kvmd API FAILED"
curl -s http://localhost/ > /dev/null && echo "✓ nginx endpoint OK" || echo "✗ nginx endpoint FAILED"

echo "Tests complete!"
```

Make it executable and run:
```bash
chmod +x automated-test.sh
./automated-test.sh
```

## Troubleshooting Failed Tests

If any tests fail, refer to:
- [Troubleshooting Guide](troubleshooting.md)
- Service logs: `sudo journalctl -u <service-name> -f`
- System logs: `sudo journalctl -xe`

## Benchmark Results

Typical performance on Raspberry Pi 4B (4GB):

- Video Latency: 30-100ms
- CPU Usage: 20-40% (with hardware encoding)
- Memory Usage: 500MB-1GB
- Network Bandwidth: 5-15 Mbps (depending on resolution)
- Boot Time: 30-60 seconds

## Next Steps

Once all tests pass:

1. Set up HTTPS for secure access
2. Configure authentication
3. Set up ATX power control (if needed)
4. Configure firewall rules
5. Set up monitoring and logging

## Support

If tests fail and you can't resolve the issue:

1. Run `./scripts/check-status.sh` and save output
2. Collect logs: `sudo journalctl -u kvmd -u ustreamer > pikvm-logs.txt`
3. Open an issue on GitHub with:
   - Hardware details
   - Test results
   - Log files
   - Steps already tried
