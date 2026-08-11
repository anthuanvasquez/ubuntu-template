#!/bin/bash
set -euo pipefail

#
# This script is intended to be run on
# a freshly installed Ubuntu server to
# perform initial setup and cleanup tasks.
#

set -euo pipefail

echo ">> [1/4] System update..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget vim htop unzip ca-certificates gnupg net-tools
sudo apt autoremove -y
echo ">> [1/4] Done."

echo ">> [2/4] Configuring firewall..."
sudo ufw allow OpenSSH
sudo ufw enable
echo ">> [2/4] Done."

echo ">> [3/4] Preparing image for cloning..."

# Clear SSH host keys: each cloned VM must generate its own
sudo rm -f /etc/ssh/ssh_host_*

# Clear machine-id (otherwise all clones share the same ID → DHCP/systemd conflicts)
sudo truncate -s 0 /etc/machine-id
sudo rm -f /var/lib/dbus/machine-id
sudo ln -s /etc/machine-id /var/lib/dbus/machine-id

# Clear persistent network config
sudo rm -f /etc/netplan/50-cloud-init.yaml 2>/dev/null

echo ">> [3/4] Done."

echo ">> [4/4] Cleaning up..."
# Clear apt cache and logs
sudo apt clean
sudo rm -rf /var/log/*.log /var/log/*/*.log
history -c && history -w
echo ">> [4/4] Done."

echo ">> Image ready. Take a snapshot now."
