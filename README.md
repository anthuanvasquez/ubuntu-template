# Ubuntu Server Template

## VBox

Download VirtualBox to handle this project and create the `ubuntu-template` base linux image.

https://www.virtualbox.org/wiki/Downloads

## Script

Run the `server.sp1` script to create the `ubuntu-template` base instance.

Replace [REPLACE-YOUR-NETWORK-INTERFACE] with the name from your real network using this command:

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

## Ubuntu

Run the `init.sh` script to update, upgrade and install the base tools to prepare the base instance.
