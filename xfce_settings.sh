#!/usr/bin/env bash
# Additional changes to XFCE settings (xsettings.xml)
xfconf-query -c xsettings -p /Net/ThemeName -s "Breeze-Dark"
xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus-Dark"
xfconf-query -c xsettings -p /Gtk/FontName -s "Ubuntu 10"

# Move terminalrc config to correct location
mkdir -p /home/$1/.config/xfce4/terminal/
cp -rf /app/terminalrc /home/$1/.config/xfce4/terminal/

# Delete PulseAudio (plugin-8) if sound is set to false
if [ "$2" = false ] ; then
  xfconf-query -c xfce4-panel -p /plugins/plugin-8 --reset --recursive
  # Reset
  xfce4-panel -r
fi

sleep 2

# Change Firefox (launcher-19) icon in panel 2
filename=$(ls /home/$1/.config/xfce4/panel/launcher-19/ | head -1)
sed -i "s/Icon=.*/Icon=firefox/" /home/$1/.config/xfce4/panel/launcher-19/$filename
