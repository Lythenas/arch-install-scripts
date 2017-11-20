# Wifi Setup

Copy the `eduroam` file to `/etc/NetworkManager/system-connections/`.

You also have to edit the `identity` and `password` field. Add `username:group` to permissions if you don't want everyone to use it. You probably have to change the location of the `ca\_cert`.

## Note

If you want to manually configure eduroam first try to use the [official eduroam installer](https://cat.eduroam.de). If that doesn't work try to set IPv6 to local only.
