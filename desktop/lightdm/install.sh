#!/bin/sh

sudo yaourt -S lightdm lightdm-mini-greeter light-locker

# insert the current user in the lightdm mini greeter config and copy it to the right place
sed "s/YOUR_USER/$USER/" lightdm-mini-greeter.conf | sudo tee /etc/lightdm/lightdm-mini-greeter.conf > /dev/null
