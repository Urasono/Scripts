#!/usr/bin/env bash
# -----------------------------------------------------------
#Nome: Arch Ajustes e instalação de apps
#Descrição: Ajustes no Arch linux e instalação de aplicativos
#Autor: Urasono
#Versão: 1.0
# -----------------------------------------------------------

#Elevação de root (Cuidado)
if [[ $EUID -ne 0 ]]; then
 echo "Você precisa ser root!" >&2
 exit 1
 fi

#Verificação se há erros no script
set -euxo pipefail
IFS=$'\n\t'

#check updates
pacman -Syu --needed archlinux-keyring --noconfirm

#Amd-ucode
pacman -S amd-ucode --noconfirm

#Verificando se há grub no sistema e, caso não venha a ter, o comando é ignorado
if pacman -Qs &>/dev/null; then
grub-mkconfig -o /boot/grub/grub.cfg
else
 "GRUB não instalado, ignorando configuração"
 fi

#Maximizar performance do SSD se houver no sistema

# SATA Active Link Power Management
#echo "ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", \
#    ATTR{link_power_management_policy}=="*", \
#    ATTR{link_power_management_policy}="max_performance"" > /etc/default/grub

#Removendo mitigação do kernel
echo "kernel.split_lock_mitigate=0" > /etc/sysctl.d/99-splitlock.conf

#Alteração de keyboard para abnt2 no tty e na interface gráfica
setxkbmap -model abnt2 -layout br
loadkeys br-abnt2

#pacman-contrib (Apagar o cache semanalmente para evitar um sistema sobrecarregado)
pacman -S pacman-contrib --noconfirm
systemctl enable --now paccache.timer

#Terminal Personalizado
echo "# If not running interactively, don't do anything
[[ himBHs != *i* ]] && return
alias ls='ls --color=auto'
alias l="ls -l"
alias la="ls -a"
alias up="apt upgrade"
alias upgd="pkg upgrade"
alias ouvir="mpv --no-video --ytdl-format='bestaudio[acodec^=opus]'"
alias ver="mpv --ytdl-format='bestvideo[height<=720][vcodec^=avc1]+bestaudio[acodec^=opus]'"
PS1='\[\e[1;95m\]\u@\h\[\e[0m\] \[\e[\e[1;93m\]\w\[\e[0m\]\n\[\e[38;5;46m\]╰➜\[\e[0m\] $ '
# PS1='[\u@\h \W]$ '" > ~/.bashrc && source ~/.bashrc

#Zram
pacman -S zram-generator --noconfirm
echo "[zram0]
zram-size = min(ram / 2, 8192)
compression-algorithm = zstd" > /etc/systems/zram-generator.conf
systemctl enable --now systemd-zram-setup@zram0.service

#Swapfile
mkswap -U clear --size 4G --file /swapfile
swapon /swapfile
echo "[Swap]
What=/swapfile

[Install]
WantedBy=swap.target" > /etc/systemd/system/swapfile.swap
systemctl enable --now swapfile.swap

#Alteração do swapiness para um valor aceitável na maioria das distribuições linux e algumas configurações extras na vm
echo "# A low value causes the kernel to prefer freeing up open files (page cache), a high value causes the kernel to try to use swap space,          
# and a value of 100 means IO cost is assumed to be equal.
vm.swappiness = 100 

# The value controls the tendency of the kernel to reclaim the memory which is used for caching of directory and inode objects (VFS cache).
# Lowering it from the default value of 100 makes the kernel less inclined to reclaim VFS cache (do not set it to 0, this may produce out-of-memory conditions)
vm.vfs_cache_pressure = 50

# Contains, as bytes, the number of pages at which a process which is
# generating disk writes will itself start writing out dirty data.
vm.dirty_bytes = 268435456

# This action will speed up your boot and shutdown, because one less module is loaded. Additionally disabling watchdog timers increases performance and lowers power consumption
# Disable NMI watchdog
kernel.nmi_watchdog = 0

# To hide any kernel messages from the console
kernel.printk = 3 3 3 3

# Increase netdev receive queue
# May help prevent losing packets
net.core.netdev_max_backlog = 4096

# Set size of file handles and inode cache
fs.file-max = 2097152" > /etc/sysctl.d/99-vm-settings.conf

#Instalação e Configuração de Músicas
#pacman -S --needed --noconfirm /
#  docker docker-compose navidrome
#systemctl enable --now docker

#Permitir que o usuário seja root
#gpasswd -a $USER docker && newgrp docker

#Navidrome
#mkdir -p ~/navidrome/músicas ~/navidrome/dados && cd ~/navidrome
#echo "services:
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
#      - "./musicas:/music" # Aqui é onde você vai colocar seus MP3/FLAC" > docker-compose.yml && cd ~/

#Subida do Servidor
#docker compose up -d

#Obtendo as musicas
#cd ~/navidrome/músicas
#yt-dlp -x --audio-format opus --audio-quality 0 --add-metadata --embed-thumbnail --parse-metadata "playlist_index:%(track_number)s" -o "~/navidrome/musicas/%(artist)s/%(album)s/%(playlist_index)s - %(title)s.%(ext)s" "URL_DA_PLAYLIST" && cd ~/

