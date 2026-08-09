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

# Limpiar host keys SSH: cada VM clonada debe generar las suyas propias
sudo rm -f /etc/ssh/ssh_host_*

# Limpiar machine-id (si no, todos los clones comparten el mismo ID -> problemas con DHCP/systemd)
sudo truncate -s 0 /etc/machine-id
sudo rm -f /var/lib/dbus/machine-id
sudo ln -s /etc/machine-id /var/lib/dbus/machine-id

# Limpiar historial de red persistente
sudo rm -f /etc/netplan/50-cloud-init.yaml 2>/dev/null

# Limpiar logs y caché de apt
sudo apt clean
sudo rm -rf /var/log/*.log /var/log/*/*.log
history -c && history -w
