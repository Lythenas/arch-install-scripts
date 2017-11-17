# Abort if an error occurs.
set -e

echo "Installing Nightly"

sudo mkdir /opt/firefox
sudo chown $USER:users /opt/firefox

echo "Downloading Firefox Nightly"

curl -L -o /tmp/nightly.zip.bz2 "https://download.mozilla.org/?product=firefox-nightly-latest-ssl&os=linux64&lang=en-US"

echo "Unzipping Nightly to /opt/firefox"

tar -xvjf /tmp/nightly.zip.bz2 -C /opt

echo "Adding Nightly Launcher Shortcuts"

desktop-file-validate nightly.desktop
desktop-file-install --dir=/home/$USER/.local/share/applications nightly.desktop

echo "Done installing Nighlty"

