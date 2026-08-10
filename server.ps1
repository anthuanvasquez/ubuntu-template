# Usage: .\server.ps1 [-Name "ubuntu-template"]
param(
    [string]$Name = "ubuntu-template"
)

# Dependency: download the Ubuntu Server ISO and place it in this directory.
# https://ubuntu.com/download/server
# Expected filename: ubuntu-24.04.4-live-server-amd64.iso
$ISO = "ubuntu-24.04.4-live-server-amd64.iso"

# 1. Create and register the VM
VBoxManage createvm --name "$Name" --ostype "Ubuntu_64" --register

# 2. Configure hardware
VBoxManage modifyvm "$Name" `
  --memory 2048 `       # 2GB RAM
  --cpus 2 `            # 2 CPU cores
  --nic1 bridged --bridgeadapter1 "[REPLACE-WITH-YOUR-NETWORK-INTERFACE]" `
  --graphicscontroller vmsvga `
  --boot1 dvd --boot2 disk

# 3. Create virtual disk and mount storage
VBoxManage createmedium disk --filename "$Name.vdi" --size 20000 # 20GB disk size

VBoxManage storagectl "$Name" --name "SATA" --add sata --controller IntelAHCI
VBoxManage storageattach "$Name" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "$Name.vdi"
VBoxManage storageattach "$Name" --storagectl "SATA" --port 1 --device 0 --type dvddrive --medium "$ISO" # mount ISO
