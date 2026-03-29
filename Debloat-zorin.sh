#!/usr/bin/env bash
#--------------------------------
#setup Script

#uninstall Bloatware Apps

log() {
echo -e "\e[1;32m[INFO]\e[0m $1"
}

warn() {
echo -e "\e[1;33m[WARN]\e[0m $1"
}

error() {
echo -e "\e[1;31m[ERRO]\e[0m $1"
}

required_root() {

  if [[ $EUID -ne 0 ]]; then
  warn "Você precisa de root!"
exit 1
fi
}

uninstall_packages() {

  log "Desinstalando pacotes..."

  apt --purge remove -y \
gnome-weather simple-scan brasero gnome-power-manager gnome-maps zorin-connect gnome-music rhythmbox \
gnome-contacts gnome-connections baobab gnome-characters gnome-photos malcontent remmina gnome-camera*
}

update_system() {

  apt update && apt upgrade
  apt install --fix-missing -y
}

disable_unit_files() {

  systemctl disable cups.service
}

System_clean_up() {

  apt install -f
  apt autoremove --purge -y
  apt autoclean && apt clean
}

    echo "All good now!!"
    echo "please, restart the computer."

main(){

  uninstall_packages
  update_system
  disable_unit_files
  System_clean_up
}

main "$@"
