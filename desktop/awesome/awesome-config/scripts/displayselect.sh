#!/bin/sh

### Show a dmenu to allow the user to select a display configuration
###
### Author: Matthias Seiffert

### Based on: https://github.com/LukeSmithxyz/voidrice/blob/master/.scripts/displayselect

choices="laptop\nlaptopdual\nDP\nHDMI\nManual"
chosen=$(echo -e "$choices" | dmenu -i -p "Display options:")

case "$chosen" in
	laptopdual) xrandr --output eDP1 --auto \
            --output HDMI1 --auto --above eDP1 \
            --output HDMI2 --auto --above eDP1 \
            --output DP1 --auto --above eDP1 \
            --output DP2 --auto --above eDP1 ;;
	laptop) xrandr --output eDP1 --auto \
            --output HDMI1 --off \
            --output HDMI2 --off \
            --output DP1 --off \
            --output DP2 --off ;;
	DP) xrandr --output eDP1 --auto \
            --output HDMI1 --off \
            --output HDMI2 --off \
            --output DP1 --auto --same-as eDP1 \
            --output DP2 --auto --same-as eDP1 ;;
	HDMI) xrandr --output eDP1 --auto \
            --output HDMI1 --auto --same-as eDP1 \
            --output HDMI2 --auto --same-as eDP1 \
            --output DP1 --off \
            --output DP2 --off ;;
	Manual) arandr ;;
esac
