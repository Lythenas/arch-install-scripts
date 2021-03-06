-- vim: fdm=marker foldenable

-- {{{ Imports
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")
--
-- start dunst here and replace naughty
awful.spawn.with_shell("dunst")
package.preload.naughty = function () return require("libs.naughty_replacement") end
local naughty = require("libs.naughty_replacement")
--
local icons = require("libs.icons")
local battery_widget = require("libs.battery")
local backlight = require("libs.backlight")
local volume = require("libs.volume")
local displayselect = require("libs.displayselect")
-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify {
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    }
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify {
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err)
        }
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("~/.config/awesome/themes/mytheme/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "alacritty"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
alt = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    --awful.layout.suit.tile.left,
    --awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating,
    --awful.layout.suit.corner.nw,
    --awful.layout.suit.corner.ne,
    --awful.layout.suit.corner.sw,
    --awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function () return false, hotkeys_popup.show_help end},
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function () awesome.quit() end}
}

mymainmenu = awful.menu {
    items = {
        { "awesome", myawesomemenu, beautiful.awesome_icon },
        { "open terminal", terminal },
    }
}

mylauncher = awful.widget.launcher {
    image = beautiful.awesome_icon,
    menu = mymainmenu
}
-- }}}

-- {{{ Lancher / Prompt
local launcher = {
    apps = function ()
        awful.spawn("rofi -show drun -show-icons")
    end,
    run_prompt = function ()
        awful.spawn("rofi -show run")
    end,
}
-- }}}

