#!/bin/sh

function copy {
    if ! pgrep $1 ;
    then
        sudo cp $1 /etc/X11/xorg.conf.d/
    fi
}

copy 00-keyboard.conf
copy 90-keyboard.conf

