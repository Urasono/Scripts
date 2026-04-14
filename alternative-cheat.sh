#!/usr/bin/env bash
#Desc: Um assistente do cheat.sh com curl automatizado
#Autor: Urasono
#Versão: 1.0
#----------------------------------------------

#--------------Verificação do curl-------------

	if ! command -v curl >/dev/null 2>&1; then
    echo "Curl não instado"
  exit 1
fi

#--------Passagem de Argumento------------------
	if [[ -z "$1" ]]; then
    echo "uso: $0 <comando>"
    echo "exemplo: $0 ls"
  exit 1
fi

#------------Variável--------------------------

QUERY="$*"

curl -s "https://cheat.sh/$QUERY"

#-----------------------------------------------
