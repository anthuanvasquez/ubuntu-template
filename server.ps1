# Usage: .\server.ps1 [-Name "ubuntu-template"] [-Memory 2048] [-Cpus 2] [-DiskGB 20]
param(
    [string]$Name   = "ubuntu-template",
    [int]   $Memory = 2048,
    [int]   $Cpus   = 2,
    [int]   $DiskGB = 20
)

# Dependency: download the Ubuntu Server ISO and place it in this directory.
# https://ubuntu.com/download/server
# Expected filename: ubuntu-24.04.4-live-server-amd64.iso
$ISO = "ubuntu-24.04.4-live-server-amd64.iso"
$NetworkAdapter = "[REPLACE-WITH-YOUR-NETWORK-INTERFACE]"
$UserVboxPath = "$env:USERPROFILE\VirtualBox VMs\$Name"

# Guards: fail fast before creating any resources
if ($NetworkAdapter -like "*REPLACE*") {
    Write-Error "Set `$NetworkAdapter before running. Use: VBoxManage list bridgedifs"
    exit 1
}
if (-not (Test-Path $ISO)) {
    Write-Error "ISO not found: $ISO. Download it from https://ubuntu.com/download/server"
    exit 1
}

# 1. Create and register the VM
VBoxManage createvm --name "$Name" --ostype "Ubuntu_64" --register

# 2. Configure hardware (2GB RAM, 2 CPUs, bridged network, boot from DVD first)
VBoxManage modifyvm "$Name" `
  --memory $Memory `
  --cpus $Cpus `
  --nic1 bridged --bridgeadapter1 "$NetworkAdapter" `
  --graphicscontroller vmsvga `
  --boot1 dvd `
  --boot2 disk `
  --ioapic on `
  --firmware efi `
  --nestedpaging on `
  --vtxvpid on `
  --paravirtprovider kvm

# 3. Create virtual disk and mount storage
VBoxManage createmedium disk --filename "$UserVboxPath\$Name.vdi" --size ($DiskGB * 1024) # disk size in MB

VBoxManage storagectl "$Name" --name "SATA" --add sata --controller IntelAHCI
VBoxManage storageattach "$Name" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "$UserVboxPath\$Name.vdi"
VBoxManage storageattach "$Name" --storagectl "SATA" --port 1 --device 0 --type dvddrive --medium "$ISO" # mount ISO
