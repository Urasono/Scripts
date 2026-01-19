#!/bin/bash  
 #Apps to install Script
 # System Update
 sudo apt update
 #apps
 sudo apt install -y ncdu
 sudo apt install -y keepassxc
 sudo apt install -y mpv
 sudo apt install -y kdeconnect
 sudo apt install -y neofetch
 sudo apt install -y qbittorrent

 #Flatpak Update

 #Flatpak Apps
 ## Tor Browser
 flatpak install flathub org.torproject.torbrowser-launcher -y
 ## Onlyoffice
 flatpak install flathub org.onlyoffice.desktopeditors

 # Flatpak Clean Up
 flatpak uninstall --delete-data -y
 flatpak uninstall --unused -y

 # Snap Update
 sudo snap refresh

 # Snap Clean Up
 sudo rm -rf /var/lib/snapd/cache/*

 #System Update and Upgrade
 sudo apt update
 sudo apt install --fix-missing -y

 #System Clean
 sudo apt install -f
 sudo apt autoremove -y
 sudo apt autoclean
 sudo apt clean

  #End
