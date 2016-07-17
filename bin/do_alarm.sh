#!/bin/sh

NOVERBOSE="--no-terminal"

[ -f "$0".conf ] && source "$0".conf

: ${length:=28}
: ${volume:=100} 
percent_begin=$(echo | awk 'srand() { print rand()*50 }')
sound="$(find ~/alarm/ -type f | sort -R | tail -1)"
#DO_RANDOM_START="--start=$percent_begin"

mpv $NOVERBOSE --no-video --loop=force $DO_RANDOM_START --volume=$volume "$sound" &
sleep $length
pkill -P $$
wait; # Cleaner when invoking from a shell.
