#!/usr/bin/env bash

log() {
echo -e "\e[1;32m[INFO]\e[0m $1"
}

error() {
echo -e "\e[1;31m[ERRO]\e[0m $1"
}

warn() {
echo -e "\e[1;33m[WARN]\e[0m $1"
}

System_Update() {

  apt update && apt upgrade
}

Install_Packages() {

   apt install -y \
keepassxc mpv kdeconnect neofetch qbittorrent
}

Install_Flatpak() {

  flatpak install flathub org.torproject.torbrowser-launcher -y
  flatpak install flathub org.onlyoffice.desktopeditors
}

Flatpak_Clean_Up() {
  flatpak uninstall --delete-data -y
  flatpak uninstall --unused -y
}

Snap_Update() {

  sudo snap refresh
}

Snap_Clean_Up() {

  sudo rm -rf /var/lib/snapd/cache/*
}

Update_System() {

  sudo apt update
  sudo apt install --fix-missing -y
}

System_Clean() {

  sudo apt install -f
  sudo apt autoremove -y
  sudo apt autoclean
  sudo apt clean
}

main() {

  System_Update
  Install_Packages
  Install_Flatpak
  Flatpak_Clean_Up
  Snap_Update
  Snap_Clean_Up
  Update_System
  System_Clean
}

main "$@"
