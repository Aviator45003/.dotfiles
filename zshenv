if [ -d ~/bin ]; then
	export PATH=~/bin:$PATH
fi

if [ -d ~/Code/void-packages ]; then
	XBPS_CHROOT_CMD=uchroot
	XBPS_DISTDIR=~/Code/void-packages
fi
