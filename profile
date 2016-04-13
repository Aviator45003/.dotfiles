if [ -x /usr/bin/ssh-agent ] && ! pgrep ssh-agent > /dev/null; then
	eval `/usr/bin/ssh-agent -s`
fi
if [ -x /usr/bin/gpg-agent ] && ! pgrep gpg-agent > /dev/null; then
	gpg-agent --daemon
fi
if [ -x /usr/bin/keychain ]; then
	eval `/usr/bin/keychain --eval ~/.ssh/{github_rsa,id_ed25519{,_carbon},id_rsa}`
fi

if [ "$(tty | sed 's/\/dev\/\(...\).*/\1/')" = "tty" ]; then
	# TTY
	if [ -d ~/.kbd/keymaps ]; then
		find ~/.kbd/keymaps/ -name "*.map" -type f | xargs -t -d '\n' sudo /usr/bin/loadkeys
	fi
fi

[ -d ~/bin ] && export PATH=$HOME/bin:$PATH
