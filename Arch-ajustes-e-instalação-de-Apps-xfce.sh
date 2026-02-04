#!/bin/bash
#Ajustes e instalação de Apps xfce - Ajustes e instalações de aplicativos no Arch linux, porém, com base no sistema em Inglês focando no uso com o XFCE.

#check updates
sudo pacman -Sy
sudo pacman -Syu

#grub-config microcódigo
sudo pacman -S amd-ucode -y
#grub-mkconfig -o /boot/grub/grub.cfg

#set keyboard
setxkbmap -model abnt2 -layout br
loadkeys br-abnt2

#pacman-contrib (empty cache weekly)
sudo pacman -S  pacman-contrib -y
systemctl enable --now paccache.timer

#update
sudo pacman -Sy

#remoção da mitigação split-lock
sudo rm -r /etc/sysctl.d/99-splitlock.conf

#Earlyoom Daemon Linux
sudo pacman -S earlyoom -y
sudo systemctl enable --now earlyoom
#sudo echo ""EARLYOOM_ARGS="-r 0 -m 2 -M 256000 --prefer '^(Web Content|Isolated Web Co)$' --avoid '^(dnf|apt|pacman|rpm-ostree|packagekitd|gnome-shell|gnome-session-c|gnome-session-b|lightdm|sddm|sddm-helper|gdm|gdm-wayland-ses|gdm-session-wor|gdm-x-session|Xorg|Xwayland|systemd|systemd-logind|dbus-daemon|dbus-broker|cinnamon|cinnamon-sessio|kwin_x11|kwin_wayland|plasmashell|ksmserver|plasma_session|startplasma-way|sway|i3|xfce4-session|mate-session|marco|lxqt-session|openbox|cryptsetup)$" > /etc/default/earlyoom
#systemctl restart earlyoom

#shader booster
echo "# enforce RADV vulkan implementation for AMD GPUs
export AMD_VULKAN_ICD=RADV

  # increase AMD and Intel cache size to 12GB
export MESA_SHADER_CACHE_MAX_SIZE=12G" >> .profile

  # increase NVIDEA cache size to 12GB
#echo "# increase Nvidia shader cache size to 12GB
#export __GL_SHADER_DISK_CACHE_SIZE=12000000000" >> .profile

#optional apps

#sudo pacman -S davinci-resolve -y
wget "https://codeberg.org/OpenRGB/OpenRGB/releases/download/release_candidate_1.0rc2/OpenRGB_1.0rc2_x86_64_0fca93e.AppImage"
mkdir Openrgb || exit
mv ./*AppImage Openrgb/ || exit
cd Openrgb/ || exit
wget "https://openrgb.org/releases/release_0.9/openrgb-udev-install.sh"
chmod +x openrgb-udev-install.sh
bash openrgb-udev-install.sh
cd ../ || exit
wget "https://sourceforge.net/projects/ventoy/files/v1.1.10/ventoy-1.1.10-linux.tar.gz/download"
mkdir Ventoy || exit
mv ./*download Ventoy/ || exit
cd Ventoy/ || exit
tar -xvf download || exit
rm ./*download || exit
cd ../ || exit
#sudo pacman -S flatpak -y
#sudo pacman -S flatseal -y
#flatpak update

#install packages
sudo pacman -S linux-headers -y
sudo pscman -S nano -y
sudo pacman -S bitwarden -y
sudo pacman -S fastfetch -y
sudo pacman -S gdu -y
sudo pacman -S keepassxc -y
sudo pacman -S firefox -y
sudo pacman -S mpv -y
sudo pacman -S btop -y
sudo pacman -S gstreamer -y
sudo pacman -S gst-plugins-bad -y
sudo pacman -S gst-plugins-good -y
sudo pacman -S gst-plugins-base -y
sudo pacman -S gst-libav -y
sudo pacman -S gst-plugins-ugly -y
sudo pacman -S ffmpeg -y
sudo packan -S base-devel -y
sudo pacman -S gufw -y
sudo pacman -S wine -y
sudo pacman -S winetricks -y
sudo pacman -S steam -y
sudo pacman -S lutris -y
sudo pacman -S libreoffice-still -y
sudo pacman -S xorg -y
sudo pacman -S xorg-server -y
sudo pacman -S xorg-apps -y
sudo pacman -S mesa -y
sudo pacman -S lib32-mesa -y
sudo pacman -S xdg-users-dirs -y
sudo pacman -S flameshot -y
sudo pacman -S nfoview -y
sudo pacman -S foliate -y
sudo pacman -S speedtest-cli -y
sudo pacman -S aria2 -y
sudo pacman -S thunderbird -y
sudo pacman -S freecad -y
sudo pacman -S timeshift -y
sudo pacman -S cmus -y
sudo pacman -S xfce4 -y
sudo pacman -S xfce4-goodies -y

#yay AUR
git clone "https://aur.archlinux.org/yay-bin.git"
cd yay-bin || exit
makepkg -si || exit

#end
echo "Instale o dnsmasq e habilite ou descomente domain-needed, bogus-priv e bind-interface em /etc/dnsmasq.conf | Reinicie o sistema, amigão"
