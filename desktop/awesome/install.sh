#!/bin/sh

yaourt -S betterlockscreen xss-lock

# create a link to the awesome config
ln -s $(pwd)/config ~/.config/awesome

# copy the keyboard config
sudo cp 90-keyboard.conf /etc/X11/xorg.conf.d/
