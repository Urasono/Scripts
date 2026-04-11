#!/usr/bin/env bash
#-------------------------------------------------------------
#Nome: Arch Ajustes e instalação de apps
#Descrição: Ajustes no Arch linux e instalação de aplicativos
#Autor: Urasono
#Verificado por meio do shellcheck (shellcheck -x "script")
#Versão: 1.0
#-------------------------------------------------------------

set -euo pipefail
IFS=$'\n\t'

#------------------FUNÇÕES---------------
log() {
  echo -e "\e[1;32m[INFO]\e[0m $1"
}

warn() {
  echo -e "\e[1;33m[WARN]\e[0m $1"
}

error() {
  echo -e "\e[1;31m[ERRO]\e[0m $1" >&2
}

required_root() {
  if [[ $EUID -ne 0 ]]; then
 error "Você precisa ser root!"
 exit 1
 fi
}

command_exists() {
  command -v "$1" &>/devil/null
}

#---------------SISTEMA----------------------------

update_system() {
  log "atualizando sistema"
  pacman -Syu --needed archlinux-keyring --noconfirm
}

install_microcide() {
  log "instalando amd-ucode..."
  pacman -S amd-ucode --noconfirm || warn "Falha ao instalar AMD-ucode"
}

configure_grub() {
 if command_exists grub-mkconfig; then
  log "Atualizando GRUB..."
  grub-mkconfig -o /boot/grub/grub.cfg
else
   warn "GRUB não instalado, ignorando configuração..."
 fi
}

#--------------------CONFIGURAÇÕES------------------------------

#configure_performance() {

#  cat <<'EOF' >> /etc/default/grub
  
#Maximizar performance do SSD se houver no sistema

# SATA Active Link Power Management
#echo "ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", \
#    ATTR{link_power_management_policy}=="*", \
#    ATTR{link_power_management_policy}="max_performance"
#EOF
#}

configure_sysctl() {

  log "configurando"
  cat <<'EOF' > /etc/sysctl.d/99-custom.conf
kernel.split_lock_mitigate=0
vm.swappiness = 100
vm.vfs_cache_pressure = 50
vm.dirty_bytes = 268435456
kernel.nmi_watchdog = 0
kernel.printk = 3 3 3 3
net.core.netdev_max_backlog = 4096
fs.file-max = 2097152
vm.page-cluster = 0
vm.max_map_count=524288
EOF
}

configure_journal() {
  log "limitando journal"

  mkdir -p /etc/systemd/journal.conf.d

  cat <<'EOF' >/etc/systemd/journal.conf.d/size.conf
[Journal]
SystemMaxUse=50M
EOF
}

configure_zram() {
  log "Configurando Zram"
  
  pacman -S zram-generator --noconfirm
  
  cat <<'EOF' > /etc/systemd/zram-generator.conf
[zram0]
zram-size = min(ram / 2, 8192)
compression-algorithm = zstd
EOF

systemctl enable --now systemd-zram-setup@zram0.service
}

configure_swapfile() {
  log "criando swapfile"
  
  if [[ ! -f /swapfile ]]; then
  fallocate -l 4G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
else
  warn "swapfile já existe, nada a fazer"
fi
}

configure_keyboard() {
  log "configurando teclado.."
  
  setxkbmap -model abnt2 -layout br || true
  loadkeys br-abnt2 || true
}

configure_bashrc() {
  
  log "configurando .bashrc"

  cat <<'EOF' > ~/.bashrc
[[ himBHs != *i* ]] && return
alias ls="ls --color=auto"
alias l="ls -l"
alias la="ls -a"
alias up="apt upgrade"
alias upgd="pkg upgrade"
alias ouvir="mpv --no-video --ytdl-format='bestaudio[acodec^=opus]'"
alias ver="mpv --ytdl-format='bestvideo[height<=720][vcodec^=avc1]+bestaudio[acodec^=opus]'"
PS1='\[\e[1;95m\]\u@\h\[\e[0m\] \[\e[\e[1;93m\]\w\[\e[0m\]\n\[\e[38;5;46m\]╰➜\[\e[0m\] $ '
EOF
}

