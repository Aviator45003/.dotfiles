/usr/bin/xmodmap ~/.Xmodmap &
xcape -e 'Control_L=Escape' &
~/bin/trackpadsetup.sh
unset TMUX
exec awesome
