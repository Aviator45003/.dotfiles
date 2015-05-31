#!/usr/bin/env bash
[[ -z $((xprop -id $(</tmp/tabbed.xid)) 2>/dev/null) ]] && tabbed -c -d > /tmp/tabbed.xid 
exec vimprobable2 -e $(</tmp/tabbed.xid) $( [[  "$1"  ]] && echo "$1") &
