#!/usr/bin/bash
#-------------------------------------------------------------
#Nome: Arch Ajustes e instalação de apps
#Descrição: Ajustes no Arch linux e instalação de aplicativos
#Autor: Urasono
#Versão: 1.1
#-----------------------------------------------
set -euo pipefail
IFS=$'\n\t'

# ----------------- Helpers -----------------
log() { printf '\033[1;32m[INFO]\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m[WARN]\033[0m %s\n' "$1"; }
error() { printf '\033[1;31m[ERRO]\033[0m %s\n' "$1" >&2; }

#required_root
  if [[ $EUID -ne 0 ]]; then
    error "Você precisa ser root!"
    exit 1
  fi

# ----------------- System actions -----------------

#Atualizar o sistema
  log "Atualizando sistema"
  pacman -Sy --needed archlinux-keyring --noconfirm || warn "Falha ao atualizar keyring"
  pacman -Su --noconfirm || warn "Falha em pacman -Su"

#Instalação de microcódigos
  log "Instalando microcode se aplicável"
  pacman -S --needed --noconfirm intel-ucode || warn "Falha ao instalar intel-ucode"

#configurando o sysctl
  log "Configurando /etc/sysctl.d/99-custom.conf"
  cat <<'EOF' > /etc/sysctl.d/99-custom.conf
kernel.split_lock_mitigate=0
vm.swappiness=100
vm.vfs_cache_pressure=50
vm.dirty_bytes=268435456
kernel.nmi_watchdog=0
kernel.printk=3 3 3 3
net.core.netdev_max_backlog=4096
fs.file-max=2097152
vm.page-cluster=0
vm.max_map_count=524288
EOF

#configurando o journal
  log "Limitando journal"
  mkdir -p /etc/systemd/journal.conf.d
  cat <<'EOF' >/etc/systemd/journal.conf.d/size.conf
[Journal]
SystemMaxUse=50M
EOF

#configurando o zram
  log "Configurando zram"
  pacman -S --needed --noconfirm zram-generator || { warn "Não foi possível instalar zram-generator"; return; }
  cat <<'EOF' > /etc/systemd/zram-generator.conf
[zram0]
zram-size = min(ram / 2, 8192)
compression-algorithm = zstd
EOF
  # Enable generator-managed unit (systemd will create the setup unit)
  systemctl daemon-reload || true

#configuração_do_bashrc
  log "Atualizando ~/.bashrc"
  cat <<'EOF' >> ~/.bashrc
[[ $- != *i* ]] && return
alias ls="ls --color=auto"
alias l="ls -l"
alias la="ls -a"
alias up="pacman -Sy"
alias upgd="pkg -Syu"
alias ouvir="mpv --no-video --ytdl-format='bestaudio[acodec^=opus]'"
alias ver="mpv --ytdl-format='bestvideo[height<=720][vcodec^=avc1]+bestaudio[acodec^=opus]'"
PS1='\[\e[1;95m\]\u@\h\[\e[0m\] \[\e[1;93m\]\w\[\e[0m\]\n\[\e[38;5;46m\]╰➜\[\e[0m\] $ '
EOF

#configurando_udev_rules
  log "Escrevendo regras udev úteis"
  mkdir -p /etc/udev/rules.d
  cat <<'EOF' > /etc/udev/rules.d/20-audio-pm.rules
# Disables power saving capabilities for snd-hda-intel when device is not
# running on battery power. This is needed because it prevents audio cracks on
# some hardware.
ACTION=="add", SUBSYSTEM=="sound", KERNEL=="card*", DRIVERS=="snd_hda_intel", TEST!="/run/udev/snd-hda-intel-powersave", \
    RUN+="/usr/bin/bash -c 'touch /run/udev/snd-hda-intel-powersave; \
        [[ \$(cat /sys/class/power_supply/BAT0/status 2>/dev/null) != \"Discharging\" ]] && \
        echo \$(cat /sys/module/snd_hda_intel/parameters/power_save) > /run/udev/snd-hda-intel-powersave && \
        echo 0 > /sys/module/snd_hda_intel/parameters/power_save'"

SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", TEST=="/sys/module/snd_hda_intel", \
    RUN+="/usr/bin/bash -c 'echo \$(cat /run/udev/snd-hda-intel-powersave 2>/dev/null || echo 10) > /sys/module/snd_hda_intel/parameters/power_save'"

SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", TEST=="/sys/module/snd_hda_intel", \
    RUN+="/usr/bin/bash -c '[[ \$(cat /sys/module/snd_hda_intel/parameters/power_save) != 0 ]] && \
        echo \$(cat /run/udev/snd-hda-intel-powersave 2>/dev/null || echo 10) > /sys/module/snd-hda-intel-powersave; \
        echo 0 > /sys/module/snd_hda_intel/parameters/power_save'"
EOF

  cat <<'EOF' > /etc/udev/rules.d/99-cpu-dma-latency.rules
DEVPATH=="/devices/virtual/misc/cpu_dma_latency", OWNER="root", GROUP="audio", MODE="0660"
EOF

#configurando_tmpfiles
  log "Configurando tmpfiles para tcmalloc"
  cat <<'EOF' > /etc/tmpfiles.d/thp.conf
