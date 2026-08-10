# Ubuntu Server Template

A VirtualBox-based workflow to create a golden Ubuntu Server image and spin up cloned VPS instances with Docker ready to go.

## Overview

```
[server.ps1] → Create VM → Install Ubuntu → [init.sh] → Snapshot
                                                            ↓
                                          Clone → [vps-provision.sh]
                                                    ↓           ↓
                                             [vps-bootstrap.sh] [vps-install.sh]
                                             (SSH key auth)     (Docker + Git + UFW)
```

## Scripts

| Script | Purpose |
|---|---|
| `server.ps1` | Creates and configures the base VirtualBox VM |
| `init.sh` | Prepares the Ubuntu install for cloning (updates, tools, cleanup) |
| `vps-provision.sh` | Orchestrates full provisioning of a cloned VM |
| `vps-bootstrap.sh` | Injects your SSH key and disables password auth |
| `vps-install.sh` | Installs Docker, Git, UFW rules on the cloned VM |

---

## Step 1 — Install VirtualBox & Download Ubuntu

- Download and install VirtualBox: https://www.virtualbox.org/wiki/Downloads

- Download Ubuntu Server 24 LTS: https://ubuntu.com/download/server  
  **Place the ISO in this directory.** `server.ps1` expects it as `ubuntu-24.04.4-live-server-amd64.iso`.

---

## Step 2 — Create the Base VM

Find your network interface name:

```sh
VBoxManage list bridgedifs
```

Edit `server.ps1` and replace `[REPLACE-WITH-YOUR-NETWORK-INTERFACE]` with the name from the output above, then run it:

```powershell
# Default name: "ubuntu-template"
.\server.ps1

# Custom name
.\server.ps1 -Name "my-base-vm"
```

The script creates the VM, attaches the VDI disk, and mounts the ISO. The VDI filename matches the `-Name` value.

---

## Step 3 — Install Ubuntu Server

Boot the VM and follow the Ubuntu installer:

```sh
VBoxManage startvm "<name>" --type gui
```

Key settings during installation:
- Network: **DHCP**
- Credentials: `ubuntu` / `ubuntu`
- Enable **OpenSSH server** from the featured snaps list

After installation, eject the virtual ISO:

```sh
VBoxManage storageattach "<name>" --storagectl "SATA" --port 1 --device 0 --type dvddrive --medium none
```

---

## Step 4 — Initialize the Base Image

SSH into the VM and run `init.sh`. This script:
- Updates and upgrades the system
- Installs base tools (`curl`, `vim`, `htop`, etc.)
- Enables UFW and allows SSH
- Clears SSH host keys, machine-id, and network state so clones get unique identities
- Clears apt cache, logs, and shell history

```sh
# Copy and run on the VM
scp init.sh ubuntu@<VM_IP>:~/
ssh ubuntu@<VM_IP> "bash ~/init.sh"
```

> **Why scp and not a shared folder?** VirtualBox shared folders require Guest Additions installed inside the guest, which adds ~200MB to the base image and a manual setup step. `scp` works out of the box as soon as OpenSSH is enabled during installation.

---

## Step 5 — Take a Golden Snapshot

```sh
VBoxManage snapshot "<name>" take "clean-install" \
  --description "Golden image: Ubuntu Server 24 + SSH + user + base tools"
```

This snapshot is the base for every future clone.

---

## Step 6 — Clone and Provision

Every new instance is a linked clone of the snapshot. The `vps-provision.sh` script handles the full flow automatically:

```sh
./vps-provision.sh <IP> <user>
```

It runs in order:
1. **`vps-bootstrap.sh`** — copies your public key (`~/.ssh/id_ed25519.pub`) and disables password authentication
2. **`vps-install.sh`** — installs Docker Engine, Docker Compose plugin, Git, and configures UFW (ports 22, 80, 443)

### Creating a new clone manually

```sh
VBoxManage clonevm "<name>" --snapshot "clean-install" --options link --name "vps-prod" --register
VBoxManage startvm "vps-prod" --type headless
./vps-provision.sh <IP> <user>
```

After provisioning, log out and back in so Docker group membership takes effect.

---

## Notes

- The `vps-install.sh` script will prompt whether to install **Fail2Ban** for brute-force protection.
- `vps-bootstrap.sh` accepts a third argument for a custom public key path: `./vps-bootstrap.sh <ip> <user> ~/.ssh/custom.pub`
- All clones get fresh SSH host keys and a unique machine-id on first boot, avoiding DHCP/systemd conflicts.
