# Contributing to PiKVM Debian

Thank you for your interest in contributing to PiKVM Debian! This document provides guidelines for contributing to the project.

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive criticism
- Respect differing viewpoints and experiences

## How to Contribute

### Reporting Bugs

When reporting bugs, please include:

1. **Hardware Setup**
   - Raspberry Pi model and RAM
   - HDMI capture device model
   - Any other relevant hardware

2. **Software Versions**
   - Raspberry Pi OS version (`cat /etc/os-release`)
   - Kernel version (`uname -a`)
   - Python version (`python3 --version`)

3. **Steps to Reproduce**
   - Clear, numbered steps to reproduce the issue
   - Expected behavior
   - Actual behavior

4. **Logs and Error Messages**
   ```bash
   sudo journalctl -u kvmd -n 100
   sudo journalctl -u ustreamer -n 100
   ```

5. **Screenshots** (if applicable)

### Suggesting Enhancements

Enhancement suggestions are welcome! Please include:

- Clear description of the enhancement
- Why it would be useful
- Example use cases
- Potential implementation approach (if you have ideas)

### Pull Requests

1. **Fork the Repository**
   ```bash
   git clone https://github.com/your-username/pikvm-debian.git
   cd pikvm-debian
   ```

2. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

3. **Make Your Changes**
   - Follow the coding style of the project
   - Write clear, descriptive commit messages
   - Test your changes thoroughly

4. **Test Your Changes**
   - Test on actual Raspberry Pi hardware if possible
   - Verify scripts run without errors
   - Check that services start correctly
   - Document any new dependencies

5. **Update Documentation**
   - Update README.md if needed
   - Update installation guide for new steps
   - Add troubleshooting entries for common issues
   - Update quick reference if adding new commands

6. **Submit Pull Request**
   - Write a clear PR description
   - Reference any related issues
   - Explain what the PR does and why
   - List testing performed

## Development Guidelines

### Shell Scripts

- Use `#!/bin/bash` shebang
- Enable error handling: `set -e`
- Add descriptive comments
- Check for root when needed
- Provide informative output
- Use proper error messages
- Test syntax: `bash -n script.sh`

**Example:**
```bash
#!/bin/bash
# Description of what this script does

set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

echo "Step 1: Doing something..."
# Commands here

echo "Step complete!"
```

### Documentation

- Use Markdown format
- Include code examples
- Keep language clear and simple
- Use proper headings hierarchy
- Add table of contents for long documents
- Keep line length reasonable (80-100 chars)

### Configuration Files

- Use YAML for configs where possible
- Include comments explaining options
- Provide sensible defaults
- Document all options

### Python Code (if adding kvmd modifications)

- Follow PEP 8 style guide
- Use type hints
- Write docstrings for functions/classes
- Handle errors gracefully
- Log appropriately

## Testing

### Manual Testing Checklist

Before submitting a PR, test:

- [ ] Package installation completes successfully
- [ ] ustreamer builds and installs
- [ ] kvmd installs without errors
- [ ] System configuration runs successfully
- [ ] Services start correctly
- [ ] Web interface is accessible
- [ ] Video streaming works
- [ ] Keyboard/mouse emulation works
- [ ] No errors in service logs

### Testing on Different Hardware

If possible, test on:
- Raspberry Pi 4B (4GB and 8GB)
- Different HDMI capture devices
- Different Raspberry Pi OS versions

### Automated Testing

- GitHub Actions runs on all PRs
- All scripts are syntax-checked
- Build tests run in ARM64 container

## Project Structure

```
pikvm-debian/
├── .github/
│   └── workflows/      # GitHub Actions CI/CD
├── docs/               # Documentation
│   ├── installation-guide.md
│   ├── troubleshooting.md
│   ├── quick-reference.md
│   └── research-notes.md
├── scripts/            # Installation and setup scripts
│   ├── install-all.sh
│   ├── install-packages.sh
│   ├── build-ustreamer.sh
│   ├── install-kvmd.sh
│   └── configure-system.sh
├── .gitignore
├── AGENT_PROMPT.md     # Original project requirements
└── README.md           # Main readme
```

## Areas Needing Contribution

### High Priority

- [ ] Testing on different hardware configurations
- [ ] ATX power control implementation
- [ ] Web UI customization for Debian version
- [ ] Authentication and user management
- [ ] SSL/HTTPS setup automation

### Medium Priority

- [ ] More comprehensive error handling
- [ ] Automated backup/restore scripts
- [ ] Performance optimization
- [ ] Additional video capture device support
- [ ] VNC server integration

### Low Priority

- [ ] Docker container support
- [ ] Ansible playbook for deployment
- [ ] Fan control integration
- [ ] OLED display support
- [ ] Wake-on-LAN integration

## Code Review Process

1. Maintainer reviews PR
2. Feedback provided if changes needed
3. Once approved, PR is merged
4. Changes included in next release

## Release Process

Releases follow semantic versioning:
- MAJOR.MINOR.PATCH
- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes

## Getting Help

- Open an issue for questions
- Check existing documentation first
- Provide context when asking for help
- Be patient - this is a volunteer project

## Recognition

Contributors will be:
- Listed in project contributors
- Mentioned in release notes
- Credited in commits

## License

By contributing, you agree that your contributions will be licensed under GPLv3, the same license as the project.

## Questions?

Feel free to open an issue with the "question" label if you need clarification on anything in this guide.

Thank you for contributing to PiKVM Debian!
