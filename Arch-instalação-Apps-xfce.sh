#!/bash/bin

  #check updates
  sudo pacman -Sy
  sudo pacman -Syu

  #set keyboard
  setxkbmap -model abnt2 -layout br
  loadkeys br-abnt2

  #pacman-contrib (empty cache weekly)
  sudo pacman -S  pacman-contrib -y
  systemctl enable --now paccache.timer

  #update
  sudo pacman -Sy

  #install packages
  sudo pscman -S nano -y
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

  sudo pacman -S xfce4 -s
  sudo pacman -S xfce4-goodies -s
