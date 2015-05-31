a=require("awful")
a.util.spawn_with_shell("echo -e 'Awesome is a minimal window manager. You probably want to be using a desktop environment, such as Cinnamon. Please select Cinnamon from the top right corner of your login box.\n\n If you did want to run Awesome, please place a configuration file in your ~/.config/awesome/rc.lua from another desktop environment or a virtual terminal.\n\nYou can find the default configuration in /etc/xdb/awesome/rc.lua.default\n\n Please click `okay` to log out.' | xmessage -file - -display :0 && killall awesome")
tags = {}
tags[1]=a.tag({1})
