# LightDM

To install LightDM run the `install.sh` script. Then enable LightDM with `systemctl enable lightdm`.

Modify `/etc/lightdm/lightdm.conf` and change the line `greeter-session=something` to `greeter-session=lightdm-mini-greeter`.

Finally, modify `/etc/lightdm/lightdm-mini-greeter.conf` and insert your username at the line `user = YOUR_USER`.
