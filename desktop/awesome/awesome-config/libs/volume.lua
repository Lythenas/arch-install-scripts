-- Volume widget and amixer command wrapper
--
-- Author: Matthias Seiffert
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local icons = require("libs.icons")
local notifications = require("libs.notifications")

local iconbox = wibox.widget {
    layout = wibox.layout.align.horizontal,
    icons.volume_off,
}

local function amixer(callback)
    local cmd = "amixer get Master | sed -n '/.*\\[\\([0-9]*\\)%\\].*\\[\\(.*\\)\\].*/s//\\1 \\2/p'"
    awful.spawn.easy_async({"bash", "-c", cmd}, function (stdout, stderr, reason, code)
        local lines = gears.string.split(stdout, "\n")
        local info = gears.string.split(lines[1], " ")
        local level = tonumber(info[1])
        local muted = info[2] == "off"

        callback(level, muted)
    end)
end

local notification = notifications.bar("Volume")

local function update(notify)
    amixer(function (level, muted)
        if muted or level == 0 then
            iconbox.first = icons.volume_off
        elseif level > 80 then
            iconbox.first = icons.volume_high
        elseif level > 40 then
            iconbox.first = icons.volume_medium
        else
            iconbox.first = icons.volume_low
        end

        if notify then
            if muted then
                notification.show(level, "Muted")
            else
                notification.show(level)
            end
        end
    end)
end

gears.timer {
    timeout = 5,
    call_now = true,
    autostart = true,
    callback = function () update(false) end,
}

update(false)

local volume = {
    widget = iconbox,
    mixer = function ()
        awful.spawn("alsamixer")
    end,
    toggle = function ()
        os.execute("amixer set Master toggle")
        update(true)
    end,
    increase = function (amount)
        os.execute("amixer set Master 10%+")
        update(true)
    end,
    decrease = function (amount)
        os.execute("amixer set Master 10%-")
        update(true)
    end,
    mute = function (amount)

    end,
    unmute = function (amount)

    end,
}

iconbox:buttons(gears.table.join(
    awful.button({}, 1, function () volume.toggle() end)
))

return volume
