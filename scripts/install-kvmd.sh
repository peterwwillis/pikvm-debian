#!/bin/bash
# Install kvmd (PiKVM daemon) from source
# This script clones and installs the main PiKVM daemon

set -e

echo "================================"
echo "Installing kvmd (PiKVM Daemon)"
echo "================================"
echo ""

# Configuration
KVMD_REPO="https://github.com/pikvm/kvmd.git"
BUILD_DIR="/tmp/pikvm-build"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

echo "Step 1: Installing additional Python dependencies via pip..."
pip3 install --break-system-packages \
    netifaces \
    psutil \
    systemd-python \
    Pillow \
    zstandard \
    xlib \
    hidapi \
    async-lru \
    pyyaml

echo ""
echo "Step 2: Creating build directory..."
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo ""
echo "Step 3: Cloning kvmd repository..."
if [ -d "kvmd" ]; then
    echo "Removing existing kvmd directory..."
    rm -rf kvmd
fi
git clone --depth 1 "$KVMD_REPO"
cd kvmd

echo ""
echo "Step 4: Installing kvmd using pip..."
pip3 install --break-system-packages -e .

echo ""
echo "Step 5: Creating configuration directories..."
mkdir -p /etc/kvmd
mkdir -p /etc/kvmd/web

echo ""
echo "Step 6: Copying configuration files..."
if [ -d "configs" ]; then
    cp -r configs/* /etc/kvmd/ || echo "Warning: Could not copy all config files"
fi

echo ""
echo "Step 7: Creating kvmd user and group..."
if ! id -u kvmd > /dev/null 2>&1; then
    useradd -r -s /bin/false kvmd
    echo "Created kvmd user"
else
    echo "kvmd user already exists"
fi

echo ""
echo "Step 8: Setting up permissions..."
chown -R kvmd:kvmd /etc/kvmd
chmod 750 /etc/kvmd

echo ""
echo "Step 9: Creating kvmd directories..."
mkdir -p /var/lib/kvmd
mkdir -p /var/lib/kvmd/msd
mkdir -p /var/log/kvmd
chown -R kvmd:kvmd /var/lib/kvmd
chown -R kvmd:kvmd /var/log/kvmd

echo ""
echo "Step 10: Installing systemd services..."
cat > /etc/systemd/system/kvmd.service << 'EOF'
[Unit]
Description=kvmd - The main PiKVM daemon
After=network.target ustreamer.service
Wants=ustreamer.service

[Service]
Type=simple
User=kvmd
Group=kvmd
WorkingDirectory=/var/lib/kvmd
ExecStart=/usr/local/bin/kvmd
Restart=always
RestartSec=3

# Security settings
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/var/lib/kvmd /var/log/kvmd /etc/kvmd

[Install]
WantedBy=multi-user.target
EOF

echo ""
echo "Step 11: Creating nginx configuration for kvmd..."
cat > /etc/nginx/sites-available/kvmd << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    server_name _;
    
    root /usr/share/kvmd/web;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    location /api {
        proxy_pass http://127.0.0.1:8081;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /ws {
        proxy_pass http://127.0.0.1:8081;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
    
    location /streamer {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_buffering off;
    }
}
EOF

# Enable the nginx site
if [ ! -f /etc/nginx/sites-enabled/kvmd ]; then
    ln -s /etc/nginx/sites-available/kvmd /etc/nginx/sites-enabled/kvmd
fi

# Remove default nginx site if it exists
if [ -f /etc/nginx/sites-enabled/default ]; then
    rm /etc/nginx/sites-enabled/default
fi

echo ""
echo "Step 12: Reloading systemd..."
systemctl daemon-reload

echo ""
echo "================================"
echo "kvmd installation complete!"
echo "================================"
echo ""
echo "Installation details:"
echo "  Configuration: /etc/kvmd/"
echo "  Data directory: /var/lib/kvmd/"
echo "  Log directory: /var/log/kvmd/"
echo "  Service: /etc/systemd/system/kvmd.service"
echo "  Nginx config: /etc/nginx/sites-available/kvmd"
echo ""
echo "Note: Services are not enabled by default."
echo "Next step: Run ./scripts/configure-system.sh to set up USB OTG"
