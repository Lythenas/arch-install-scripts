local notify = function (obj)
    local app_name = "awesomewm"
    local replaces_id = obj.replaces_id or 0
    local app_icon = ""
    local summary = obj.title or ""
    local body = obj.text or ""
    local actions = ""
    local hints = ""
    local expire_timeout = 0

    if obj.timeout then expire_timeout = obj.timeout * 1000 end

    local cmd = "gdbus call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications --method org.freedesktop.Notifications.Notify \""..app_name.."\" "..tostring(replaces_id).." \""..app_icon.."\" \""..summary.."\" \""..body.."\" \\[\\] {} "..tostring(expire_timeout)

    -- awesomes dbus interface is bad so we just call dbus-send in a shell
    local f = io.popen(cmd)
    local return_id = f:read('*a')
    f:close()

    replaces_id = string.match(return_id, "^%(uint32 (%d+),%)")

    return {
        app_name = app_name,
        replaces_id = replaces_id,
        app_icon = app_icon,
        title = summary,
        text = body,
        timeout = expire_timeout
    }
end

local replace_text = function (notification, title, text)
    local notification = notification
    notification.title = title
    notification.text = text
    notify(notification)
end

local reset_timeout = function (notification, timeout)
    local notification = notification
    notification.timeout = timeout
    notify(notification)
end

return {
    notify = notify,
    replace_text = replace_text,
    reset_timeout = reset_timeout,
    config = {presets = {}, defaults = {}},
}

