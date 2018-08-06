-- This file contains a wibox.widget.imagebox for every used icon
--
-- Author: Matthias Seiffert
local wibox = require("wibox")
local gears = require("gears")

local path_prefix = "/home/ms/.config/awesome/icons/"
local icon_suffix = "_white"

local function get_path(name)
    return path_prefix .. name .. ".png"
end

local function create(name)
    return wibox.widget {
        widget = wibox.widget.imagebox,
        image = get_path(name),
    }
end

local icons = {
    "wifi_on",
    "wifi_off",
    "volume_off",
    "volume_low",
    "volume_medium",
    "volume_high",
    "battery_alert",
    "battery_unknown",
}

local battery = {}
for i = 0, 10 do
    battery[i+1] = "battery_" .. (i * 10)
end

local battery_charging = {}
for i = 0, 10 do
    battery_charging[i+1] = "battery_charging_" .. (i * 10)
end

local generated_icons = {}

for i, v in pairs(icons) do
    generated_icons[v] = create(v .. icon_suffix)
end

for i, v in pairs(battery) do
    generated_icons[v] = create(v .. icon_suffix)
end

for i, v in pairs(battery_charging) do
    generated_icons[v] = create(v .. icon_suffix)
end

return generated_icons
