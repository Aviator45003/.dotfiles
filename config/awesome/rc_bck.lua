-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Extra widgets
vicious = require("vicious")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- Drop-down manager
local scratch = require("scratch")

-- Load Debian menu entries
require("debian.menu")

awful.util.spawn_with_shell("xcompmgr &")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.add_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/eric/.config/awesome/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "konsole"
sterminal = "konsole --p role=scratch"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.max,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.floating,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    awful.layout.suit.magnifier
    --awful.layout.suit.max.fullscreen
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 'IRC' }, s, layouts[1])
end
--tagkeys = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 'IRC' }
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Debian", debian.menu.Debian_menu.Debian },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a spacer widget
spacer = widget({ type = "textbox" })
spacer.text = "   "

-- Create a battery widget
batwidget = widget({ type = "textbox" })
vicious.register(batwidget, vicious.widgets.bat, function (widget, args)
                if args[1] == '⌁' or args[1] == '+' or args[1] == '↯' then
                        state_string = '<span color = "lightgreen">'..args[1]..'</span>'
                else
                        state_string = '<span color = "red">'..args[1]..'</span>'
                end

                if args[2] > 60 then
                        percent_string = '<span color = "lightgreen">'..args[2]..'%</span>'
                elseif args[2] > 20 then
                        percent_string = '<span color = "yellow">'..args[2]..'%</span>'
                elseif args[2] > 10 then
                        percent_string = '<span color = "orange">'..args[2]..'%</span>'
                else
                        percent_string = '<span color = "red">'..args[2]..'%</span>'
                end

                return state_string..' '..percent_string
        end, 3, "BAT1")

-- Create a textclock widget
mytextclock = awful.widget.textclock.new({ align = "right" }, "%a %b %d, %I:%M %p", 30)

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewprev),
                    awful.button({ }, 5, awful.tag.viewnext)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)
        
    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
                {
                        mylauncher,
                        mytaglist[s],
                        spacer,
                        batwidget,
                        spacer,
                        mypromptbox[s],
                        layout = awful.widget.layout.horizontal.leftright
                },
                mylayoutbox[s],
                mytextclock,
                s == 1 and mysystray or nil,
                mytasklist[s],
                layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewprev),
    awful.button({ }, 5, awful.tag.viewnext)
))
-- }}}

