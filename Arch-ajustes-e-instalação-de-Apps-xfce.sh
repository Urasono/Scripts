#!/usr/bin/env bash
#Ajustes e instalação de Apps xfce - Ajustes e instalações de aplicativos no Arch linux, porém, com base no sistema em Inglês focando no uso com o XFCE.

#Elevação do usuário ao root (CUIDADO)
whoami || exit

#check updates
pacman -Syu && pacman -Sy --needed archlinux-keyring

#grub-config microcódigo
pacman -S amd-ucode -y

#Modo root
grub-mkconfig -o /boot/grub/grub.cfg || exit

#set keyboard
setxkbmap -model abnt2 -layout br
loadkeys br-abnt2

#pacman-contrib (empty cache weekly)
pacman -S pacman-contrib -y
systemctl enable paccache.timer || exit
systemctl start paccache.timer || exit

#update
pacman -Sy

#Earlyoom Daemon Linux
pacman -S earlyoom -y
systemctl enable earlyoom || exit

echo "# Default settings for earlyoom. This file is sourced by /bin/sh from
# /etc/init.d/earlyoom or by systemd from earlyoom.service.

# Available minimum memory 15% and free minimum swap 5%
# EARLYOOM_ARGS="-m 15 -s 5"

EARLYOOM_ARGS="-r 0 -m 2 -M 256000 --prefer '^(Web Content|Isolated Web Co)$' --avoid '^(dnf|apt|pacman|rpm-ostree|packagekitd|gnome-shell|gnome-session-c|gnome-session-b|lightdm|sddm|sddm-helper|gdm|gdm-wayland-ses|gdm-session-wor|gdm-x-session|Xorg|Xwayland|systemd|systemd-logind|dbus-daemon|dbus-broker|cinnamon|cinnamon-sessio|kwin_x11|kwin_wayland|plasmashell|ksmserver|plasma_session|startplasma-way|sway|i3|xfce4-session|mate-session|marco|lxqt-session|openbox|cryptsetup)$'"" > /etc/default/earlyoom
systemctl start earlyoom || exit

#Escalonador De Disco
echo ' # define o escalonador para NVMe
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
# define o escalonador para SSD e eMMC
ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
# define o escalonador para discos rotativos
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"' > /etc/udev/rules.d/60-ioschedulers.rule || exit

#shader booster
echo "# enforce RADV vulkan implementation for AMD GPUs
export AMD_VULKAN_ICD=RADV

  # increase AMD and Intel cache size to 12GB
export MESA_SHADER_CACHE_MAX_SIZE=12G" >> .profile

  # increase NVIDIA cache size to 12GB
#echo "# increase Nvidia shader cache size to 12GB
#export __GL_SHADER_DISK_CACHE_SIZE=12000000000" >> .profile

#NVIDIA Drivers (Open Source)
#pacman -S nvidia-open-dkms nvidia-utils nvidia-settings -y

#Proprietário
#pacman -S nvidia-dkms nvidia-utils nvidia-settings -y

#optional apps
#pacman -S davinci-resolve -y
#wget "https://codeberg.org/OpenRGB/OpenRGB/releases/download/release_candidate_1.0rc2/OpenRGB_1.0rc2_x86_64_0fca93e.AppImage"
#mkdir Openrgb || exit
#mv ./*AppImage Openrgb/ || exit
#cd Openrgb/ || exit
#wget "https://openrgb.org/releases/release_0.9/openrgb-udev-install.sh"
#chmod +x openrgb-udev-install.sh
#bash openrgb-udev-install.sh
#cd ../ || exit
wget "https://sourceforge.net/projects/ventoy/files/v1.1.10/ventoy-1.1.10-linux.tar.gz/download"
mkdir Ventoy || exit
mv ./*download Ventoy/ || exit
cd Ventoy/ || exit
tar -xvf download || exit
rm ./*download || exit
cd ../ || exit

#<Flatpak>
#pacman -S flatpak -y
#pacman -S flatseal -y
#flatpak update

#install packages
pacman -S linux-headers -y
pacman -S linux-lts-headers -y
pacman -S nano -y
pacman -S bitwarden -y
pacman -S fastfetch -y
pacman -S gdu -y
pacman -S keepassxc -y
pacman -S firefox -y
pacman -S mpv -y
pacman -S gstreamer -y
pacman -S gst-plugins-bad -y
pacman -S gst-plugins-good -y
pacman -S gst-plugins-base -y
pacman -S gst-libav -y
pacman -S gst-plugins-ugly -y
pacman -S ffmpeg -y
pacman -S base-devel -y
pacman -S gufw -y
pacman -S wine -y
pacman -S winetricks -y
pacman -S steam -y
pacman -S lutris -y
pacman -S libreoffice-still -y
pacman -S --needed xorg -y
pacman -S mesa -y
pacman -S lib32-mesa -y
pacman -S xdg-users-dirs -y
pacman -S flameshot -y
pacman -S tldr -y
pacman -S foliate -y
pacman -S speedtest-cli -y
pacman -S aria2 -y
pacman -S claws-mail -y
pacman -S freecad -y
pacman -S timeshift -y
pacman -S cmus -y
pacman -S xfce4 -y
pacman -S xfce4-goodies -y
pacman -S bleachbit -y
#pacman -S --needed bash systemd pacman pacman-contrib archlinux-contrib curl fakeroot htmlq diffutils hicolor-icon-theme python python-pyqt6 qt6-svg glib2 xdg-utils

#Lidar com pacotes .pacnew e pacotes órfãos
pacdiff || exit
#pacman -Qdtq | pacman -Rns - || exit

#yay AUR
git clone "https://aur.archlinux.org/yay-bin.git"
git clone "https://aur.archlinux.org/topgrade-bin.git"

#end
echo "Instale o dnsmasq e habilite ou descomente domain-needed, bogus-priv e bind-interface em /etc/dnsmasq.conf | Reinicie o sistema, amigão"
