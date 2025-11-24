     #!/bin/bash

     #setup Script

     #uninstall Bloatware Apps

     sudo apt --purge remove -y libreoffice*
     sudo apt --purge remove -y gnome-weather
     sudo apt --purge remove -y simple-scan
     sudo apt --purge remove -y brasero
     sudo apt --purge remove -y gnome-power-manager
     sudo apt --purge remove -y gnome-maps
     sudo apt --purge remove -y zorin-connect
     sudo apt --purge remove -y gnome-music
     sudo apt --purge remove -y rhythmbox
     sudo apt --purge remove -y gnome-contacts
     sudo apt --purge remove -y gnome-connections
     sudo apt --purge remove -y baobab
     sudo apt --purge remove -y gnome-characters
     sudo apt --purge remove -y gnome-photos
     sudo apt --purge remove -y malcontent
     sudo apt --purge remove -y remmina
     sudo apt --purge remove -y gnome-camera*

     # System Update and upgrade
     sudo apt update
     sudo apt install --fix-missing -y
     sudo apt upgrade -y

     #system disable unit-files
     sudo systemctl disable cups.service
     sudo systemctl disable cups.path
     sudo systemctl disable cups.socket

     #System clean Up
     sudo apt install -f
     sudo apt autoremove --purge -y
     sudo apt autoclean
     sudo apt clean

     # End of Script

    # Display installation Complete Message
    echo "All good now!!"
    echo "please, restart the computer."