-- {{{ Key bindings
globalkeys = {}
globalkeys = awful.util.table.join(
    --awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    --awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey, "Shift"   }, "h",
		function ()
			local screen = mouse.screen
			local tagnum = awful.tag.getidx ( mouse.tag )
			awful.tag.viewonly ( tags[ screen ][ ( tagnum + 7 ) % 9 + 1 ] )
		end),
    awful.key({ modkey, "Shift"   }, "l",
		function ()
			local screen = mouse.screen
			local tagnum = awful.tag.getidx ( mouse.tag )
			awful.tag.viewonly ( tags[ screen ][ tagnum % 9 + 1 ] )
		end),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey, "Shift"   }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey,           }, "p", function () awful.util.spawn_with_shell(terminal .. " -e python") end),
    awful.key({ modkey,           }, "w", function () awful.util.spawn_with_shell(terminal .. " -e wyrd") end),
    awful.key({ modkey, "Shift"   }, "t", function () awful.util.spawn_with_shell(terminal .. " -e ~/bin/todo") end),
    awful.key({ modkey, "Shift"   }, "i", function () awful.util.spawn_with_shell(terminal .. " --profile Weechat") end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    --awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    --awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Shift"   }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),

    -- Volume Keys
    awful.key({}, "XF86AudioMute",
            function () awful.util.spawn_with_shell ("~/bin/mute_toggle") end ),
    awful.key({}, "XF86AudioLowerVolume",
            function () awful.util.spawn_with_shell ("~/bin/volume_down") end ),
    awful.key({}, "XF86AudioRaiseVolume",
            function () awful.util.spawn_with_shell ("~/bin/volume_up") end ),

    -- Brightness Keys
    awful.key({}, "XF86MonBrightnessUp",
            function () awful.util.spawn_with_shell ("~/bin/bright_up") end ),
    awful.key({}, "XF86MonBrightnessDown",
            function () awful.util.spawn_with_shell ("~/bin/bright_down") end ),

    -- Sleep/Screensaver Keys
    awful.key({}, "XF86Sleep", function ()
            awful.util.spawn ("/home/eric/bin/suspend") end),
            --awful.util.spawn ("xscreensaver-command -lock") end ),
    awful.key({ modkey }, "F4", function ()
            awful.util.spawn ("/home/eric/bin/suspend") end ),
            --awful.util.spawn ("xscreensaver-command -lock") end ),
    awful.key({}, "XF86ScreenSaver", function() awful.util.spawn_with_shell ( "slock" ) end ),
    awful.key({ modkey }, "F3", function() awful.util.spawn_with_shell ( "slock" ) end ),
    awful.key({}, "XF86WebCam", function ()
            awful.util.spawn_with_shell ("sleep 1; xset dpms force off") end ),
    awful.key({ modkey }, "F6", function ()
            awful.util.spawn_with_shell ("sleep 1; xset dpms force off") end ),

    -- Media Keys
    awful.key({}, "XF86AudioPlay", function () awful.util.spawn ("xmms2 toggle") end ),
    awful.key({modkey}, "F11", function () awful.util.spawn ("xmms2 toggle") end ),
    awful.key({}, "XF86AudioPrev", function () awful.util.spawn ("xmms2 prev") end ),
    awful.key({modkey}, "F10", function () awful.util.spawn ("xmms2 prev") end ),
    awful.key({}, "XF86AudioNext", function () awful.util.spawn ("xmms2 next") end ),
    awful.key({modkey}, "F12", function () awful.util.spawn ("xmms2 next") end ),

    awful.key({modkey, "Shift"}, "F11", function () awful.util.spawn ("p play") end ),
    awful.key({modkey, "Shift"}, "F10", function () awful.util.spawn ("p history") end ),
    awful.key({modkey, "Shift"}, "F12", function () awful.util.spawn ("p next") end ),
    awful.key({modkey, "Shift"}, "=", function () awful.util.spawn ("p love") end ),
    awful.key({modkey, "Shift"}, "-", function () awful.util.spawn ("p ban") end ),
    awful.key({modkey, "Shift"}, "e", function () awful.util.spawn ("p explain") end ),
    awful.key({modkey, "Shift"}, "s", function () awful.util.spawn ("p switchstation") end ),
    awful.key({modkey, "Shift"}, "u", function () awful.util.spawn ("p upcoming") end ),

    awful.key({modkey, "Shift"}, "m", function () awful.util.spawn_with_shell ("mail-notification -u") end ),
    awful.key({modkey, "Control"}, "m", function () awful.util.spawn_with_shell ("mail-notification -r") end ),
    awful.key({modkey, "Control", "Shift"}, "m",
      function ()
        awful.util.spawn_with_shell ("killall -9 mail-notification")
        os.execute ("sleep 1")
        awful.util.spawn_with_shell ("mail-notification")
      end ),
	awful.key({modkey, "Control"}, "m", function () awful.util.spawn_with_shell ("killall mutt") end ),

    -- Hide taskbar
    awful.key({modkey}, "i", function () mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible end ),

    -- Scratch Windows
    awful.key({ modkey }, "a",
            function () scratch.drop(sterminal .. " -e alsamixer", "top", "right", 0.1, 0.55, true) end),
    awful.key({ modkey, "Shift" }, "x",
            function () scratch.drop(sterminal .. " -e xmms2 status", "bottom", "center", 0.7, 0.06, true) end),
    awful.key({ modkey }, "Home",
            function () scratch.drop(sterminal, "top", "center", 1, 0.24, true) end),
    awful.key({ modkey, "Shift" }, "p",
            function () scratch.drop("pavucontrol", "top", "right", 0.5, 0.55, true) end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 0, keynumber do
	if i == 0 then
		i = 10
	end
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, i % 10,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, i % 10,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, i % 10,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, i % 10,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Menu keys
awful.menu.menu_keys = {
        up = { "k", "Up" },
        down = { "j", "Down" },
        exec = { "l", "Return", "Right" },
        back = { "h", "Left" },
        close = { "q", "Escape" },
}

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     floating = false,
                     size_hints_honor = false,
                     buttons = clientbuttons },
	  callback = function ( c )
		  local selected = awful.tag.selectedlist()
		  for index, tag in ipairs ( selected ) do
			  if tag == tags[ mouse.screen ][ 10 ] then
				  table.remove ( selected, index )
			  end
		  end
		  if table.getn ( selected ) == 0 then
			  selected = { tags[ mouse.screen ][ 1 ] }
		  end
		  c:tags ( selected )
	  end },
        { rule = { role = "scratch" },
          properties = { floating = true } },
        { rule = { class = "Dolphin" },
          properties = { floating = true } },
        { rule = { class = "Kdialog" },
          properties = { floating = true } },
        { rule = { class = "processing-core-PApplet" },
          properties = { floating = true } },
		{ rule = { class = "Konsole" },
		  callback = function ( c )
			  local clock = os.clock
			  local t0 = clock()
			  local property = { name = "Weechat – Konsole" }
			  while clock() - t0 <= 0.001 do end -- wait for 1 / 1000 second
			  if awful.rules.match ( c, property ) then
				  c:tags ( { tags[ mouse.screen ][ 10 ] } )
			  end
		  end }
    --{ rule = { class = "MPlayer" },
      --properties = { floating = true } },
    --{ rule = { class = "pinentry" },
      --properties = { floating = true } },
    --{ rule = { class = "gimp" },
      --properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they do not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- {{{ Arrange signal handler
for s = 1, screen.count() do screen[s]:add_signal("arrange", function ()
    local clients = awful.client.visible(s)
    local layout = awful.layout.getname(awful.layout.get(s))

    for _, c in pairs(clients) do -- Floaters are always on top
        if   awful.client.floating.get(c) or layout == "floating"
        then if not c.fullscreen then c.above       =  true  end
        else                          c.above       =  false end
    end
  end)
end
-- }}}
-- }}}

