-- Battery widget
--
-- Author: Matthias Seiffert
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local lain = require("lain")

local icons = require("libs.icons")

local function create_battery_widget()
    local battext = wibox.widget {
        widget = wibox.widget.textbox,
        text = "?",
    }
    -- Create wibox with batwidget
    local batbox = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        spacing = 5,
        icons.battery_alert,
        battext,
    }

    local function change_text(text)
        battext:set_markup_silently(text)
    end
    local function change_icon(icon)
        batbox.children[1] = icon
    end
    local function get_icon(percentage, status)
        local normalized = math.floor(percentage / 10) * 10
        local name = "battery_unknown"

        if status == "Charging" then
            name = "battery_charging_" .. normalized
        elseif status == "Discharging" then
            name = "battery_" .. normalized
        elseif normalized == 100 then
            name = "battery_100"
        end

        return icons[name]
    end

    -- Register battery widget
    local options = {
        timeout = 5,
        batteries = { "BAT0", "BAT1", },
        ac = "AC",
        notify = "on",
        n_perc = {5, 15}, -- critical and low battery percentages
        settings = function ()
            --widget:set_markup(bat_now.status .. " " .. bat_now.perc .. "%") 
            local percentage = bat_now.perc
            local status = bat_now.status
            local level = 0
            local markup = "N/A"

            if type(percentage) == "number" then
                level = percentage / 100
                markup = percentage .. "%"
            end

            markup = "<span color='#ffffff'>" .. markup .. "</span>"

            change_text(markup)
            change_icon(get_icon(percentage, status))
        end
    }

    -- TODO get data directly from "upower -i /org/freedesktop/UPower/devices/battery_BAT1 | grep -E "state|to\ full|percentage"
    -- because this widget is not working quite right
    local bar = lain.widget.bat(options)

    -- tooltip
    batbox_tooltip = awful.tooltip {
        objects = { batbox, },
        timer_function = function()
            local output = "Remaining time: " .. bat_now.time .."\n"

            if bat_now.ac_status == 0 then
                output = output .. "AC unplugged"
            else
                output = output .. "AC plugged in"
            end

            for i = 1, #options.batteries do
                local bat = options.batteries[i]
                output = output .. string.format("\n\n<b>%s</b> (%s)\nLevel: %d%%", bat, bat_now.n_status[i], bat_now.n_perc[i])
            end
            return output
        end,
    }

    batbox:buttons(gears.table.join(
        awful.button({}, 1, function ()
            bar.update()
        end)
    ))

    return batbox
end

return create_battery_widget
