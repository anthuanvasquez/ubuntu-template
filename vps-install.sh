#!/usr/bin/env bash
# vps-install.sh
# Converts a clean VPS (Layer 1) into a Docker host (Layer 2)

set -euo pipefail

echo ">> Updating system"
sudo apt update && sudo apt upgrade -y

echo ">> Installing Docker repo dependencies"
sudo apt install -y ca-certificates curl gnupg

echo ">> Adding Docker GPG key and official repo"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

echo ">> Installing Docker Engine + Compose plugin"
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo ">> Adding current user to the docker group"
sudo usermod -aG docker "$USER"

echo ">> Installing Git"
sudo apt install -y git

echo ">> Configuring UFW for Docker host"
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

read -rp ">> Install Fail2Ban? (y/n) " INSTALL_F2B
if [[ "$INSTALL_F2B" == "y" ]]; then
  sudo apt install -y fail2ban
  sudo systemctl enable --now fail2ban
fi

echo ">> Creating /opt/app-auth directory"
sudo mkdir -p /opt/app-auth
sudo chown "$USER":"$USER" /opt/app-auth

echo ">> Provisioning complete. Log out and back in to use Docker without sudo."
docker --version
docker compose version