-- {{{ Wibar
-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- Create a textclock widget
mytextclock = wibox.widget.textclock("%d.%m.%y %H:%M:%S", 0.5)

-- Battery widget
local mybatteries = battery_widget()

-- volume bar
local myvolume = volume.widget

-- calendar popup
local mycalendar = awful.widget.calendar_popup.month {
    position = "tr",
}
-- attach signals, because the on_hover argument of :attach does not work
mytextclock:connect_signal("mouse::enter", function ()
    mycalendar:call_calendar(0)
    mycalendar.visible = true
end)
mytextclock:connect_signal("mouse::leave", function ()
    mycalendar.visible = false
end)
mycalendar:attach(mytextclock, "tr", {
    on_hover = false
})

-- networking / wifi
-- TODO make notifications pretty
local wifi_interface = "wlp4s0"

local mynetwork = wibox.widget {
    layout = wibox.layout.align.horizontal,

    icons.wifi_on,
}

local function wifi_up()
    mynetwork.first = icons.wifi_on
    mynetwork.opacity = 1
    mynetwork:emit_signal("widget::redraw_needed")

    local handle = io.popen("nmcli -t device")
    local content = handle:read("*all")
    handle:close()

    local lines = gears.string.split(content, "\n")

    for i, line in pairs(lines) do
        if line and wifi_interface and line:find(wifi_interface) then
            local items = gears.string.split(line, ":")
            local wifi_name = items[4]

            naughty.notify {
                text = "Wifi connected\n"..wifi_name,
                timeout = 3,
            }
        end
    end
end
local function wifi_down()
    mynetwork.first = icons.wifi_off
    mynetwork.opacity = 1
    mynetwork:emit_signal("widget::redraw_needed")

    naughty.notify {
        text = "Wifi disconnected",
        timeout = 3,
    }
end
local function wifi_searching()
    mynetwork.first = icons.wifi_on
    mynetwork.opacity = 0.5
    mynetwork:emit_signal("widget::redraw_needed")
end

local function process_line(line)
    if line:find(wifi_interface) then
        local items = gears.string.split(line, " ")
        local event = items[2]

        if event == "connected" then
            wifi_up()
        elseif event == "unavailable" then
            wifi_down()
        elseif event == "disconnected" or event == "using" then
            wifi_searching()
        end
    end
end

local function watch_wifi()
    awful.spawn.with_line_callback("nmcli device monitor "..wifi_interface, {
        stdout = function (line)
            process_line(line)
        end,
        exit = function (reason, code)
            watch_wifi()
        end,
    })
end

-- initial network check
awful.spawn.with_line_callback("nmcli -t device", {
    stdout = function (line)
        if line:find(wifi_interface) then
            local items = gears.string.split(line, ":")
            local state = items[3]

            if state == "connected" then
                wifi_up()
            elseif state == "unavailable" then
                wifi_down()
            elseif state == "disconnected" or state:find("connecting") then
                wifi_searching()
            end
        end
    end,
})
watch_wifi()


-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
    awful.button({}, 1, function(t) t:view_only() end)
)

local tasklist_buttons = gears.table.join(
    awful.button({}, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            -- Without this, the following
            -- :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() and c.first_tag then
                c.first_tag:view_only()
            end
            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
            c:raise()
        end
    end),
    awful.button({}, 3, client_menu_toggle_fn())
)

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

-- create a global systray
local mysystray = wibox.widget.systray()
-- intially show the systray but hide it after 5 seconds
-- this prevent potential issues with jetbrains toolbox not starting correctly
-- because it can't find a systray
awful.spawn.easy_async("sleep 5", function (stdout, stderr, reason, exit_code)
    mysystray.visible = false
end)

-- create a global prompt
local mypromptbox = awful.widget.prompt()

awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9", }, s, awful.layout.layouts[1])

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({}, 1, function () awful.layout.inc(1) end),
        awful.button({}, 3, function () awful.layout.inc(-1) end)
    ))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar {
        position = "top",
        screen = s,
    }

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        spacing = 5,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            spacing = 5,
            mylauncher,
            s.mytaglist,
            mypromptbox,
        },
        -- Middle widget
        wibox.container.margin(s.mytasklist, 5, 5),
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            spacing = 5,
            myvolume,
            mynetwork,
            mybatteries,
            mykeyboardlayout,
            mysystray,
            mytextclock,
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({}, 3, function () mymainmenu:toggle() end)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    -- General awesome hotkeys
    awful.key({ modkey, }, "s", hotkeys_popup.show_help,
        {description="show help", group="awesome"}),
    awful.key({ modkey, }, "w", function () mymainmenu:show() end,
        {description = "show main menu", group = "awesome"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
        {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Control", alt, "Shift", }, "q", awesome.quit,
        {description = "quit awesome", group = "awesome"}),
    awful.key({ modkey, "Control", }, "l", function () awful.spawn("light-locker-command -l") end,
        {description = "lock awesome", group = "awesome"}),

    awful.key({ modkey, "Shift", }, "s", function () mysystray.visible = not mysystray.visible end,
        {description = "hide/show the systray", group = "awesome"}),
    awful.key({ modkey, }, "+", function () awful.spawn.with_shell("~/.config/awesome/scripts/mountmenu.sh") end,
        {description = "show mount menu", group = "awesome"}),
    awful.key({ modkey, }, "#", function () awful.spawn.with_shell("~/.config/awesome/scripts/umountmenu.sh") end,
        {description = "show unmount menu", group = "awesome"}),

    -- Tag navigation and manipulation
    awful.key({ modkey, }, "Left", awful.tag.viewprev,
        {description = "view previous", group = "tag"}),
    awful.key({ modkey, }, "Right",  awful.tag.viewnext,
        {description = "view next", group = "tag"}),
    awful.key({ modkey, }, "Escape", awful.tag.history.restore,
        {description = "go back", group = "tag"}),

    -- Client navigation and manipulation
    awful.key({ modkey, }, "j", function () awful.client.focus.byidx(1) end,
        {description = "focus next by index", group = "client"}),
    awful.key({ modkey, }, "k", function() awful.client.focus.byidx(-1) end,
        {description = "focus previous by index", group = "client"}),
    awful.key({ modkey, "Shift", }, "j", function () awful.client.swap.byidx(1) end,
        {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift", }, "k", function () awful.client.swap.byidx(-1) end,
        {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, }, "u", awful.client.urgent.jumpto,
        {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey, }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),
    awful.key({ modkey, "Control", }, "n",
        function ()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                client.focus = c
                c:raise()
            end
        end,
        {description = "restore minimized", group = "client"}),

    -- Layout manipulation
    awful.key({ modkey, }, "l", function () awful.tag.incmwfact(0.05) end,
        {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey, }, "h", function () awful.tag.incmwfact(-0.05) end,
        {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift", }, "h", function () awful.tag.incnmaster(1, nil, true) end,
        {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift", }, "l", function () awful.tag.incnmaster(-1, nil, true) end,
        {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control", }, "h", function () awful.tag.incncol(1, nil, true) end,
        {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control", }, "l", function () awful.tag.incncol(-1, nil, true) end,
        {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey, }, "space", function () awful.layout.inc(1) end,
        {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift", }, "space", function () awful.layout.inc(-1) end,
        {description = "select previous", group = "layout"}),

    -- Screen navigation
    awful.key({ modkey, }, "Up", function () awful.screen.focus_relative(1) end,
        {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, }, "Down", function () awful.screen.focus_relative(-1) end,
        {description = "focus the previous screen", group = "screen"}),

    -- Standard program / launcher
    awful.key({ modkey, }, "Return", function () awful.spawn(terminal) end,
        {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, }, "r", function () launcher.run_prompt() end,
        {description = "run prompt", group = "launcher"}),
    awful.key({ modkey, }, "x",
        function ()
            awful.prompt.run {
                prompt       = "Run Lua code: ",
                textbox      = mypromptbox.widget,
                exe_callback = awful.util.eval,
                history_path = awful.util.get_cache_dir() .. "/history_eval"
            }
        end,
        {description = "lua execute prompt", group = "launcher"}),
    awful.key({ modkey, }, "p", function() launcher.apps() end,
        {description = "show the app lancher (rofi)", group = "launcher"}),

    -- Mediakeys
    awful.key({}, "XF86AudioMute", volume.toggle,
        {description = "mute/unmute volume", group = "media"}),
    awful.key({}, "XF86AudioLowerVolume", volume.decrease,
        {description = "lower volume", group = "media"}),
    awful.key({}, "XF86AudioRaiseVolume", volume.increase,
        {description = "raise volume", group = "media"}),
    awful.key({}, "XF86AudioMicMute", function() awful.spawn("amixer set Capture toggle") end,
        {description = "mute/unmute mic", group = "media"}),
    awful.key({}, "XF86MonBrightnessDown", function() backlight.change(-10) end,
        {description = "turn screen brightness down", group = "media"}),
    awful.key({}, "XF86MonBrightnessUp", function() backlight.change(10) end,
        {description = "turn screen brightness up", group = "media"}),
    awful.key({}, "XF86Display", function() displayselect.prompt(mypromptbox.widget) end,
        {description = "display options prompt", group = "media"}),
    awful.key({}, "XF86WLAN", function() awful.spawn("toggle-wifi") end,
        {description = "turns wifi on/off", group = "media"}),
    awful.key({}, "XF86Tools", function() awful.spawn("") end,
        {description = "TODO", group = "media"}),
    awful.key({}, "XF86Search", function() awful.spawn("") end,
        {description = "TODO", group = "media"}),
    awful.key({}, "XF86LaunchA", function() awful.spawn("") end,
        {description = "TODO", group = "media"}),
    awful.key({}, "XF86Explorer", function() awful.spawn("") end,
        {description = "TODO", group = "media"})
)

clientkeys = gears.table.join(
    awful.key({ modkey, }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift", }, "q", function (c) c:kill() end,
        {description = "close", group = "client"}),
    awful.key({ modkey, "Control",  }, "space", awful.client.floating.toggle,
        {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control", }, "Return", function (c) c:swap(awful.client.getmaster()) end,
        {description = "move to master", group = "client"}),
    awful.key({ modkey, }, "o", function (c) c:move_to_screen() end,
        {description = "move to screen", group = "client"}),
    awful.key({ modkey, }, "t", function (c) c.ontop = not c.ontop end,
        {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey, }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end,
        {description = "minimize", group = "client"}),
    awful.key({ modkey, }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control", }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift", }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey, }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control", }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift", }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift", }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
            {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen,
        },
    },

    -- Floating clients.
    {
        rule_any = {
            instance = {
                "DTA",  -- Firefox addon DownThemAll.
                "copyq",  -- Includes session name in class.
            },
            class = {
                "Arandr",
                "Gpick",
                "Kruler",
                "MessageWin",  -- kalarm.
                "Sxiv",
                "Wpa_gui",
                "pinentry",
                "veromix",
                "xtightvncviewer",
            },
            name = {
                "Event Tester",  -- xev.
            },
            role = {
                "AlarmWindow",  -- Thunderbird's calendar.
                "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = { floating = true, }
    },

    -- Add titlebars to normal clients and dialogs
    {
        rule_any = {
            type = { "normal", "dialog", },
        },
        properties = { titlebars_enabled = true, }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },

    {
        rule_any = {
            class = {
                "Dunst"
            }
        },
        properties = {
            floating = true,
            focus = false,
            raise = true,
        },
    }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({}, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({}, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c):setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton(c),
            awful.titlebar.widget.ontopbutton(c),
            awful.titlebar.widget.closebutton(c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ autorun
awful.spawn.with_shell("~/.config/awesome/scripts/autorun.sh")
-- }}}

-- {{{ external event receivers
-- since the dbus api is barely usable and not documented
-- use (global) functions and call them using `echo -e "something() | awesome-client"`
function something()
    naughty.notify {text = "ok" }
end
-- }}}
