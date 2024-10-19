#!/bin/bash

cols=144
rows=28

while true; do
  clear

  artist=$(playerctl metadata xesam:artist)
  title=$(playerctl metadata xesam:title)
  position=$(playerctl position)
  length=$(playerctl metadata mpris:length)

  length_sec=$((length / 1000000))
  position_sec=$(echo "$position" | bc)
  progress_percent=$(echo "scale=2; 100 * $position_sec / $length_sec" | bc)

  bar_size=40
  filled_bar=$(echo "$progress_percent * $bar_size / 100" | bc)
  empty_bar=$(echo "$bar_size - $filled_bar" | bc)
  progress_bar=$(printf '█%.0s' $(seq 1 ${filled_bar%.*}))
  progress_bar+=$(printf '░%.0s' $(seq 1 ${empty_bar%.*}))

  position_time=$(printf "%02d:%02d" $((position_sec / 60)) $((position_sec % 60)))
  length_time=$(printf "%02d:%02d" $((length_sec / 60)) $((length_sec % 60)))

  artist_line=" $artist "
  title_line=" $title "

  artist_bigger=$(printf "%s\n\n\n" "$artist_line")
  title_bigger=$(printf "%s\n\n" "$title_line")

  artist_pad=$(( (cols - ${#artist_line}) / 2 ))
  title_pad=$(( (cols - ${#title_line}) / 2 ))
  progress_line="[$progress_bar] $position_time / $length_time"
  progress_pad=$(( (cols - ${#progress_line}) / 2 ))

  top_padding=$(( (rows - 10) / 2 ))

  printf "%${top_padding}s\n" ""
  printf "%${artist_pad}s%s\n\n" "" "$artist_bigger"
  printf "%${title_pad}s%s\n\n" "" "$title_bigger"
  printf "%${progress_pad}s%s\n" "" "$progress_line"

  sleep 1
done
