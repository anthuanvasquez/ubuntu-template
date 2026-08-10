#!/usr/bin/env bash
# vps-bootstrap.sh
# Use: ./vps-bootstrap.sh <ip> <user> <path_to_public_key>

set -euo pipefail

VPS_IP="$1"
VPS_USER="${2:-deploy}"
PUBKEY_PATH="${3:-$HOME/.ssh/id_ed25519.pub}"

echo ">> Inyectando clave SSH en ${VPS_USER}@${VPS_IP}"

# Copia la clave pública (pedirá password una única vez)
ssh-copy-id -i "${PUBKEY_PATH}" "${VPS_USER}@${VPS_IP}"

echo ">> Verificando login sin password..."
ssh -o BatchMode=yes -o ConnectTimeout=5 "${VPS_USER}@${VPS_IP}" "echo OK" || {
  echo "Fallo el login con clave. Abortando antes de deshabilitar password auth."
  exit 1
}

echo ">> Deshabilitando autenticación por password"
ssh "${VPS_USER}@${VPS_IP}" bash -s <<'EOF'
sudo sed -i \
  -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' \
  -e 's/^#\?PermitRootLogin.*/PermitRootLogin no/' \
  /etc/ssh/sshd_config
sudo systemctl restart ssh
EOF

echo ">> Listo. ${VPS_IP} ahora solo acepta login por clave."
