-- xbacklight wrapper with notifications
--
-- Author: Matthias Seiffert
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")

local MIN_BRIGHTNESS = 10

local function current_brightness()
    local handle = io.popen("xbacklight -get")
    local content = handle:read("*all")
    handle:close()
    return math.floor(tonumber(content))
end

local notification = nil

local preset = {
    timeout = 2,
    font = "Monospace 10",
}

local function change(amount)
    if amount < 0 then
        -- display nitification anyway
        if current_brightness() > MIN_BRIGHTNESS then
            awful.spawn("xbacklight -dec " .. -amount .. " -time 10")
        end
    else
        awful.spawn("xbacklight -inc " .. amount .. " -time 10")
    end
    
    local level = current_brightness()

    preset.title = string.format("Backlight - %s%%", level)

    -- TODO move to util file
    -- notification stolen from https://github.com/lcpz/lain

    -- tot is the maximum number of ticks to display in the notification
    -- fallback: default horizontal wibox height
    local wib, tot = awful.screen.focused().mywibox, 20

    -- if we can grab mywibox, tot is defined as its height if
    -- horizontal, or width otherwise
    if wib then
        if wib.position == "left" or wib.position == "right" then
            tot = wib.width
        else
            tot = wib.height
        end
    end

    local int = math.modf((level / 100) * tot)
    preset.text = string.format("[%s%s]", string.rep("|", int), string.rep(" ", tot - int))

    if not notification then
        notification = naughty.notify {
            preset = preset,
            destroy = function () notification = nil end,
        }
    else
        naughty.replace_text(notification, preset.title, preset.text)
        naughty.reset_timeout(notification, preset.timeout)
    end
end

return {
    change = change,
    current = current_brightness,
}
