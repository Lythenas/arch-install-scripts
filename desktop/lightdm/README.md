# LightDM

To install LightDM run the `install.sh` script. Then enable LightDM with `systemctl enable lightdm`.

Modify `/etc/lightdm/lightdm.conf` and change the line `greeter-session=something` to `greeter-session=lightdm-webkit2-greeter`.

Finally, modify `/etc/lightdm/lightdm-webkit2-greeter.conf` and insert `arch` at `webkit_theme = something`.
