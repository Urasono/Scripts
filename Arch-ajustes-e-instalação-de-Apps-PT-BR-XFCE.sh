#!/bin/bash
#Ajustes e instalação de Apps xfce PT BR - Ajustes no Arch linux e instalação de aplicativos com base no sistema em Português e buscando a instalação da interface gráfica XFCE.

#Elevação de usuário ao root (CUIDADO)
su || exit

#check updates
pacman -Sy
pacman -Syu
pacman-key --refresh-keys
pacman -Syu archlinux-keyring

#grub-config microcódigo
pacman -S amd-ucode -s

#modo root
update-grub || exit

#set keyboard
setxkbmap -model abnt2 -layout br
loadkeys br-abnt2

#pacman-contrib (empty cache weekly)
pacman -S pacman-contrib -s
systemctl enable paccache.timer || exit
systemctl start paccache.timer || exit

#update
pacman -Sy

#remoção da mitigação split-lock
echo "kernel.split_lock_mitigate=0" > /etc/sysctl.d/99-splitlock.conf || exit

#Earlyoom Daemon Linux
pacman -S earlyoom -s
systemctl enable earlyoom || exit
systemctl start earlyoom || exit
# echo ""EARLYOOM_ARGS="-r 0 -m 2 -M 256000 --prefer '^(Web Content|Isolated Web Co)$' --avoid '^(dnf|apt|pacman|rpm-ostree|packagekitd|gnome-shell|gnome-session-c|gnome-session-b|lightdm|sddm|sddm-helper|gdm|gdm-wayland-ses|gdm-session-wor|gdm-x-session|Xorg|Xwayland|systemd|systemd-logind|dbus-daemon|dbus-broker|cinnamon|cinnamon-sessio|kwin_x11|kwin_wayland|plasmashell|ksmserver|plasma_session|startplasma-way|sway|i3|xfce4-session|mate-session|marco|lxqt-session|openbox|cryptsetup)$" > /etc/default/earlyoom

#shader booster
echo "# enforce RADV vulkan implementation for AMD GPUs
export AMD_VULKAN_ICD=RADV

  # increase AMD and Intel cache size to 12GB
export MESA_SHADER_CACHE_MAX_SIZE=12G" >> .profile

# increase NVIDEA cache size to 12GB
#echo "# increase Nvidia shader cache size to 12GB
#export __GL_SHADER_DISK_CACHE_SIZE=12000000000" >> .profile

#instalações de aplicativos extras
mkdir Openrgb || exit
mv ./*AppImage Openrgb/ || exit
cd Openrgb/ || exit
wget "https://openrgb.org/releases/release_0.9/openrgb-udev-install.sh"
chmod +x openrgb-udev-install.sh
bash openrgb-udev-install.sh
cd ../ || exit
wget "https://sourceforge.net/projects/ventoy/files/v1.1.10/ventoy-1.1.10-linux.tar.gz/download"
mkdir Ventoy || exit
mv ./*download Ventoy || exit
cd Ventoy/ || exit
tar -xvf ./*download || exit
rm ./*download || exit
cd ../ || exit
#pacman -S flatpak -s
#pacman -S flatseal -s
#flatpak update
#pacman -S davinci-resolve -s

#install packages
pacman -S linux-headers -s
pacman -S nano -s
pacman -S bitwarden -s
pacman -S gdu -s
pacman -S fastfetch -s
pacman -S keepassxc -s
pacman -S firefox -s
pacman -S mpv -s
pacman -S btop -s
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
pacman -S xorg -s
pacman -S xorg-apps -s
pacman -S xorg-server -s
pacman -S mesa -s
pacman -S lib32-mesa -s
pacman -S xdg-users-dirs -s
pacman -S flameshot -s
pacman -S foliate -s
pacman -S speedtest-cli -s
pacman -S aria2 -s
pacman -S claws-mail -s
pacman -S freecad -s
pacman -S timeshift -s
pacman -S xfce4 -s
pacman -S xfce4-goodies -s
pacman -S cmus -s
pacman -S tldr -s

#yay AUR
git clone "https://aur.archlinux.org/yay-bin.git"

#end
echo "Instale o dnsmasq e habilite ou descomente domain-needed, bogus-priv e bind-interface em /etc/dnsmasq.conf | Reinicie o sistema, amigão"
