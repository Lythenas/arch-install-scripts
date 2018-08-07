#!/bin/bash

### Increases or decreases volume by the given amount or toggle mute
### and displays a notification
###
### Author: Matthias Seiffert
###
### Usage: volume.sh toggle|amount
###   if the first parameter is toggle then the mute state is toggled
###   amount can be negative to decrease volume

dir=$(dirname $0)
tag=volume

if [[ $1 -eq "toggle" ]]
then
    amixer set Master toggle > /dev/null
else
    amount=$(printf "%.0f" $1)
    if [[ $amount -lt 0 ]]
    then
        let amount=-$amount
        amixer set Master "$amount%-" > /dev/null
    else
        amixer set Master "$amount%+" > /dev/null
    fi
fi

volume=$(amixer get Master | grep -Po "[0-9]+(?=%)" | tail -1)
summary=Volume

if amixer get Master | grep -Fq "[off]"
then
    summary="$summary - Muted"
    icon="audio-volume-muted"
else
    if [[ $volume -lt 33 ]]
    then
        icon="audio-volume-low"
    elif [[ $volume -lt 66 ]]
    then
        icon="audio-volume-medium"
    else
        icon="audio-volume-high"
    fi
fi

last_id=$($dir/notification_id.sh $tag)
new_id=$($dir/bar_notification.sh "$summary" "$icon" $volume $last_id)
$dir/notification_id.sh $tag $new_id > /dev/null

