#!/usr/bin/env bash

#--------------------------------------
#Desc: Gravar tela com tempo definidido
#Autor: Urasono
#Versão: 1.0
#---------------------------------------

config_variables() {
  resolucao=$(xrandr | grep '*' | head -n1 | awk '{print $1}')
  monitor=$(pactl get-default-source)

  t15="00:15:00"
  t30="00:30:00"
  t1h="01:00:00"
}

config_record() {
  ffmpeg \
    -video_size "$resolucao" \
    -framerate 30 \
    -f x11grab -i :0.0 \
    -f pulse -ac 2 -i "$monitor" \
    -t "$t15" \
    -c:v libx264 -preset ultrafast \
    -c:a aac -b:a 192k \
    output.mp4
}

main() {
  config_variables
  config_record
}

main "$@"
