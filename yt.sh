#!/usr/bin/bash

tempfile=$(mktemp)
youtube_dl_log=$(mktemp)

# Escolher resolução
echo "Escolha a qualidade desejada:"
echo "1) 360p"
echo "2) 480p (padrão compatível: AVC1 + MP4A)"
echo "3) 720p"
echo "4) 1080p"
echo "5) Apenas áudio (MP3/AAC)"
read -rp "Digite o número da opção: " quality_choice

# Definir o formato com base na escolha
case "$quality_choice" in
1) format="bestvideo[height<=360][vcodec^=avc1]+bestaudio[acodec^=opus]" ;;
2) format="bestvideo[height<=480][vcodec^=avc1]+bestaudio[acodec^=opus]" ;;
3) format="bestvideo[height<=720][vcodec^=avc1]+bestaudio[acodec^=opus]" ;;
4) format="bestvideo[height<=1080][vcodec^=avc1]+bestaudio[acodec^=opus]" ;;
5) format="bestaudio[acodec^=opus]" ;;
*) echo "Opção inválida. Usando 480p como padrão."; format="bestvideo[height<=480][vcodec^=avc1]+bestaudio[acodec^=opus]" ;;
esac

query="ytsearch5:$*"
yt-dlp -j "$query" > "$tempfile" 2>"$youtube_dl_log"

if [ ! -s "$tempfile" ]; then
echo "Nenhum resultado encontrado ou erro no yt-dlp:"
cat "$youtube_dl_log"
rm "$tempfile" "$youtube_dl_log"
exit 1
fi

declare -a youtube_urls
declare -a youtube_titles

mapfile -t youtube_titles < <(jq -r '.fulltitle' "$tempfile")
mapfile -t youtube_urls < <(jq -r '.webpage_url' "$tempfile")

for i in "${!youtube_titles[@]}"; do
printf "[%d] %s\n" $((i + 1)) "${youtube_titles[$i]}"
done

while true; do
echo -e "\nDigite o número do vídeo escolhido (ou 'q' para sair):"
read -r input

if [[ "$input" == "q" ]]; then
break
elif [[ "$input" =~ ^[0-9]+$ ]] && (( input >= 1 && input <= ${#youtube_urls[@]} )); then
echo "Iniciando vídeo em mpv com formato: $format"
mpv --ytdl-format="$format" "${youtube_urls[$((input - 1))]}"
break
else
echo "Entrada inválida."
fi
done

rm "$tempfile" "$youtube_dl_log"