# Improve performance for applications that use tcmalloc
# https://github.com/google/tcmalloc/blob/master/docs/tuning.md#system-level-optimizations
w! /sys/kernel/mm/transparent_hugepage/defrag - - - - defer+madvise
EOF

#configurando_shader_booster
  log "Aplicando variáveis de ambiente para cache de shader"
  
  cat <<'EOF' >> /etc/.profile

#NVIDIA

increase Nvidia shader cache size to 8GB
export __GL_SHADER_DISK_CACHE_SIZE=8000000000
EOF

#configurando_disk_scheduler
  log "Escrevendo regras de IO scheduling (somente como exemplo, comentadas)"
  cat <<'EOF' > /etc/udev/rules.d/60-ioschedulers.rules
# define o escalonador para NVMe
#ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
# define o escalonador para SSD e eMMC
#ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
# define o escalonador para discos rotativos
#ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
EOF

#----------------- Drivers -----------------
#instalação_nvidia_proprietário
  log "Instalando drivers NVIDIA proprietários"
  pacman -S --needed --noconfirm nvidia-dkms nvidia-utils nvidia-settings lib32-nvidia-utils || warn "Falha ao instalar nvidia-dkms"

  cat <<'EOF' > /etc/modprobe.d/nvidia.conf
options nvidia_drm modeset=1
EOF

   cat <<'EOF' > /etc/mkinitcpio.conf
MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)

mkinitcpio -P || warn "mkinitcpio falhou"
#
EOF

#install_nvidia_open_source
#  log "Instalando drivers NVIDIA open (nouveau)"
 # pacman -S --needed --noconfirm xf86-video-nouveau || warn "Falha ao instalar xf86-video-nouveau"

  #cat <<'EOF' > /etc/modprobe.d/nvidia.conf
#options nvidia_drm modeset=1
#EOF


#instalação_amd_drivers
#  log "Instalando drivers AMD mesa"
# pacman -S --needed --noconfirm mesa vulkan-radeon lib32-vulkan-radeon lib32-mesa || warn "Falha ao instalar mesa"

install_intel_drivers() {
  log "Instalando drivers Intel mesa"
  pacman -S --needed --noconfirm mesa vulkan-intel lib32-vulkan-intel lib32-mesa || warn "Falha ao instalar mesa"
}

# ----------------- Pacotes -----------------
#instalação_pacotes_básicos
  log "Instalando pacotes base (pacman)"
  pacman -S --needed --noconfirm \
nano linux-firmware bitwarden fastfetch keepassxc firefox mpv gstreamer gst-plugins-bad gst-plugins-good gst-plugins-base gst-libav gst-plugins-ugly ffmpeg base-devel gufw fwupd wine winetricks steam lutris libreoffice-still protonup-qt xorg mesa lib32-mesa xdg-user-dirs flameshot foliate speedtest-cli aria2 claws-mail freecad timeshift cmus bleachbit linux-headers linux-lts-headers yt-dlp lm_sensors dhcp || warn "Falha em instalar alguns pacotes"

#instalação_pacotes_extras
  log "Instalando pacotes extras"
  pacman -S --needed --noconfirm pacman-contrib archlinux-contrib curl fakeroot htmlq diffutils hicolor-icon-theme python python-pyqt6 qt6-svg glib2 xdg-utils || warn "Falha em instalar extras"

install_optional_packages() {
  log "Tarefas opcionais (Ventoy exemplo)"
  mkdir -p ~/Ventoy && cd ~/Ventoy || return
  wget -q --show-progress "https://sourceforge.net/projects/ventoy/files/v1.1.11/ventoy-1.1.11-linux.tar.gz/download" -O Ventoy.tar.gz || { warn "wget falhou"; return; }
  tar -xzf Ventoy.tar.gz || warn "tar falhou"
  cd --
}

Paccache() {
  log "Habilitando serviços úteis"
  systemctl enable --now paccache.timer || true
  pacman -S --needed --noconfirm earlyoom || true
  systemctl enable --now fwupd.service || true
}
Earlyoom() {
  cat <<'EOF' > /etc/default/earlyoom
EARLYOOM_ARGS="-r 0 -m 2 -M 256000 --prefer '^(Web Content|Isolated Web Co)$' --avoid '^(dnf|apt|pacman|rpm-ostree|packagekitd|gnome-shell|gdm|sddm|Xorg|Xwayland|systemd)$'"
EOF
}

cleanup_system() {
  log "Removendo dependências órfãs"
 local orphans
 orphans=$(pacman -Qdtq || true)
  if [[ -n "$orphans" ]]; then
    pacman -Rns --noconfirm -- "${orphans}" || warn "Falha ao remover órfãos"
  fi
}

# ----------------- Functions-------------------
configure_cpu_power() {
}

configure_flatpak() {
  log "Configurando Flatpak"
  if ! command_exists flatpak; then
    pacman -S --needed --noconfirm flatpak || {
      warn "Falha ao instalar flatpak"
      return 1
    }
  fi

  if ! flatpak remote-list | grep -q flathub; then
    flatpak remote-add --if-not-exists flathub \
https://flathub.org/repo/flathub.flatpakrepo || warn "Falha ao adicionar flathub"
  fi
}
