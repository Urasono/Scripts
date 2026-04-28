#!/usr/bin/env bash
set -euo pipefail

# Verificar dependências
for cmd in yt-dlp jq mpv; do
    command -v "$cmd" >/dev/null 2>&1 || {
        printf "Erro: '%s' não está instalado.\n" "$cmd"
        exit 1
    }
done

tempfile=$(mktemp)
youtube_dl_log=$(mktemp)

# Cleanup automático
cleanup() {
    rm -f "$tempfile" "$youtube_dl_log"
}
trap cleanup EXIT

# Escolher resolução
printf "Escolha a qualidade desejada:\n"
printf "1) 360p\n"
printf "2) 480p (padrão compatível: AVC1 + MP4A)\n"
printf "3) 720p\n"
printf "4) 1080p\n"
printf "5) Apenas áudio (MP3/AAC)\n"
read -rp "Digite o número da opção: " quality_choice

case "$quality_choice" in
    1) format="bestvideo[height<=360][vcodec^=avc1]+bestaudio[acodec^=opus]" ;;
    2) format="bestvideo[height<=480][vcodec^=avc1]+bestaudio[acodec^=opus]" ;;
    3) format="bestvideo[height<=720][vcodec^=avc1]+bestaudio[acodec^=opus]" ;;
    4) format="bestvideo[height<=1080][vcodec^=avc1]+bestaudio[acodec^=opus]" ;;
    5) format="bestaudio[acodec^=opus]" ;;
    *)
        printf "Opção inválida. Usando 480p como padrão.\n"
        format="bestvideo[height<=480][vcodec^=avc1]+bestaudio[acodec^=opus]"
        ;;
esac

while true; do
    read -rp "Digite o que deseja pesquisar: " search

    [[ -z "$search" ]] && {
        printf "Pesquisa vazia. Tente novamente.\n"
        continue
    }

    tempfile=$(mktemp)
    youtube_dl_log=$(mktemp)

query="ytsearch10:$search"

# Executar yt-dlp
if ! yt-dlp -j "$query" >"$tempfile" 2>"$youtube_dl_log"; then
    printf "Erro ao executar yt-dlp:\n"
    cat "$youtube_dl_log"
    continue
fi

# Verificar conteúdo
if [[ ! -s "$tempfile" ]]; then
    printf "Nenhum resultado encontrado.\n"
    continue
fi

# Ler títulos e URLs em uma única passada
mapfile -t results < <(jq -r '[.fulltitle, .webpage_url] | @tsv' "$tempfile")

declare -a youtube_titles youtube_urls

for line in "${results[@]}"; do
    title=${line%%$'\t'*}
    url=${line#*$'\t'}
    youtube_titles+=("$title")
    youtube_urls+=("$url")
done

# Mostrar lista
for i in "${!youtube_titles[@]}"; do
    printf "[%d] %s\n" $((i + 1)) "${youtube_titles[$i]}"
done

# Escolha do usuário
while true; do
        printf "\nDigite o número do vídeo (ou 'q' para nova busca): "
        read -r input

        if [[ "$input" == "q" ]]; then
            break
        elif [[ "$input" =~ ^[0-9]+$ ]] && (( input >= 1 && input <= ${#youtube_urls[@]} )); then
            printf "Iniciando vídeo em mpv...\n"
            mpv --ytdl-format="$format" "${youtube_urls[$((input - 1))]}"
            break
        else
            printf "Entrada inválida.\n"
        fi
    done
done