#Script Oficial de Instalação Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

#Adicionando ao Bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" >> ~/.bashrc && source ~/.bashrc

#Earlyoom Daemon Linux (Gerenciador a nível de sistema que trata de evitar o congelamento total do sistema ao estar sobrecarregado
pacman -S earlyoom --noconfirm
echo "EARLYOOM_ARGS="-r 0 -m 2 -M 256000 --prefer '^(Web Content|Isolated Web Co)$' --avoid '^(dnf|apt|pacman|rpm-ostree|packagekitd|gnome-shell|gnome-session-c|gnome-session-b|lightdm|sddm|sddm-helper|gdm|gdm-wayland-ses|gdm-session-wor|gdm-x-session|Xorg|Xwayland|systemd|systemd-logind|dbus-daemon|dbus-broker|cinnamon|cinnamon-sessio|kwin_x11|kwin_wayland|plasmashell|ksmserver|plasma_session|startplasma-way|sway|i3|xfce4-session|mate-session|marco|lxqt-session|openbox|cryptsetup)$'". " > /etc/default/earlyoom

#Escalonador De Disco (Ajuste para ter melhor transferência de dados, porém, é preciso verificar se as informações do seu HDD, SSD ou nvme estão de acordo com o script)
echo ' # define o escalonador para NVMe
#ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
# define o escalonador para SSD e eMMC
#ACTION=="add|cserviKERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
# define o escalonador para discos rotativos
#ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"' > /etc/udev/rules.d/60-ioschedulers.rule

#shader booster (Para AMD VULKAN e visa aumentar o cache para uma aplicação mais pesada e exigente)
echo "# enforce RADV vulkan implementation for AMD GPUs
export AMD_VULKAN_ICD=RADV

  # increase AMD and Intel cache size to 12GB
export MESA_SHADER_CACHE_MAX_SIZE=12G" >> .profile

# Aumentar o cache de shader para NVIDIA e intel
#echo "# increase Nvidia shader cache size to 12GB
#export __GL_SHADER_DISK_CACHE_SIZE=12000000000" >> .profile

#Alteração da frequência de CPU
#cpupower frequency-set -g powersave
#cpupower frequency-set -g performance
#cpupower frequency-set -g ondemand
#cpupower frequency-set -g schedutil

#NVIDIA Drivers (Open Source)
#pacman -S --noconfirm \
#nvidia-open-dkms nvidia-utils nvidia-settings

#(NVIDIA Driver Proprietários)
#pacman -S --needed --noconfirm \
#nvidia-dkms nvidia-utils nvidia-settings

#mkinitcpio -P

#instalações de aplicativos extras
#mkdir Openrgb
#wget "https://codeberg.org/OpenRGB/OpenRGB/releases/download/release_candidate_1.0rc2/OpenRGB_1.0rc2_x86_64_0fca93e.AppImage" -O OpenRGB.AppImage
#mv ./OpenRGB.AppImage Openrgb/
#cd Openrgb/
#wget "https://openrgb.org/releases/release_0.9/openrgb-udev-install.sh"
#chmod +x openrgb-udev-install.sh
#bash openrgb-udev-install.sh
#cd ../
wget "https://sourceforge.net/projects/ventoy/files/v1.1.10/ventoy-1.1.10-linux.tar.gz/download" -O Ventoy.tar.gz
mkdir Ventoy
tar -xvf Ventoy.tar.gz -C Ventoy/
rm ./*Ventoy.tar.gz

#<Flatpak>
pacman -S flatpak --noconfirm
pacman -S flatseal --noconfirm
flatpak update
#pacman -S davinci-resolve --noconfirm

#instalação dos pacotes

pacman -S --needed --noconfirm \
  nano bitwarden fastfetch gdu keepassxc \
  firefox mpv gstreamer gst-plugins-bad \
  gst-plugins-good gst-plugins-base gst-libav \
  gst-plugins-ugly ffmpeg base-devel gufw \
  wine winetricks steam lutris libreoffice-still \
  xorg mesa lib32-mesa xdg-users-dirs flameshot \
  tldr foliate speedtest-cli aria2 claws-mail \
  freecad timeshift cmus bleachbit linux-lts-headers \
  yt-dlp lm_sensors dhcp 

#instalação extra
pacman -S --needed --noconfirm \
  pacman-contrib archlinux-contrib curl fakeroot \
  htmlq diffutils hicolor-icon-theme python python-pyqt6 \
  qt6-svg glib2 xdg-utils

#Lidar com pacotes .pacnew e pacotes órfãos
pacdiff || true
pacman -Qdtq | pacman -Rns -

#yay AUR
git clone "https://aur.archlinux.org/yay-bin.git"
git clone "https://aur.archlinux.org/topgrade-bin.git"

#Limpeza Final de cache do pacman
pacman -Scc --noconfirm

#end
echo "Instale o dnsmasq e habilite ou descomente domain-needed, bogus-priv e bind-interface em /etc/dnsmasq.conf | Reinicie o sistema, amigão"
