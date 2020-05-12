#!/usr/bin/env bash
# Additional changes to XFCE settings (xsettings.xml)
xfconf-query -c xsettings -p /Net/ThemeName -s "Breeze-Dark"
xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus-Dark"
xfconf-query -c xsettings -p /Gtk/FontName -s "Ubuntu 10"
