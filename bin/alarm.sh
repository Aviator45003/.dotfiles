#!/bin/sh

[ -f "$0".conf ] && . "$0".conf

: ${timebetween:=30}

while [ ! -f /tmp/imup ]; do
	( sh ~/bin/do_alarm.sh ) &
	sleep $timebetween
done

rm /tmp/imup
