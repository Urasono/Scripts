#!/usr/bin/bash
#---------------------------------------------#
#Descrição:Instalação, manuntenção e remoção do Telegran baixado diretamente do site
#Autor:Urasono(Fork Xerxes Viva o linux)
#Versão:1.0

fail_command() {

  set -euo pipefail
}

variables() {

URL_DOWNLOAD="https://telegram.org/dl/desktop/linux"
ARQUIVO_TAR="telegram.tar.xz"
INSTALL_DIR="/opt/telegram"
BIN_PATH="$INSTALL_DIR/Telegram"
LINK_PATH="/usr/bin/telegram"
DESKTOP_FILE="$home/.local/share/applications/telegramdesktop.desktop"
}

  echo "==Gerenciador De Telegram Desktop=="



if [ -d "$INSTALL_DIR" ]; then
  echo "Telegram já instalado em $INSTALL_DIR"
  echo "O que deseja fazer?"

  echo "1) Atualizar/Reinstalar a aplicação (Versão mais recente)"

  echo "2) Remove completamente (Desinstalar)"

  echo "3) Sair"

  echo "------------------------------------------"
  read -pr "Opção: " acao

  case $acao in
2)
   echo "Removendo arquivos..."

if [ -d "$INSTALL_DIR" ]; then
  rm -rf "$INSTALL_DIR"
  echo "   Diretório de instalação removido"
fi


#Link Simbólico

if [ -L "$LINK_PATH" ]; then
  rm -rf "$LINK_PATH"
  echo "Link simbólico removido"
fi


#Atalho

if [ -f "$DESKTOP_FILE" ]; then
  rm -rf "DESKTOP_FILE"
  echo "Atalho removido"
fi

  echo "Removido o Telegram com sucesso"
exit 0
;;

0)

  echo "saindo.."
exit 0
;;

1|*)

  echo "---> Iniciando processo de atualização..."
;;
  esac
fi

#------BLOCO DE INSTALAÇÃO/ATUALIZAÇÃO----------------

create_temp() {
TEMP_DIR=$(mktemp -d)
}

install_update_extract() {

#1.Download

  echo "Baixando a versão mais recente"

wget -q --show-progress -O "$TEMP_DIR/$TAR_FILE" "$URL_DOWNLOAD"

#2.Extração

  echo "fazendo a extração..."

tar -xvf "$TEMP_DIR/$STAR_FILE" -C "$TEMP_DIR"

#3.Instalação

  echo "Fazendo a instalação em $INSTALL_DIR"

if [ -d "$INSTALL_DIR" ]; then
  echo "Removendo a versão antiga..."
  rm -rf "$INSTALL_DIR"
fi
}

create_simbolic_link_mv_dir_clean() {

  mv "$TEMP_DIR/Telegram" "$INSTALL_DIR"

#4. Link Simbólico

  echo "Criando link Simbólico..."
  ln -sf "$BIN-PATH" "$LINK_PATH"
  chmod +x "BIN_PATH"

#5. Limpeza

  rm -rf "$TEMP_DIR"
}

  echo "--------------------------------------------------"

  echo "Sucesso! Execute digitando 'telegram' no terminal. O Telegram cria o .desktop na primeira execução."

