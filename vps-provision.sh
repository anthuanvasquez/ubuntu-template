#!/usr/bin/env bash
# vps-provision.sh
# Use: ./vps-provision.sh <ip> <user>

VPS_IP="$1"
VPS_USER="${2:-deploy}"

./vps-bootstrap.sh "$VPS_IP" "$VPS_USER"

echo ">> Copiando vps-install.sh a la VM"
scp vps-install.sh "${VPS_USER}@${VPS_IP}:~/vps-install.sh"

echo ">> Ejecutando provisioning remoto"
ssh "${VPS_USER}@${VPS_IP}" "chmod +x vps-install.sh && ./vps-install.sh"
