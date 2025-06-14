#!/bin/bash

# Habitica local development environment setup script
# For Ubuntu/Debian-based Linux

# 0. Create dedicated user for Habitica
if ! id habitica >/dev/null 2>&1; then
  sudo useradd -m -s /bin/bash habitica
fi

# 1. Install required system packages
sudo apt update
sudo apt install -y curl git libkrb5-dev build-essential

# 2. Install libssl-1.1
TMP_DEB="/tmp/libssl1.1_1.1.1f-1ubuntu2_amd64.deb"
wget -O "$TMP_DEB" http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
sudo dpkg -i "$TMP_DEB"
rm -f "$TMP_DEB"

# 3. Prepare /opt/habitica and set permissions
sudo mkdir -p /opt/habitica
sudo chown habitica:habitica /opt/habitica

# 4. Install nvm, Node.js, and Habitica as habitica user in /opt/habitica
sudo -i -u habitica bash <<'EOF'
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
fi
source "$NVM_DIR/nvm.sh"
nvm install 20
if [ ! -d "/opt/habitica/.git" ]; then
  git clone https://github.com/HabitRPG/habitica /opt/habitica
fi
cd /opt/habitica
npm i
if [ ! -f config.json ]; then
  cp config.json.example config.json
  sed -i 's|"TRUSTED_DOMAINS": "localhost,https://habitica.com"|"TRUSTED_DOMAINS": "localhost,https://habitica.com,${trusted_domain_entry}"|' /opt/habitica/config.json
fi
cd /opt/habitica/website/client
npm i
npm run build
EOF

# 5. Create systemd service for Habitica MongoDB
cat <<EOF | sudo tee /etc/systemd/system/habitica-mongo.service
[Unit]
Description=Habitica MongoDB (npm run mongo:dev)
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/habitica
ExecStart=/bin/bash -c 'export NVM_DIR=/home/habitica/.nvm && source /home/habitica/.nvm/nvm.sh && npm run mongo:dev'
Restart=always
User=habitica

[Install]
WantedBy=multi-user.target
EOF

# 6. Create systemd service for Habitica Server
cat <<EOF | sudo tee /etc/systemd/system/habitica-server.service
[Unit]
Description=Habitica Server (npm start)
After=habitica-mongo.service
Requires=habitica-mongo.service

[Service]
Type=simple
WorkingDirectory=/opt/habitica
Environment=PORT=8080
ExecStart=/bin/bash -c 'export NVM_DIR=/home/habitica/.nvm && source /home/habitica/.nvm/nvm.sh && npm start'
Restart=always
User=habitica

[Install]
WantedBy=multi-user.target
EOF

# 7. Enable and start services
sudo systemctl daemon-reload
sudo systemctl enable --now habitica-mongo.service
sudo systemctl enable --now habitica-server.service

echo "Habitica services registered with systemd and started."
echo "Setup complete. Access Habitica at http://localhost:8080" | tee -a /var/log/habitica-setup.log
