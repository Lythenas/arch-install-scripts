-- xbacklight wrapper with notifications
--
-- Author: Matthias Seiffert
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local notifications = require("libs.notifications")

local MIN_BRIGHTNESS = 10

local function current_brightness()
    local handle = io.popen("xbacklight -get")
    local content = handle:read("*all")
    handle:close()
    return math.floor(tonumber(content))
end

local notification = notifications.bar("Backlight")

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

    notification.show(level)
end

return {
    change = change,
    current = current_brightness,
}
