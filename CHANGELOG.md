# Changelog

All notable changes to the PiKVM Debian project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial implementation of PiKVM for Raspberry Pi OS (Debian)
- Installation scripts for automated setup
  - `install-packages.sh` - System package installation
  - `build-ustreamer.sh` - Build video streamer from source
  - `install-kvmd.sh` - Install PiKVM daemon
  - `configure-system.sh` - System configuration for USB OTG
  - `install-all.sh` - Master installation script
- USB gadget configuration for keyboard/mouse/mass storage emulation
- systemd service files for all components
- nginx reverse proxy configuration
- Comprehensive documentation
  - Installation guide
  - Troubleshooting guide
  - Quick reference guide
  - Research notes
  - Contributing guidelines
- GitHub Actions CI/CD workflow
  - ARM64/AArch64 build testing
  - Shell script validation
  - ustreamer build verification
- Project structure with organized directories
- `.gitignore` for build artifacts
- GPL v3 LICENSE file

### Features
- Video streaming via ustreamer
- Keyboard emulation via USB HID
- Mouse emulation via USB HID
- Mass storage device emulation
- Web-based control interface
- Support for Raspberry Pi 4B
- HDMI capture support via CSI-2

### Documentation
- Complete installation instructions
- Hardware requirements and setup
- Service management commands
- Troubleshooting for common issues
- Configuration file locations
- Security considerations

### Technical Details
- Built on Raspberry Pi OS (Debian Bookworm)
- Python 3.8+ support
- USB OTG via dwc2 kernel driver
- V4L2 for video capture
- nginx for web serving
- systemd for service management

## [0.1.0] - Initial Release

### Project Goals
- Simplify PiKVM installation on Raspberry Pi OS
- Remove dependency on Arch Linux packages
- Provide clear, maintainable installation scripts
- Focus on core KVM functionality
- Support Raspberry Pi 4B hardware

### Differences from Original PiKVM
- Uses Debian package ecosystem instead of Arch
- Simplified installation process
- Manual configuration instead of custom OS image
- Focuses on essential features first
- More accessible for Debian/Ubuntu users

### Known Limitations
- ATX power control not yet implemented
- Web UI uses basic nginx configuration (no SSL by default)
- Limited hardware platform support (Pi 4B only initially)
- Manual certificate generation required for HTTPS
- No automated updates mechanism

### Future Plans
- [ ] ATX power control via GPIO
- [ ] SSL/HTTPS setup automation
- [ ] Support for more Raspberry Pi models
- [ ] Support for additional HDMI capture devices
- [ ] User management and authentication
- [ ] Wake-on-LAN support
- [ ] VNC server integration
- [ ] Fan control for cooling
- [ ] OLED display support
- [ ] Docker container option
- [ ] Ansible playbook for automation

[Unreleased]: https://github.com/peterwwillis/pikvm-debian/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/peterwwillis/pikvm-debian/releases/tag/v0.1.0
