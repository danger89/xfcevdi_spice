#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

SPICE_RES=${SPICE_RES:-"1280x960"}
SPICE_LOCAL=${SPICE_LOCAL:-"en_US.UTF-8"}
TIMEZONE=${TIMEZONE:-"Europe/Paris"}
SPICE_USER=${SPICE_USER:-"user"}
SPICE_UID=${SPICE_UID:-"1000"}
SPICE_GID=${SPICE_GID:-"1000"}
SPICE_PASSWD=${SPICE_PASSWD:-"password"}
SPICE_KB="us"
SUDO=${SUDO:-"user"}
locale-gen $SPICE_LOCAL
echo $TIMEZONE > /etc/timezone
useradd -ms /bin/bash -u $SPICE_UID $SPICE_USER
echo "$SPICE_USER:$SPICE_PASSWD" | chpasswd
sed -i "s|#Option \"SpicePassword\" \"\"|Option \"SpicePassword\" \"$SPICE_PASSWD\"|" /etc/X11/spiceqxl.xorg.conf
unset SPICE_PASSWD
update-locale LANG=$SPICE_LOCAL
sed -i "s/XKBLAYOUT=.*/XKBLAYOUT=\"$SPICE_KB\"/" /etc/default/keyboard
sed -i "s/SPICE_KB/$SPICE_KB/" /etc/xdg/autostart/keyboard.desktop
sed -i "s/SPICE_RES/$SPICE_RES/" /etc/xdg/autostart/resolution.desktop
# add sudo group to user
if [ "$SUDO" != "NO" ]; then
        sed -i "s/^\(sudo:.*\)/\1$SPICE_USER/" /etc/group
fi
cd /home/$SPICE_USER

# Pulseaudio (https://github.com/ikreymer/spice-chrome/blob/master/entry_point.sh)
mkdir /tmp/audio_fifo
FIFO=/tmp/audio_fifo/audio.fifo
chmod a+w /etc/pulse/client.conf
chmod a+w /etc/pulse/default.pa

echo "default-sink = fifo_output" >> /etc/pulse/client.conf
echo "load-module module-x11-publish" >> /etc/pulse/default.pa
echo "load-module module-pipe-sink sink_name=fifo_output file=$FIFO format=s16 rate=48000 channels=2" >> /etc/pulse/default.pa

# TODO: --vdagent?
# Start both X server with Spice Server (don't ask for login)
Xspice --port 5900 --audio-fifo-dir=/tmp/audio_fifo --disable-ticketing $DISPLAY > /dev/null 2>&1 &

sleep 1

# Start DBUS with XFCE4 session
# TODO: Later add also > /dev/null
su $SPICE_USER -c "DISPLAY=$DISPLAY dbus-launch --exit-with-session xfce4-session"


### disable screensaver and power management
# xset -dpms &
# xset s noblank &
# xset s off