configure_udev_rules() {

  log "configurando udev..."

  cat <<'EOF' > /etc/udev/rules.d/20-audio-pm.rules
# Disables power saving capabilities for snd-hda-intel when device is not
# running on battery power. This is needed because it prevents audio cracks on
# some hardware.
ACTION=="add", SUBSYSTEM=="sound", KERNEL=="card*", DRIVERS=="snd_hda_intel", TEST!="/run/udev/snd-hda-intel-powersave", \
    RUN+="/usr/bin/bash -c 'touch /run/udev/snd-hda-intel-powersave; \
        [[ $$(cat /sys/class/power_supply/BAT0/status 2>/dev/null) != \"Discharging\" ]] && \
        echo $$(cat /sys/module/snd_hda_intel/parameters/power_save) > /run/udev/snd-hda-intel-powersave && \
        echo 0 > /sys/module/snd_hda_intel/parameters/power_save'"

SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", TEST=="/sys/module/snd_hda_intel", \
    RUN+="/usr/bin/bash -c 'echo $$(cat /run/udev/snd-hda-intel-powersave 2>/dev/null || \
        echo 10) > /sys/module/snd_hda_intel/parameters/power_save'"

SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", TEST=="/sys/module/snd_hda_intel", \
    RUN+="/usr/bin/bash -c '[[ $$(cat /sys/module/snd_hda_intel/parameters/power_save) != 0 ]] && \
        echo $$(cat /sys/module/snd_hda_intel/parameters/power_save) > /run/udev/snd-hda-intel-powersave; \
        echo 0 > /sys/module/snd_hda_intel/parameters/power_save'"
EOF

  cat <<'EOF' > /etc/udev/rules.d/99-cpu-dma-latency.rules
DEVPATH=="/devices/virtual/misc/cpu_dma_latency", OWNER="root", GROUP="audio", MODE="0660"
EOF
}

configure_tmpfiles() {

  log "configurando tmpfiles para aplicativos que usam tcmalloc..."

  cat <<'EOF' > /etc/tmpfiles.d/thp.conf
# Improve performance for applications that use tcmalloc
# https://github.com/google/tcmalloc/blob/master/docs/tuning.md#system-level-optimizations
w! /sys/kernel/mm/transparent_hugepage/defrag - - - - defer+madvise
EOF
}

#configure_music_server() {

#  log "configurando docker e navidrome"

  #Instalação e Configuração de Músicas
#pacman -S --needed --noconfirm /
#  docker docker-compose navidrome
#systemctl enable --now docker

#Permitir que o usuário seja root
#gpasswd -a $USER docker && newgrp docker

#Navidrome
#mkdir -p ~/navidrome/músicas ~/navidrome/dados && cd ~/navidrome
  #cat <<'EOF' > ~/docker-compose.yml
  
  #  navidrome:
#    image: deluan/navidrome:latest
#    user: 1000:1000 # Isso garante que o servidor tenha acesso aos seus arquivos
#    ports:
#      - "4533:4533" # A porta que vamos usar no navegador
#    restart: unless-stopped
#    environment:
#      ND_SCANSCHEDULE: 1h
#      ND_LOGLEVEL: info
#      ND_BASEURL: ""
#    volumes:
#      - "./dados:/data"
#      - "./musicas:/music" # Aqui é onde você vai colocar seus MP3/FLAC
#EOF

#Subida do Servidor
#docker compose up -d
  #Obtendo as musicas
#cd ~/navidrome/músicas
#yt-dlp -x --audio-format opus --audio-quality 0 --add-metadata --embed-thumbnail --parse-metadata "playlist_index:%(track_number)s" -o "~/navidrome/musicas/%(artist)s/%(album)s/%(playlist_index)s - %(title)s.%(ext)s" "URL_DA_PLAYLIST" && cd ~/
#}

configure_oficial_script_homebrew() {

  log "baixando e executando o script"

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  cat <<'EOF' >> ~/.bashrc

  eval \"\$($(brew --prefix)/bin/brew shellenv)\
EOF
}

configure_Disk_scaler() {
  log "configurando escalonador de disco"

  cat <<'EOF' > /etc/udev/rules.d/60-ioschedulers.rules
# define o escalonador para NVMe
#ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
# define o escalonador para SSD e eMMC
#ACTION=="add|cserviKERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
# define o escalonador para discos rotativos
#ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
EOF
}

configure_shader_booster() {

  log "configurando shader booster"

  cat <<'EOF' > ~/.profile
# enforce RADV vulkan implementation for AMD GPUs
export AMD_VULKAN_ICD=RADV

  # increase AMD and Intel cache size to 12GB
export MESA_SHADER_CACHE_MAX_SIZE=12G
EOF

# Aumentar o cache de shader para NVIDIA e intel
#cat <<'EOF' > ~/.profile
# increase Nvidia shader cache size to 12GB
#export __GL_SHADER_DISK_CACHE_SIZE=12000000000
#EOF
}

configure_cpu_power() {

  log "Configurando a frequência da CPU"

  #cpupower frequency-set -g powersave
  #cpupower frequency-set -g performance
  #cpupower frequency-set -g ondemand
  #cpupower frequency-set -g schedutil
}

