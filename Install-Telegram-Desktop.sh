#!/usr/bin/env bash
#---------------------------------------------#
#Descrição:Instalação, manuntenção e remoção do Telegran baixado diretamente do site
#Autor:Urasono(Fork Xerxes Viva o linux)
#Versão:1.0

fail_command() {

  set -euo pipefail
}

#variables

URL_DOWNLOAD="https://telegram.org/dl/desktop/linux"
ARQUIVO_TAR="telegram.tar.xz"
INSTALL_DIR="$HOME/.local/opt/telegram"
LINK_PATH="$HOME/.local/bin/telegram"
BIN_PATH="$INSTALL_DIR/Telegram"
DESKTOP_FILE="$home/.local/share/applications/telegramdesktop.desktop"

#Criação do diretório

  mkdir -p "$HOME/.local/bin"

  mkdir -p "$INSTALL_DIR"

#Verificação de dependências

  command -v wget >/dev/null || { echo "Instale wget"; exit 1; }

  command -v tar >/dev/null || { echo "instale tar"; exit 1; }

#Detecção de ambiente gráfico

if [ -z "${DISPLAY:-}" ]; then
  echo "Sem ambiente gráfico detectado"
fi
  echo "==Gerenciador De Telegram Desktop=="


if [ -d "$INSTALL_DIR" ]; then
  echo "Telegram já instalado em $INSTALL_DIR"
  echo "O que deseja fazer?"

  echo "1) Atualizar/Reinstalar a aplicação (Versão mais recente)"

  echo "2) Remove completamente (Desinstalar)"

  echo "3) Sair"

  echo "------------------------------------------"

  printf "Opção: " acao
  read -r acao
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

*)

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

wget -q --show-progress -O "$TEMP_DIR/$ARQUIVO_TAR" "$URL_DOWNLOAD"

#2.Extração

  echo "fazendo a extração..."

tar -xvf "$TEMP_DIR/$ARQUIVO_TAR" -C "$TEMP_DIR"
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
