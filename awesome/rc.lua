-- Standard awesome library
local awful = require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
require("naughty")

-- Load Debian menu entries
require("debian.menu")

-- {{{ Custom function

quit = function()
	answer = awful.util.pread("dmenu -p 'Realy want to quit (No or Yes)?'")
	if answer:sub(1, 3) == "Yes" or answer:sub(1, 1) == "y" then
		awesome.quit()
	end
end

-- }}}


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
    awesome.connect_signal("debug::error", function (err)
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
beautiful.init("/home/louis/.config/awesome/themes/zenburn/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
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
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
        names = { "T(1)", "T(2)", "T(3)", "T(4)", "T(5)", "F(6)", "F(7)", "F(8)", "T(9)" },
            layout = { layouts[2], layouts[2], layouts[2], layouts[2], layouts[2], layouts[1], layouts[1], layouts[1], layouts[2]}
}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s, tags.layout)
end
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

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })

mytextclock:buttons(awful.util.table.join(
  awful.button({ }, 1, function () awful.util.spawn("osmo -c") end)
    ))

-- Create a systray
-- mysystray = awful.widget({ type = "systray" })

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
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
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
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
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
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

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
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Personnal
    awful.key({ modkey }, "i",
            function ()
                awful.util.spawn("x-www-browser")
            end),
        awful.key({ modkey, "Shift" }, "z",
            function ()
                awful.util.spawn("sh -c \"sudo pm-suspend\"")
            end),
        awful.key({ modkey }, "z",
            function ()
                awful.util.spawn("xscreensaver-command -lock")
            end),
        awful.key({ }, "XF86AudioRaiseVolume",
            function ()
                awful.util.spawn("amixer -D pulse set Master 5%+")
            end),
        awful.key({ }, "XF86AudioLowerVolume",
            function ()
                awful.util.spawn("amixer -D pulse set Master 5%-")
            end),
        awful.key({ }, "XF86AudioMute",
            function ()
                awful.util.spawn("amixer -D pulse set Master toggle")
            end),
        awful.key({ }, "XF86KbdBrightnessUp",
            function ()
                awful.util.spawn("sudo /usr/local/bin/kbd_backlight up")
            end),
        awful.key({ }, "XF86KbdBrightnessDown",
            function ()
                awful.util.spawn("sudo /usr/local/bin/kbd_backlight down")
            end),
        awful.key({ }, "XF86Eject",
            function ()
                awful.util.spawn("eject")
            end),
        awful.key({ }, "XF86LaunchA",
            function ()
                awful.util.spawn("shutter --full")
            end),
        awful.key({ modkey }, "XF86LaunchA",
            function ()
                awful.util.spawn("shutter --active")
            end),
        awful.key({ modkey }, "F1",
            function ()
                awful.util.spawn("xdg-open /home/louis/awesome.pdf")
            end),
        awful.key({ modkey }, "XF86AudioPlay",
            function ()
                awful.util.spawn("bash -c \"if [ `mocp --info | grep -c 'State: STOP'`a == 1a ]; then mocp --play; else mocp --stop; fi\"")
            end),
        awful.key({ }, "XF86AudioPlay",
            function ()
                awful.util.spawn("bash -c \"if [ `mocp --info | grep -c 'State: STOP'`a == 1a ]; then mocp --play; else mocp --toggle-pause; fi\"")
            end),
        awful.key({ }, "XF86AudioPrev",
            function ()
                awful.util.spawn("mocp --previous")
            end),
        awful.key({ }, "XF86AudioNext",
            function ()
                awful.util.spawn("mocp --next")
            end),
        awful.key({ modkey }, "p",
            function ()
                awful.util.spawn("x-terminal-emulator -e mocp")
            end),
        awful.key({ modkey }, "v",
            function ()
                awful.util.spawn("x-terminal-emulator -e alsamixer")
            end),
        awful.key({ modkey, "Shift" }, "Return",
            function ()
                awful.util.spawn("pcmanfm")
            end),
        awful.key({ modkey }, "numbersign",
            function ()
                awful.util.spawn("bash -c \"sleep 0.5; xdotool key Menu\"")
            end),
        awful.key({ modkey }, "XF86KbdBrightnessUp",
            function ()
                awful.util.spawn("synclient TouchpadOff=0")
            end),
        awful.key({ modkey }, "XF86KbdBrightnessDown",
            function ()
                awful.util.spawn("synclient TouchpadOff=1")
            end),
	awful.key({ }, "XF86MonBrightnessDown",
            function ()
                awful.util.spawn("sudo /usr/local/bin/brightness down")
            end),
	awful.key({ }, "XF86MonBrightnessUp",
            function ()
                awful.util.spawn("sudo /usr/local/bin/brightness up")
            end),
       awful.key({ modkey }, "F3",
            function ()
                awful.util.spawn("display -immutable -title \"help bepo layout\" bepo.png")
            end),
       awful.key({ modkey }, "g",
            function ()
                awful.util.spawn("gpa -c")
            end),
        awful.key({ modkey }, "F2",
            function ()
                awful.util.spawn("display -immutable -title \"help vim\" vimcsbepo.png")
            end)


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
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
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
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "Display" },
      callback = function( c )
            if c.name == "help bepo layout" then
                awful.client.floating.set (c, true)
                local dimension = c:geometry()
                dimension.x= 912
                dimension.y = 19
                dimension.width = 956
                dimension.height = 593
                c:geometry(dimension)
                c.ontop = true
            elseif c.name == "help vim" then
                awful.client.floating.set (c, true)
                local dimension = c:geometry()
--              io.stderr:write("Dimension: (" .. dimension.x .. "," .. dimension.y .. "," .. dimension.width .. "," .. dimension.height .. ")")
                dimension.x= 793
                dimension.y = 19
                dimension.width = 1127
                dimension.height = 712
                c:geometry(dimension)
                c.ontop = true
            end

      end
    },
    { rule = { class = "Osmo" },
      properties = { floating = true},
      callback = function( c )
        local w_area = screen[ c.screen ].workarea
        local winwidth = 537
        local winheight = 441
        c:geometry( { x = w_area.width - winwidth, width = winwidth, y = w_area.y, height = winheight } )
      end
    },

    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
	{ rule = { instance = "plugin-container" },
		properties = { floating = true } },
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

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)
client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

os.execute("killall -9 xscreensaver;/usr/bin/xscreensaver &")
os.execute("killall -9 nm-applet;/usr/bin/nm-applet --sm-disable &")
os.execute("killall -9 volumeicon;/usr/bin/volumeicon &")
os.execute("chmod +x /home/louis/lid.sh &")
os.execute("/usr/bin/mocp --server &")
os.execute("killall -9 battery_indicator;/usr/local/bin/battery_indicator &")
os.execute("killall -9 gpa;/usr/bin/gpa -d &")
os.execute("killall -9 gtk-redshift;/usr/bin/gtk-redshift -l 45.572266:-71.999318 &")
os.execute("killall -9 owncloud;/usr/bin/owncloud &")
os.execute("if ps aux | grep pcmanfm | grep -v grep; then :;else pcmanfm -d; fi &")
