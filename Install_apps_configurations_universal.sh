#!/usr/bin/env bash
#-------------------------------------------------------------
# Nome: Universal Linux Setup
# Suporte: Arch | Debian/Ubuntu | Fedora
#-------------------------------------------------------------

set -euo pipefail
IFS=$'\n\t'

#------------------LOG-----------------
log() { echo -e "\e[1;32m[INFO]\e[0m $1"; }
warn() { echo -e "\e[1;33m[WARN]\e[0m $1"; }
error() { echo -e "\e[1;31m[ERRO]\e[0m $1" >&2; }

#------------------ROOT AUTO-----------------
if [[ $EUID -ne 0 ]]; then
  exec sudo "$0" "$@"
fi

#------------------DETECT DISTRO-----------------
detect_distro() {
  . /etc/os-release

  case "$ID" in
    arch) DISTRO="arch" ;;
    ubuntu|debian|linuxmint|pop) DISTRO="debian" ;;
    fedora) DISTRO="fedora" ;;
    *) DISTRO="unknown" ;;
  esac

  log "Distro detectada: $DISTRO"
}

#------------------PKG MANAGER-----------------
update_system() {
  log "Atualizando sistema..."

  case "$DISTRO" in
    arch) pacman -Syu --noconfirm ;;
    debian) apt update -y && apt upgrade -y ;;
    fedora) dnf upgrade -y ;;
  esac
}

install_pkg() {
  case "$DISTRO" in
    arch) pacman -S --noconfirm --needed "$@" ;;
    debian) apt install -y "$@" ;;
    fedora) dnf install -y "$@" ;;
  esac
}

#------------------MAPA DE PACOTES-----------------
pkg_map() {
  case "$DISTRO" in
    debian)
      case "$1" in
        linux-lts-headers) echo "linux-headers-amd64" ;;
        gufw) echo "gufw" ;;
        base-devel) echo "build-essential" ;;
        *) echo "$1" ;;
      esac
      ;;
    fedora)
      case "$1" in
        linux-lts-headers) echo "kernel-devel" ;;
        gufw) echo "firewall-config" ;;
        base-devel) echo "@development-tools" ;;
        *) echo "$1" ;;
      esac
      ;;
    *)
      echo "$1"
      ;;
  esac
}

#------------------SISTEMA-----------------

configure_grub() {
  if command -v grub-mkconfig &>/dev/null; then
    log "Atualizando GRUB..."
    grub-mkconfig -o /boot/grub/grub.cfg
  else
    warn "GRUB não encontrado"
  fi
}

#------------------CONFIG-----------------

configure_sysctl() {
  log "Configurando sysctl..."

  cat <<'EOF' > /etc/sysctl.d/99-custom.conf
vm.swappiness=100
vm.vfs_cache_pressure=50
fs.file-max=2097152
vm.max_map_count=524288
EOF
}

configure_swapfile() {
  log "Configurando swapfile..."

  if [[ ! -f /swapfile ]]; then
    fallocate -l 4G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
  else
    warn "Swap já existe"
  fi
}

configure_flatpak() {
  log "Instalando Flatpak..."
  install_pkg flatpak

  if command -v flatpak &>/dev/null; then
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  fi
}

configure_bashrc() {
  log "Configurando bashrc..."

  cat <<'EOF' > ~/.bashrc
alias ls="ls --color=auto"
alias l="ls -l"
alias la="ls -a"
alias update="sudo apt update && sudo apt upgrade"
PS1='\u@\h:\w\$ '
EOF
}

#------------------PACOTES-----------------

install_base_packages() {
  log "Instalando pacotes base..."

  install_pkg \
    $(pkg_map nano) \
    $(pkg_map firefox) \
    $(pkg_map mpv) \
    $(pkg_map ffmpeg) \
    $(pkg_map git) \
    $(pkg_map curl)
}

#------------------SERVIÇOS-----------------

enable_services() {
  log "Habilitando serviços..."

  if command -v systemctl &>/dev/null; then
    systemctl enable --now bluetooth 2>/dev/null || true
  fi
}

#------------------LIMPEZA-----------------

cleanup_system() {
  log "Limpando sistema..."

  case "$DISTRO" in
    arch) pacman -Scc --noconfirm ;;
    debian) apt autoremove -y ;;
    fedora) dnf autoremove -y ;;
  esac
}

#------------------MAIN-----------------

main() {
  detect_distro

  update_system
  configure_grub
  configure_sysctl
  configure_swapfile
  configure_flatpak
  configure_bashrc
  install_base_packages
  enable_services
  cleanup_system

  log "Setup finalizado 🚀"
}

main "$@"
