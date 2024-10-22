#!/bin/bash

last_status=""
last_artist=""
last_title=""
last_position=0

text_color=$(tput setaf 7)
reset_color=$(tput sgr0)

print_centered() {
  local message="$1"
  local cols="$2"
  local pad_size=$(( (cols - ${#message}) / 2 ))
  printf "%${pad_size}s%s\n" "" "$message"
}

while true; do
  cols=144
  rows=$(tput lines)

  status=$(playerctl status)

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

  
  if [ "$length_sec" -ge 3600 ]; then
    position_time=$(printf "%02d:%02d:%02d" $((position_sec / 3600)) $(((position_sec % 3600) / 60)) $((position_sec % 60)))
    length_time=$(printf "%02d:%02d:%02d" $((length_sec / 3600)) $(((length_sec % 3600) / 60)) $((length_sec % 60)))
  else
    position_time=$(printf "%02d:%02d" $((position_sec / 60)) $((position_sec % 60)))
    length_time=$(printf "%02d:%02d" $((length_sec / 60)) $((length_sec % 60)))
  fi

  artist_line="♪ $artist "
  title_line="    $title "

  if [ "${#artist}" -gt 30 ]; then
    artist_line="♪ ${artist:0:30}..."
  fi
  if [ "${#title}" -gt 30 ]; then
    title_line="    ${title:0:30}..."
  fi

  printf "\033[H\033[J"

  top_padding=$(( (rows - 10) / 2 ))
  printf "%${top_padding}s\n" ""

  print_centered "$text_color$artist_line$reset_color" "$cols"
  print_centered "$text_color$title_line$reset_color" "$cols"

  if [ "$status" == "Paused" ]; then
    progress_bar=""
    for (( i=0; i<filled_bar; i++ )); do
      progress_bar+="=" 
    done
    for (( i=0; i<empty_bar; i++ )); do
      progress_bar+="-";  
    done
    progress_line="[$progress_bar]"
    pause_logo="❚❚"
  else
    progress_bar=""
    for (( i=0; i<filled_bar; i++ )); do
      progress_bar+="=" 
    done
    for (( i=0; i<empty_bar; i++ )); do
      progress_bar+="-";  
    done
    progress_line="[$progress_bar]"
    pause_logo=""
  fi

  print_centered "$text_color$progress_line$reset_color" "$cols"

  if [ "$status" != "Paused" ]; then
    print_centered "$text_color$position_time / $length_time$reset_color" "$cols"
  else
    print_centered "$text_color$pause_logo$reset_color" "$cols"
  fi

  last_artist="$artist"
  last_title="$title"
  last_status="$status"
  last_position="$position_sec"

  sleep 1
done

