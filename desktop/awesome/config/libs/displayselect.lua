-- Simple script to show a display selection prompt
-- Idea stolen from https://github.com/LukeSmithxyz/voidrice/blob/master/.scripts/displayselect
--
-- Author: Matthias Seiffert
local awful = require("awful")
local naughty = require("naughty")
local gears = require("gears")

local choises = {
    internal = "xrandr \
        eDP1 --auto \
        HDMI1 --off \
        HDMI2 --off \
        DP1 --off \
        DP2 --off \
    ",
    multi = "xrandr \
        eDP1 --auto \
        HDMI1 --auto --above eDP1 \
        HDMI2 --auto --above eDP1 \
        DP1 --auto --above eDP1 \
        DP2 --auto --above eDP1 \
    ",
    manual = "arandr",
}

local function keys()
    local keys = {}
    for k, v in pairs(choises) do
        keys[#keys+1] = k
    end
    return keys
end

local function cmd()
    local dmenu = "dmenu -i -p 'Display options:' "
    local options = table.concat(keys(), "\n")
    return "echo \"" .. options .. "\" | " .. dmenu
end

-- TODO
local function prompt(widget)
    awful.spawn.easy_async_with_shell(cmd(), function (stdout, stderr, reason, code)
        if code ~= 0 then return end
        
        local choise = stdout:gsub("%s+", "")

        if choises[choise] then
            awful.spawn(choises[choise])
        end
    end)
end

return {
    prompt = prompt,
}
