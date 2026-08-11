#!/usr/bin/env bash
# vps-bootstrap.sh
# Use: ./vps-bootstrap.sh <ip> <user> <path_to_public_key>

set -euo pipefail

VPS_IP="$1"
VPS_USER="${2:-ubuntu}"
PUBKEY_PATH="${3:-$HOME/.ssh/id_ed25519.pub}"

echo ">> Injecting SSH key into ${VPS_USER}@${VPS_IP}"

# Copy the public key (will prompt for password once)
ssh-copy-id -i "${PUBKEY_PATH}" "${VPS_USER}@${VPS_IP}"

echo ">> Verifying passwordless login..."
ssh -o BatchMode=yes -o ConnectTimeout=5 "${VPS_USER}@${VPS_IP}" "echo OK" || {
  echo "Key login failed. Aborting before disabling password auth."
  exit 1
}

echo ">> Disabling password authentication"
ssh "${VPS_USER}@${VPS_IP}" bash -s <<'EOF'
sudo sed -i \
  -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' \
  -e 's/^#\?PermitRootLogin.*/PermitRootLogin no/' \
  /etc/ssh/sshd_config
sudo systemctl restart ssh
EOF

echo ">> Done. ${VPS_IP} now only accepts key-based login."
