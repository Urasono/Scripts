#!/bin/bash

  #update sync

  sudo pacman -Sy
  #install dev-tools

  git clone "https://aur.archlinux.org/paru.git"
  cd paru
  makepkg -si

  #sync again
  sudo pacman -Sy

  #end
  echo "Terminou, daddy."
