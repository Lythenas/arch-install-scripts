-- xbacklight wrapper with notifications
--
-- Author: Matthias Seiffert
local awful = require("awful")

local function change(amount)
    awful.spawn.with_shell("~/.config/awesome/scripts/backlight.sh "..tostring(amount))
end

return {
    change = change,
}
