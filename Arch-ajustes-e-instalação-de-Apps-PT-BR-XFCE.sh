#!/usr/bin/env bash
#Ajustes e instalação de Apps xfce PT BR - Ajustes no Arch linux e instalação de aplicativos com base no sistema em Português e buscando a instalação da interface gráfica XFCE.

#Elevação de root (Cuidado)
if [[ $EUID -ne 0 ]]; then
 echo "Você precisa ser root!" >&2
 exit 1
 fi
 
#Verificação se há erros
set -euxo pipefail
IFS=$'\n\t'

#check updates
pacman -Syu && pacman -Syu --needed archlinux-keyring --noconfirm

#grub-config microcódigo
pacman -S amd-ucode --noconfirm

#modo root
grub-mkconfig -o /boot/grub/grub.cfg

#set keyboard
setxkbmap -model abnt2 -layout br
loadkeys br-abnt2

#pacman-contrib (empty cache weekly)
pacman -S pacman-contrib --noconfirm
systemctl enable paccache.timer
systemctl start paccache.timer

#Earlyoom Daemon Linux
pacman -S earlyoom --noconfirm
systemctl enable earlyoom

echo "# Default settings for earlyoom. This file is sourced by /bin/sh from
# /etc/init.d/earlyoom or by systemd from earlyoom.service.

# Available minimum memory 15% and free minimum swap 5%
# EARLYOOM_ARGS="-m 15 -s 5"

EARLYOOM_ARGS="-r 0 -m 2 -M 256000 --prefer '^(Web Content|Isolated Web Co)$' --avoid '^(dnf|apt|pacman|rpm-ostree|packagekitd|gnome-shell|gnome-session-c|gnome-session-b|lightdm|sddm|sddm-helper|gdm|gdm-wayland-ses|gdm-session-wor|gdm-x-session|Xorg|Xwayland|systemd|systemd-logind|dbus-daemon|dbus-broker|cinnamon|cinnamon-sessio|kwin_x11|kwin_wayland|plasmashell|ksmserver|plasma_session|startplasma-way|sway|i3|xfce4-session|mate-session|marco|lxqt-session|openbox|cryptsetup)$'"" > /etc/default/earlyoom
systemctl start earlyoom

#Escalonador De Disco
echo ' # define o escalonador para NVMe
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
# define o escalonador para SSD e eMMC
ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
# define o escalonador para discos rotativos
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"' > /etc/udev/rules.d/60-ioschedulers.rule

#shader booster
echo "# enforce RADV vulkan implementation for AMD GPUs
export AMD_VULKAN_ICD=RADV

  # increase AMD and Intel cache size to 12GB
export MESA_SHADER_CACHE_MAX_SIZE=12G" >> .profile

# increase NVIDIA cache size to 12GB
#echo "# increase Nvidia shader cache size to 12GB
#export __GL_SHADER_DISK_CACHE_SIZE=12000000000" >> .profile

#NVIDIA Drivers (Open Source)
#pacman -S --noconfirm \
#nvidia-open-dkms nvidia-utils nvidia-settings

#(Proprietário)
#pacman -S --needed --noconfirm \
#nvidia-dkms nvidia-utils nvidia-settings

#mkinitcpio -P

#instalações de aplicativos extras
#mkdir Openrgb
#mv ./*AppImage Openrgb/
#cd Openrgb/
#wget "https://openrgb.org/releases/release_0.9/openrgb-udev-install.sh"
#chmod +x openrgb-udev-install.sh
#bash openrgb-udev-install.sh
#cd ../
wget "https://sourceforge.net/projects/ventoy/files/v1.1.10/ventoy-1.1.10-linux.tar.gz/download"
mkdir Ventoy
mv ./*download Ventoy
cd Ventoy/
tar -xvf ./*download
rm ./*download
cd ../

#<Flatpak>
#pacman -S flatpak --noconfirm
#pacman -S flatseal --noconfirm
#flatpak update
#pacman -S davinci-resolve --noconfirm

#install packages

pacman -S --needed --noconfirm \
  nano bitwarden fastfetch gdu keepassxc \
  firefox mpv gstreamer gst-plugins-bad \
  gst-plugins-good gst-plugins-base gst-libav \
  gst-plugins-ugly ffmpeg base-devel gufw \
  wine winetricks steam lutris libreoffice-still \
  xorg mesa lib32-mesa xdg-users-dirs flameshot \
  tldr foliate speedtest-cli aria2 claws-mail \
  freecad timeshift cmus bleachbit 
  
pacman -S --needed --noconfirm \
  pacman-contrib archlinux-contrib curl fakeroot \
  htmlq diffutils hicolor-icon-theme python python-pyqt6 \
  qt6-svg glib2 xdg-utils

#Lidar com pacotes .pacnew e pacotes órfãos
pacdiff
#pacman -Qdtq | pacman -Rns -

#yay AUR
git clone "https://aur.archlinux.org/yay-bin.git"
git clone "https://aur.archlinux.org/topgrade-bin.git"

#end
echo "Instale o dnsmasq e habilite ou descomente domain-needed, bogus-priv e bind-interface em /etc/dnsmasq.conf | Reinicie o sistema, amigão"
