#!/bin/bash

### Increases or decreases brightness by the given amount and displays a notification
###
### Author: Matthias Seiffert
###
### Usage: backlight.sh amount
###   amount can be negative to decrease brightness

dir=$(dirname $0)

min=10
time=10

amount=$(printf "%.0f" $1)
current=$(printf "%.0f" $(xbacklight -get))

if [[ $amount -lt 0 ]]
then
    if [[ $current -gt $min ]]
    then
        let amount=-$amount
        xbacklight -dec $amount -time $time
    fi
else
    xbacklight -inc $amount -time $time
fi

let sleeptime=($time+1)/1000
sleep $sleeptime
current=$(xbacklight -get)

last_id=$($dir/notification_id.sh "backlight")
new_id=$($dir/bar_notification.sh "Backlight" "pda" $current $last_id)
$dir/notification_id.sh "backlight" $new_id > /dev/null

