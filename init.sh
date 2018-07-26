#!/bin/sh

echo "Installing aurman"

git clone https://aur.archlinux.org/aurman.git
cd aurman
makepkg -si
