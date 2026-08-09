VBoxManage createvm --name "ubuntu-template" --ostype "Ubuntu_64" --register

VBoxManage modifyvm "ubuntu-template" \
  --memory 2048 \       # 2GB RAM
  --cpus 2 \            # 2 CPU cores
  --nic1 bridged --bridgeadapter1 "[REPLACE-WITH-YOUR-NETWORK-INTERFACE]" \
  --graphicscontroller vmsvga \
  --boot1 dvd --boot2 disk

VBoxManage createmedium disk --filename "ubuntu-template.vdi" --size 20000 # 20GB disk size

VBoxManage storagectl "ubuntu-template" --name "SATA" --add sata --controller IntelAHCI
VBoxManage storageattach "ubuntu-template" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "ubuntu-template.vdi"
VBoxManage storageattach "ubuntu-template" --storagectl "SATA" --port 1 --device 0 --type dvddrive --medium "ubuntu-24.04.4-live-server-amd64.iso"
