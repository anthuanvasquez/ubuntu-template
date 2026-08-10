#!/usr/bin/env bash
# vps-install.sh
# Convierte un VPS limpio (Layer 1) en un Docker Host (Layer 2)

set -euo pipefail

echo ">> Actualizando sistema"
sudo apt update && sudo apt upgrade -y

echo ">> Instalando dependencias para el repo de Docker"
sudo apt install -y ca-certificates curl gnupg

echo ">> Agregando GPG key y repo oficial de Docker"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

echo ">> Instalando Docker Engine + Compose plugin"
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo ">> Agregando usuario actual al grupo docker"
sudo usermod -aG docker "$USER"

echo ">> Instalando Git"
sudo apt install -y git

echo ">> Configurando UFW para Docker Host"
sudo ufw allow OpenSSH
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

read -rp ">> ¿Instalar Fail2Ban? (y/n) " INSTALL_F2B
if [[ "$INSTALL_F2B" == "y" ]]; then
  sudo apt install -y fail2ban
  sudo systemctl enable --now fail2ban
fi

echo ">> Creando estructura /opt/app-auth"
sudo mkdir -p /opt/app-auth
sudo chown "$USER":"$USER" /opt/app-auth

echo ">> Provisioning completo. Cierra sesión y vuelve a entrar para usar Docker sin sudo."
docker --version
docker compose version
