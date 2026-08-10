# Ubuntu Server Template

## VBox

Download VirtualBox to handle this project and create the `ubuntu-template` base linux image.

https://www.virtualbox.org/wiki/Downloads

## Script

Run the `server.sp1` script to create the `ubuntu-template` base instance.

Replace [REPLACE-YOUR-NETWORK-INTERFACE] with the name of your real network using this command:

```sh
VBoxManage list bridgedifs
```

Ejecuta la vm para instalar ubuntu server:

```sh
VBoxManage startvm "ubuntu-template" --type gui
```

Opciones a tomar en cuenta en el setup inicial:
- DHCP
- usuario: ubuntu / password: ubuntu
- Instala OpenSSH server de la lista de herramientas


Note: read the script before run to update the values to your needs.

Retira el ISO virtual de la vm:

```sh
VBoxManage storageattach "ubuntu-template" --storagectl "SATA" --port 1 --device 0 --type dvddrive --medium none
```

## Ubuntu

Run the `init.sh` script to update, upgrade and install the base tools to prepare the base instance.

Luego crea un snapshot, el cual servira como instancia para clonar:

```sh
VBoxManage snapshot "ubuntu-template" take "clean-install" --description "Golden image: Ubuntu 24.04 + SSH + user + base tools"
```

Luego cada instancia nueva es un clon del snapshot:

```sh
VBoxManage clonevm "ubuntu-template" --snapshot "clean-install" --options link --name "vps-dev" --register
VBoxManage clonevm "ubuntu-template" --snapshot "clean-install" --options link --name "vps-staging" --register
VBoxManage clonevm "ubuntu-template" --snapshot "clean-install" --options link --name "vps-prod" --register
```

Inicia la instancia en modo headless

```sh
VBoxManage startvm "vps-dev" --type headless
```
