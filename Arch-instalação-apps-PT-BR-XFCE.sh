#!/bash/bin

  #check updates
  sudo pacman -Sy -s
  sudo pacman -Syu

  #set keyboard
  setxkbmap -model abnt2 -layout br
  loadkeys br-abnt2

  #pacman-contrib (empty cache weekly)
  sudo pacman -S  pacman-contrib -s
  systemctl enable --now paccache.timer

  #update
  sudo pacman -Sy

  #remoção da mitigação split-lock
  sudo rm -r /etc/sysctl.d/99-splitlock.conf

  #install packages
  sudo pscman -S nano -s
  sudo pacman -S gdu -s
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
  sudo pacman -S xorg-server -s
  sudo pacman -S xorg-apps -s
  sudo pacman -S mesa -s
  sudo pacman -S lib32-mesa -s
  sudo pacman -S xdg-users-dirs -s
  sudo pacman -S flameshot -s
  sudo pacman -S nfoview -s
  sudo pacman -S foliate -s
  sudo pacman -S speedtest-cli -s
  sudo pacman -S aria2 -s
  sudo pacman -S thunderbird -s
  sudo pacman -S freecad -s
  sudo pacman -S timeshift -s
  sudo pacman -S xfce4 -s
  sudo pacman -S xfce4-goodies -s
