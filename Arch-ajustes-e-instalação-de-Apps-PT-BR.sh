#!/bin/bash
#Ajustes e instalação de Apps PT BR - Instalação de aplicativos e alguns ajustes com base no sistema em Português.

#Elevação do usuário ao root (CUIDADO)
whoami || exit

#check updates
pacman -Syu && pacman -Sy --needed archlinux-keyring && pacman -Su && pacman -Syu

#grub-config microcódigo
pacman -S amd-ucode -s

#Modo root
grub-mkconfig -o /boot/grub/grub.cfg || exit

#set keyboard
setxkbmap -model abnt2 -layout br
loadkeys br-abnt2

#pacman-contrib (empty cache weekly)
pacman -S pacman-contrib -s
systemctl enable paccache.timer || exit
systemctl start paccache.timer || exit

#update
pacman -Sy

#Earlyoom Daemon Linux
pacman -S earlyoom -s
systemctl enable earlyoom || exit

echo "# Default settings for earlyoom. This file is sourced by /bin/sh from
# /etc/init.d/earlyoom or by systemd from earlyoom.service.

# Available minimum memory 15% and free minimum swap 5%
# EARLYOOM_ARGS="-m 15 -s 5"

EARLYOOM_ARGS="-r 0 -m 2 -M 256000 --prefer '^(Web Content|Isolated Web Co)$' --avoid '^(dnf|apt|pacman|rpm-ostree|packagekitd|gnome-shell|gnome-session-c|gnome-session-b|lightdm|sddm|sddm-helper|gdm|gdm-wayland-ses|gdm-session-wor|gdm-x-session|Xorg|Xwayland|systemd|systemd-logind|dbus-daemon|dbus-broker|cinnamon|cinnamon-sessio|kwin_x11|kwin_wayland|plasmashell|ksmserver|plasma_session|startplasma-way|sway|i3|xfce4-session|mate-session|marco|lxqt-session|openbox|cryptsetup)$'"" > /etc/default/earlyoom
systemctl start earlyoom || exit

#Escalonador De Disco

echo " # define o escalonador para NVMe
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
# define o escalonador para SSD e eMMC
ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
# define o escalonador para discos rotativos
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"" > /etc/udev/rules.d/60-ioschedulers.rule || exit

#shader booster
echo "# enforce RADV vulkan implementation for AMD GPUs
export AMD_VULKAN_ICD=RADV

  # increase AMD and Intel cache size to 12GB
export MESA_SHADER_CACHE_MAX_SIZE=12G" >> .profile

#increase NVIDIA cache size to 12GB
#echo "# increase Nvidia shader cache size to 12GB
#export __GL_SHADER_DISK_CACHE_SIZE=12000000000" >> .profile

#NVIDIA Drivers (Open source)
#pacman -S nvidia-open-dkms nvidia-utils nvidia-settings -s

#Proprietário
#pacman -S nvidia-dkms nvidia-utils nvidia-settings -s
#mkinitcpio -P || exit

#optional apps#
#pacman -S davinci-resolve -s
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
tar -xvf ./*download || exit
rm ./*download || exit
cd ../ || exit

#<Flatpak>
#pacman -S flatpak -s
#pacman -S flatseal -s
#flatpak update

#install packages
pacman -S linux-headers -s
pacman -S linux-lts-headers -s
pacman -S nano -s
pacman -S gdu -s
pacman -S bitwarden -s
pacman -S fastfetch -s
pacman -S keepassxc -s
pacman -S firefox -s
pacman -S mpv -s
pacman -S gstreamer -s
pacman -S gst-libav -s
pacman -S gst-plugins-bad -s
pacman -S gst-plugins-good -s
pacman -S gst-plugins-base -s
pacman -S gst-plugins-ugly -s
pacman -S ffmpeg -s
pacman -S base-devel -s
pacman -S gufw -s
pacman -S wine -s
pacman -S winetricks -s
pacman -S steam -s
pacman -S lutris -s
pacman -S libreoffice-still -s
pacman -S --needed xorg -s
#pacman -S xorg-apps -s
#pacman -S xorg-server -s
pacman -S mesa -s
pacman -S lib32-mesa -s
pacman -S xdg-users-dirs -s
pacman -S flameshot -s
pacman -S tldr -s
pacman -S foliate -s
pacman -S speedtest-cli -s
pacman -S aria2 -s
pacman -S claws-mail -s
pacman -S freecad -s
pacman -S timeshift -s
pacman -S cmus -s
pacman -S bleachbit -s
#pacman -S --needed bash systemd pacman pacman-contrib archlinux-contrib curl fakeroot htmlq diffutils hicolor-icon-theme python python-pyqt6 qt6-svg glib2 xdg-utils

#Lidar com pacotes .pacnew
pacdiff || exit

#yay AUR
git clone "https://aur.archlinux.org/yay-bin.git"
git clone "https://aur.archlinux.org/topgrade-bin.git"

#end
echo "Instale o dnsmasq e habilite ou descomente domain-needed, bogus-priv e bind-interface em /etc/dnsmasq.conf. Se deu alguma merda, volte e resolva | Reinicie o sistema, amigão"
