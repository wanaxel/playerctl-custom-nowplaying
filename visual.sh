#!/bin/bash

cols=144
rows=28

last_status=""
last_artist=""
last_title=""
last_position=0

text_color=$(tput setaf 7)
reset_color=$(tput sgr0)

while true; do
  status=$(playerctl status)

  if [ "$status" == "Paused" ]; then
    paused_message="❚❚ Media is Paused"
    paused_pad=$(( (cols - ${#paused_message}) / 2 ))
    top_padding=$(( (rows - 3) / 2 ))

    printf "\033[H\033[J"
    printf "%${top_padding}s\n" ""
    printf "%${paused_pad}s%s%s\n\n" "" "$text_color$paused_message" "$reset_color"
  else
    artist=$(playerctl metadata xesam:artist)
    title=$(playerctl metadata xesam:title)
    position=$(playerctl position)
    length=$(playerctl metadata mpris:length)

    length_sec=$((length / 1000000))
    position_sec=$(printf "%.0f" "$position")

    progress_percent=$(echo "scale=2; 100 * $position_sec / $length_sec" | bc)
    bar_size=40
    filled_bar=$(printf "%.0f" "$(echo "$progress_percent * $bar_size / 100" | bc)")
    empty_bar=$(( bar_size - filled_bar ))

    progress_bar=""
    for (( i=0; i<filled_bar; i++ )); do
      progress_bar+="="
    done
    
    for (( i=0; i<empty_bar; i++ )); do
      progress_bar+="-" 
    done

    position_time=$(printf "%02d:%02d" $((position_sec / 60)) $((position_sec % 60)))
    length_time=$(printf "%02d:%02d" $((length_sec / 60)) $((length_sec % 60)))

    artist_line="♪ $artist "
    title_line=" $title "

    if [ "$last_artist" != "$artist" ] || [ "$last_title" != "$title" ] || [ "$last_status" != "$status" ] || [ "$last_position" -ne "$position_sec" ]; then
      printf "\033[H\033[J"
      top_padding=$(( (rows - 8) / 2 ))

      printf "%${top_padding}s\n" ""

      artist_pad=$(( (cols - ${#artist_line}) / 2 ))
      title_pad=$(( (cols - ${#title_line}) / 2 ))

      printf "%${artist_pad}s%s%s\n" "" "$text_color$artist_line" "$reset_color"
      printf "\n"
      printf "%${title_pad}s%s%s\n" "" "$text_color$title_line" "$reset_color"
      printf "\n"

      progress_line="[$progress_bar] $position_time / $length_time"
      progress_pad=$(( (cols - ${#progress_line}) / 2 ))
      printf "%${progress_pad}s%s%s\n" "" "$text_color$progress_line" "$reset_color"

      last_artist="$artist"
      last_title="$title"
      last_status="$status"
      last_position="$position_sec"
    else
      printf "\033[$((rows - 4))H"
      printf "\033[K"
      printf "\033[${progress_pad}C%s[%s] %s / %s%s\n" "$text_color" "$progress_bar" "$position_time" "$length_time" "$reset_color"
    fi
  fi

  sleep 1
done