configure_open_source_nvidia_drivers() {

  log "baixando pacotes..."
  #pacman -S --noconfirm \
#nvidia-open-dkms nvidia-utils nvidia-settings
}

configure_proprietary_nvidia_drivers() {

  log "baixando pacotes..."
  #pacman -S --needed --noconfirm \
#nvidia-dkms nvidia-utils nvidia-settings
#mkinitcpio -P
}

configure_flatpak() {
  pacman -S --noconfirm flatpak flatseal
  flatpak update -y
}


#-----------------------PACOTES-----------------------

install_base_packages() {

  log "instalando pacotes base"
  pacman -S --needed --noconfirm \
  nano bitwarden fastfetch gdu keepassxc \
  firefox mpv gstreamer gst-plugins-bad \
  gst-plugins-good gst-plugins-base gst-libav \
  gst-plugins-ugly ffmpeg base-devel gufw \
  wine winetricks steam lutris libreoffice-still \
  xorg mesa lib32-mesa xdg-users-dirs flameshot \
  foliate speedtest-cli aria2 claws-mail \
  freecad timeshift cmus bleachbit linux-lts-headers \
  yt-dlp lm_sensors dhcp
}

install_extra_packages() {
  log "instalando extras.."
  pacman -S --needed --noconfirm \
  pacman-contrib archlinux-contrib curl fakeroot \
  htmlq diffutils hicolor-icon-theme python python-pyqt6 \
  qt6-svg glib2 xdg-utils
}

install_optional_packages() {

#mkdir Openrgb
#wget "https://codeberg.org/OpenRGB/OpenRGB/releases/download/release_candidate_1.0rc2/OpenRGB_1.0rc2_x86_64_0fca93e.AppImage" -O OpenRGB.AppImage
#mv ./OpenRGB.AppImage Openrgb/
#cd Openrgb/
#wget "https://openrgb.org/releases/release_0.9/openrgb-udev-install.sh"
#chmod +x openrgb-udev-install.sh
#bash openrgb-udev-install.sh
#cd ../
wget "https://sourceforgeprojects/ventoy/files/v1.1.10/ventoy-1.1.10-linux.tar.gz/download" -O Ventoy.tar.gz
mkdir Ventoy
tar -xvf Ventoy.tar.gz -C Ventoy/
rm ./*Ventoy.tar.gz
}

enable_services() {
  log "Habilitando serviços"
 
  systemctl enable --now paccache.timer || true
  
  pacman -S earlyoom --noconfirm
cat <<'EOF' > /etc/default/earlyoom 
EARLYOOM_ARGS="-r 0 -m 2 -M 256000 --prefer '^(Web Content|Isolated Web Co)$' --avoid '^(dnf|apt|pacman|rpm-ostree|packagekitd|gnome-shell|gnome-session-c|gnome-session-b|lightdm|sddm|sddm-helper|gdm|gdm-wayland-ses|gdm-session-wor|gdm-x-session|Xorg|Xwayland|systemd|systemd-logind|dbus-daemon|dbus-broker|cinnamon|cinnamon-sessio|kwin_x11|kwin_wayland|plasmashell|ksmserver|plasma_session|startplasma-way|sway|i3|xfce4-session|mate-session|marco|lxqt-session|openbox|cryptsetup)$'
EOF
}

cleanup_system() {
  log "Limpando Sistema"

  pacdiff || true
pacman -Qdtq | pacman -Rns - --noconfirm  || true
pacman -Scc --noconfirm
}

aur_git_clone() {
  git clone "https://aur.archlinux.org/yay-bin.git"
  git clone "https://aur.archlinux.org/topgrade-bin.git"
}

configure_dnsmaq() {
  log "Instale o dnsmasq e habilite ou descomente domain-needed, bogus-priv e bind-interface em /etc/dnsmasq.conf | Reinicie o sistema, amigão"
}

#--------------------MAIN---------------------------

main() {
    required_root

    update_system
    install_microcode
    configure_grub
    configure_udev_rules
    configure_tmpfiles
    configure_keyboard
    configure_music_server
    configure_Disk_scaler
    configure_shader_booster
    configure_performance
    configure_cpu_power
    configure_open_source_nvidia_drivers
    configure_proprietary_nvidia_drivers
    configure_flatpak
    configure_oficial_script_homebrew
    configure_sysctl
    configure_journal
    configure_zram
    configure_swapfile
    configure_bashrc
    install_base_packages
    install_extra_packages
    install_optional_packages
    aur_git_clone
    configure_dnsmaq
    enable_services
    cleanup_system

    log "Instale o dnsmasq e habilite ou descomente domain-needed, bogus-priv e bind-interface em /etc/dnsmasq.conf | Reinicie o sistema, amigão"
}

main "$@"

#######--------#########
