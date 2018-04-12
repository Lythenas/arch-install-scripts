-- Pretty notifications
--
-- Author: Matthias Seiffert
--
-- Progressbar notification stole from https://github.com/lcpz/lain and modified

local awful = require("awful")
local naughty = require("naughty")

local function get_progressbar_size()
    local wib, tot = awful.screen.focused().mywibox, 20
    if wib then
        if wib.position == "left" or wib.position == "right" then
            tot = wib.width
        else
            tot = wib.height
        end
    end
    return tot
end

return {
    bar = function (title)
        local notification = nil

        local preset = {
            timeout = 2,
            font = "Monospace 10",
        }
        
        return {
            show = function (level, alt)
                local size = get_progressbar_size()

                if alt == nil then
                    alt = tostring(level) .. "%"
                end

                preset.title = string.format("%s - %s", title, alt)

                local bars = math.modf(level / 100 * size)
                preset.text = string.format("[%s%s]", string.rep("|", bars), string.rep(" ", size - bars))

                if not notification then
                    notification = naughty.notify {
                        preset = preset,
                        destroy = function () notification = nil end,
                    }
                else
                    naughty.replace_text(notification, preset.title, preset.text)
                    naughty.reset_timeout(notification, preset.timeout)
                end
            end,
        }
    end,
}
