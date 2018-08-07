-- Volume widget and amixer command wrapper
--
-- Author: Matthias Seiffert
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local icons = require("libs.icons")

local iconbox = wibox.widget {
    layout = wibox.layout.align.horizontal,
    icons.volume_off,
}

local function amixer(callback)
    local cmd = "(z=$(amixer get Master); (echo $z | grep -Po \"[0-9]+(?=%)\" | tail -1); (echo $z | grep -Fo \"[off]\" | tail -1))"
    awful.spawn.easy_async_with_shell(cmd, function (stdout, stderr, reason, code)
        local lines = gears.string.split(stdout, "\n")
        local level = tonumber(lines[1])
        local muted = not not lines[2]
        callback(level, muted)
    end)
end

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
        awful.spawn.with_shell("~/.config/awesome/scripts/volume.sh toggle")
        update(true)
    end,
    increase = function (amount)
        if amount == nil then amount = 10 end
        awful.spawn.with_shell("~/.config/awesome/scripts/volume.sh "..tostring(amount))
        update(true)
    end,
    decrease = function (amount)
        if amount == nil then amount = 10 end
        awful.spawn.with_shell("~/.config/awesome/scripts/volume.sh -"..tostring(amount))
        update(true)
    end,
}

iconbox:buttons(gears.table.join(
    awful.button({}, 1, function () volume.toggle() end)
))

return volume
