#!/usr/bin/env bash
#Desc: Script para automação de cheat.sh com o curl | Menu Interativo | cache | fzf
#Autor: Urasono
#Versão: 1.0
#-----------------------------------------------
#Variáveis

CACHE_DIR="${HOME}/.cache/cht"
mkdir -p "$CACHE_DIR"

#Funções complementares


has() {

   command -v "$1" >/dev/null 2>&1
}

die() {

   echo "Erro: $1"
   exit 1
}

fetch_cheat() {
    local query="$1"
    local cache_file="${CACHE_DIR}/$(echo "$query" | tr ' /' '__')"

#Verificação do cache

	if [[ -f "$cache_file" ]]; then
    cat "$cache_file"
  return
fi

#Verificação online

	if has curl; then
	  curl -s "https://cheat.sh/${query}?T" | tee "$cache_file"
  else
    die "Curl não instalado"
  fi
}

list_topics() {

   curl -s "https://cheat.sh/:list"
}

interactive_mode() {

   has fzf || die "fzf não está instalado"

   local query
   query=$(list_topics | fzf --prompt="Buscar cheat > ")

   [[ -z "$query" ]] && exit 0
   fetch_cheat "$query" | less -R
}

clear_cache() {

   rm -rf "${CACHE_DIR:?}"/*
   echo "Cache limpo"
}

show_help() {
    cat <<EOF
Uso: cht [OPÇÕES] [QUERY]

Exemplos:
  cht tar
  cht "docker run"
  cht python/list

Opções:
  -i, --interactive   Modo interativo com fzf
  -l, --list          Listar tópicos disponíveis
  -c, --clear-cache   Limpar cache
  -h, --help          Mostrar ajuda
EOF
}

#Parse de argumentos

case "$1" in
    -i|--interactive)
        interactive_mode
        ;;
    -l|--list)
        list_topics
        ;;
    -c|--clear-cache)
        clear_cache
        ;;
    -h|--help)
        show_help
        ;;
    *)
        if [[ -z "$1" ]]; then
            interactive_mode
        else
            QUERY="$*"
            fetch_cheat "$QUERY" | less -R
        fi
        ;;
esac
