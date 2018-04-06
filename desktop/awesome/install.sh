#!/bin/sh

sudo ln -s $(pwd)/lock /usr/bin/
sudo cp lock@.service /etc/systemd/system/
sudo systemctl enable lock@$USER.service