require("lfs") 
-- {{{ Run program once
local function processwalker()
        local function yieldprocess()
                for dir in lfs.dir("/proc") do
                        -- All directories in /proc containing a number, represent a process
                        if tonumber(dir) ~= nil then
                                local f, err = io.open("/proc/"..dir.."/cmdline")
                                if f then
                                        local cmdline = f:read("*all")
                                        f:close()
                                        if cmdline ~= "" then
                                                coroutine.yield(cmdline)
                                        end
                                end
                        end
                end
        end
        return coroutine.wrap(yieldprocess)
end

local function run_once(process, cmd)
--      local file = io.open ( "/home/eric/awesome_debug", "a" )
        assert(type(process) == "string")
        local regex_killer = {
                ["+"]  = "%+", ["-"] = "%-",
                ["*"]  = "%*", ["?"]  = "%?",
                [" "]  = "\0" }

--      file:write(process:gsub("[-+?* ]", regex_killer):sub(0,-1) .. "\0\n")
--      file:write(process:gsub(" ", "\0"):sub(0,-1) .. "\0\n")

        if process:find(" ") then
                findstring = process:gsub(" ", "\0"):sub(0,-1)
        else
                findstring = process:gsub("[-+?*]", regex_killer):sub(0,-1)
        end
--      file:write("findstring is: " .. findstring)

        for p in processwalker() do
--              file:write(p .. "\n")
                if p:find(findstring .. "\0") then
--                      file:write("Killed it!\n")
                        return
                end
        end
--      file:close()
        return awful.util.spawn_with_shell(cmd or process)
end
-- }}}

-- {{{ Startup Programs
run_once ( "nm-applet" )
run_once ( "xflux -z 75080" )
run_once ( "skype" )
run_once ( "synclient Touchpadoff=1" )
--run_once ( "caffeine" )
run_once ( "mail-notification" )
--run_once ( "/home/eric/bin/auto-grive" )
run_once ( "dropbox start" )

-- }}}

-- ex: set foldmethod=marker:
