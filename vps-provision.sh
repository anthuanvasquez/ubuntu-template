#!/usr/bin/env bash
# vps-provision.sh
# Use: ./vps-provision.sh <ip> [user]

set -euo pipefail

[[ $# -lt 1 ]] && { echo "Usage: $0 <ip> [user]"; exit 1; }

VPS_IP="$1"
VPS_USER="${2:-ubuntu}"

./vps-bootstrap.sh "$VPS_IP" "$VPS_USER"

echo ">> Copying vps-install.sh to the VM"
scp vps-install.sh "${VPS_USER}@${VPS_IP}:~/vps-install.sh"

echo ">> Running remote provisioning"
ssh "${VPS_USER}@${VPS_IP}" "chmod +x vps-install.sh && ./vps-install.sh"
