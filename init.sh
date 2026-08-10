# !/bin/bash

#
# This script is intended to be run on
# a freshly installed Ubuntu server to
# perform initial setup and cleanup tasks.
#
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget vim htop unzip ca-certificates gnupg net-tools
sudo apt autoremove -y

# Enable UFW firewall and allow SSH connections
sudo ufw allow OpenSSH
sudo ufw enable

# Clear SSH host keys: each cloned VM must generate its own
sudo rm -f /etc/ssh/ssh_host_*

# Clear machine-id (otherwise all clones share the same ID → DHCP/systemd conflicts)
sudo truncate -s 0 /etc/machine-id
sudo rm -f /var/lib/dbus/machine-id
sudo ln -s /etc/machine-id /var/lib/dbus/machine-id

# Clear persistent network config
sudo rm -f /etc/netplan/50-cloud-init.yaml 2>/dev/null

# Clear apt cache and logs
sudo apt clean
sudo rm -rf /var/log/*.log /var/log/*/*.log
history -c && history -w
