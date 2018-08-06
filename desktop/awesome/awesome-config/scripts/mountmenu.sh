#!/bin/sh

# grab all devices (not partitions)
devices=$(lsblk -lp -o "NAME,SIZE,TRAN,VENDOR,MODEL" -d | tail -n +2)
[[ "$devices" = "" ]] && exit 1

# loop over devices and grab partitions and create nicely formatted list
partitions=""
IFS=$'\n'
set -f
for devinfo in $devices
do
    dev=$(echo $devinfo | awk '{print $1}')
    tran=$(echo $devinfo | awk '{print $3}')
    vendor=$(echo $devinfo | awk '{print $4}')

    add=$(lsblk -lp -o "NAME,LABEL,SIZE,TYPE,MOUNTPOINT" $dev | grep "part $" | awk -v vendor="$vendor" '{print $1, "(" $2 ")", vendor, "(" $3 ")"}')
    partitions=$(echo -e "${partitions}\n${add}")
done

chosen=$(echo "$partitions" | grep -E ".+" | dmenu -i -p "Choose device to mount?" | awk '{print $1}')
[[ "$chosen" = "" ]] && exit 1

# try to mount the partition via gio, returns the mountpoint
result=$(gio mount -d "$chosen")

if [[ "$?" = 0 ]]
then
    mountpoint=$(echo $result | awk '{print $4}' | sed -r 's/\.//g')
    notify-send "$result"
else
    notify-send -u critical "Failed to mount $chosen"
    exit 1
fi

