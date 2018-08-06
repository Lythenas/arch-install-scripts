#!/bin/sh

# grab all mounted partitions
partitions=$(lsblk -lp -o "NAME,SIZE,LABEL,TYPE,MOUNTPOINT" | grep -E "part /run/media/$USER/.+$" | awk '{print $1, "(" $2 ",", $3 ")"}')

device=$(echo "$partitions" | grep -E ".+" | dmenu -i -p "Choose device to unmount?" | awk '{print $1}')
[[ "$device" = "" ]] && exit 1

echo $device

location=$(lsblk -lp -o "MOUNTPOINT" $device | tail -n +2)
[[ "$location" = "" ]] && exit 2

gio mount -u $location

if [[ $? -eq 0 ]]
then
    notify-send "$device has been unmounted from $location"
else
    notify-send -u critical "Failed to unmount $device from $location"
fi
