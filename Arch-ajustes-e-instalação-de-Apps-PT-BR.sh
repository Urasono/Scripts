#!/bin/bash
#Ajustes e instalação de Apps PT BR - Instalação de aplicativos e alguns ajustes com base no sistema em Português.

#check updates
sudo pacman -Sy
sudo pacman -Syu
pacman-key --refresh-keys
sudo pacman -Syu archlinux-keyring

#grub-config microcódigo
sudo pacman -S amd-ucode -s

#Modo root
#grub-mkconfig -o /boot/grub/grub.cfg

#set keyboard
setxkbmap -model abnt2 -layout br
loadkeys br-abnt2

#pacman-contrib (empty cache weekly)
sudo pacman -S  pacman-contrib -s
systemctl enable paccache.timer
systemctl start paccache. timer

#update
sudo pacman -Sy

#remoção da mitigação split-lock
#sudo rm -r /etc/sysctl.d/99-splitlock.conf

#Earlyoom Daemon Linux
sudo pacman -S earlyoom -s
sudo systemctl enable earlyoom
sudo systemctl start earlyoom

#sudo echo ""EARLYOOM_ARGS="-r 0 -m 2 -M 256000 --prefer '^(Web Content|Isolated Web Co)$' --avoid '^(dnf|apt|pacman|rpm-ostree|packagekitd|gnome-shell|gnome-session-c|gnome-session-b|lightdm|sddm|sddm-helper|gdm|gdm-wayland-ses|gdm-session-wor|gdm-x-session|Xorg|Xwayland|systemd|systemd-logind|dbus-daemon|dbus-broker|cinnamon|cinnamon-sessio|kwin_x11|kwin_wayland|plasmashell|ksmserver|plasma_session|startplasma-way|sway|i3|xfce4-session|mate-session|marco|lxqt-session|openbox|cryptsetup)$" > /etc/default/earlyoom
sudo systemctl restart earlyoom

#shader booster
echo "# enforce RADV vulkan implementation for AMD GPUs
export AMD_VULKAN_ICD=RADV

  # increase AMD and Intel cache size to 12GB
export MESA_SHADER_CACHE_MAX_SIZE=12G" >> .profile

#increase NVIDEA cache size to 12GB
#echo "# increase Nvidia shader cache size to 12GB
#export __GL_SHADER_DISK_CACHE_SIZE=12000000000" >> .profile

#optional apps#

#sudo pacman -S davinci-resolve -s
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
tar -xvf ./*download || exit
rm ./*download || exit
cd ../ || exit
#sudo pacman -S flatpak -s
#sudo pacman -S flatseal -s
#flatpak update

#install packages
sudo pacman -S linux-headers -s
sudo pscman -S nano -s
sudo pacman -S gdu -s
sudo pacman -S bitwarden -s
sudo pacman -S fastfetch -s
sudo pacman -S keepassxc -s
sudo pacman -S firefox -s
sudo pacman -S mpv -s
sudo pacman -S btop -s
sudo pacman -S gstreamer -s
sudo pacman -S gst-libav -s
sudo pacman -S gst-plugins-bad -s
sudo pacman -S gst-plugins-good -s
sudo pacman -S gst-plugins-base -s
sudo pacman -S gst-plugins-ugly -s
sudo pacman -S ffmpeg -s
sudo packan -S base-devel -s
sudo pacman -S gufw -s
sudo pacman -S wine -s
sudo pacman -S winetricks -s
sudo pacman -S steam -s
sudo pacman -S lutris -s
sudo pacman -S libreoffice-still -s
sudo pacman -S xorg -s
sudo pacman -S xorg-apps -s
sudo pacman -S xorg-server -s
sudo pacman -S mesa -s
sudo pacman -S lib32-mesa -s
sudo pacman -S xdg-users-dirs -s
sudo pacman -S flameshot -s
sudo pacman -S tldr -s
sudo pacman -S foliate -s
sudo pacman -S speedtest-cli -s
sudo pacman -S aria2 -s
sudo pacman -S claws-mail -s
sudo pacman -S freecad -s
sudo pacman -S timeshift -s
sudo pacman -S cmus -s

#yay AUR
git clone "https://aur.archlinux.org/yay-bin.git"
cd yay-bin || exit
makepkg -si || exit

#end
echo "Instale o dnsmasq e habilite ou descomente domain-needed, bogus-priv e bind-interface em /etc/dnsmasq.conf. Se deu alguma merda, volte e resolva | Reinicie o sistema, amigão"
