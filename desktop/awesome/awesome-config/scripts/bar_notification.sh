#!/bin/bash

### Displays a bar notification
###
### Author: Matthias Seiffert
###
### Usage: bar_notification.sh Summary Icon Percentage Last_Notification_Id

title=$1
icon=$2
percentage=$(printf "%.0f" $3)
last_id=${4:-0}
timeout=$((${NOTIFICATION_TIMEOUT:-8} * 1000))

let num_bars=$percentage/3+1
bar=$(seq -s "─" $num_bars | sed 's/[0-9]//g')
summary="$title [$(printf "%3d" $percentage)%]"

dunstify -p -i $icon -t $timeout -r $last_id -u normal "$summary" "$bar"

