#!/bin/env sh

# Exit script if any of the commands fail
set -e

filepath="/usr/share/i18n/locales/custom"

sudo cp custom $filepath
sudo chown root:root $filepath
sudo chmod 644 $filepath

sudo localedef -f UTF-8 -i custom custom.UTF-8

sudo cp locale.conf /etc/locale.conf

