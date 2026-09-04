#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=== 1. Updating APT Package Lists & Upgrading Packages ==="
apt-get update -y
apt-get upgrade -y

echo "=== 2. Installing Prerequisites (curl & vim) ==="
apt-get install -y curl vim ca-certificates gnupg

echo "=== 3. Installing Docker & Docker Compose Plugin ==="
# Add Docker's official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Set up the Docker repository for Debian Trixie
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker engine and Compose plugin
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "=== 4. Verifying Docker Installation ==="
docker --version
docker compose version

echo "=== 5. Setting Up Project Directory ==="
read -rp "Enter the name of the directory to create: " DIR_NAME

if [ -z "$DIR_NAME" ]; then
    echo "Directory name cannot be empty. Exiting."
    exit 1
fi

mkdir -p "$DIR_NAME"
cd "$DIR_NAME" || exit

echo "=== 6. Creating docker-compose.yml ==="
cat <<'EOF' > docker-compose.yml
services:
  web:
    image: nginx:alpine
    container_name: sample_web
    ports:
      - "8080:80"
    restart: always
EOF

echo "Done! Created '$DIR_NAME' with a starter docker-compose.yml (running Nginx on port 8080)."
