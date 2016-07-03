if [ -x /usr/bin/ssh-agent ] && ! pgrep ssh-agent > /dev/null; then
	eval `/usr/bin/ssh-agent -s`
fi
if [ -x /usr/bin/gpg-agent ] && ! pgrep gpg-agent > /dev/null; then
	gpg-agent --daemon
fi

key_list=
for file in ~/.ssh/*.pub; do
	key_list+=" ${file%.pub}"
done
if [ -x /usr/bin/keychain ]; then
	eval `echo $key_list | xargs /usr/bin/keychain --eval`
elif [ -x /usr/bin/ssh-add ]; then
	echo $key_list | xargs /usr/bin/ssh-add
fi

if [ "$(tty | sed 's/\/dev\/\(...\).*/\1/')" = "tty" ]; then
	# TTY
	if [ -d ~/.kbd/keymaps ]; then
		find ~/.kbd/keymaps/ -name "*.map" -type f | xargs -t -d '\n' sudo /usr/bin/loadkeys
	fi
fi

[ -d ~/bin ] && export PATH=$HOME/bin:$PATH
