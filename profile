if [ $(tty | sed 's/\/dev\/\(...\).*/\1/') = "tty" ]; then
	if [ -x /usr/bin/ssh-agent ]; then
		eval `/usr/bin/ssh-agent -s`
	fi
	if [ -x /usr/bin/keychain ]; then
		eval `/usr/bin/keychain --eval ~/.ssh/{github_rsa,id_ed25519,id_rsa,id_ed25519_carbon}`
	fi
	# TTY
	if [ -d ~/.kbd/keymaps ]; then
		find ~/.kbd/keymaps/ -name "*.map" -type f | xargs -t -d '\n' sudo /usr/bin/loadkeys
	fi
fi
