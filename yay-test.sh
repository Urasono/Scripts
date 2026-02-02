#!/bin/bash
  #yay AUR
  git clone "https://aur.archlinux.org/yay-bin.git"
  cd yay-bin || exit
  makepkg -si || exit
