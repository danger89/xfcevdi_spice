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
SPICE_KB_LAYOUT=${SPICE_KB_LAYOUT:-"us"}
SPICE_KB_VARIANT=${SPICE_KB_VARIANT:-"euro"}

SUDO=${SUDO:-"user"}
locale-gen $SPICE_LOCAL
echo $TIMEZONE > /etc/timezone
useradd -ms /bin/bash -u $SPICE_UID $SPICE_USER
echo "$SPICE_USER:$SPICE_PASSWD" | chpasswd
sed -i "s|#Option \"SpicePassword\" \"\"|Option \"SpicePassword\" \"$SPICE_PASSWD\"|" /etc/X11/spiceqxl.xorg.conf
unset SPICE_PASSWD
update-locale LANG=$SPICE_LOCAL
sed -i "s/XKBLAYOUT=.*/XKBLAYOUT=\"$SPICE_KB_LAYOUT\"/" /etc/default/keyboard
sed -i "s/XKBVARIANT=.*/XKBVARIANT=\"$SPICE_KB_VARIANT\"/" /etc/default/keyboard
sed -i "s/SPICE_KB_LAYOUT/$SPICE_KB_LAYOUT/" /etc/xdg/autostart/keyboard.desktop
sed -i "s/SPICE_KB_VARIANT/$SPICE_KB_VARIANT/" /etc/xdg/autostart/keyboard.desktop
sed -i "s/SPICE_RES/$SPICE_RES/" /etc/xdg/autostart/resolution.desktop
sed -i "s/SPICE_USER/$SPICE_USER/" /etc/xdg/autostart/xfceboot.desktop
# add extra groups to user
if [ "$SUDO" != "NO" ]; then
        usermod -a -G sudo,adm,audio,video,plugdev $SPICE_USER
fi
chmod a+x /app/xfce_settings.sh

# Serve Spice client5 on port 8080
cd /app/spice-html5
mv spice.html index.html 2> /dev/null
python3 -m http.server 8080 > /dev/null 2>&1 &

# Workaround red-hat bug #1773148 in sudo
echo "Set disable_coredump false" >> /etc/sudo.conf

# Start system dbus
service dbus start

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

websockify 5959 localhost:5900 > /dev/null 2>&1 &

# Start DBUS with XFCE4 session
# TODO: Later add also > /dev/null
su $SPICE_USER -c "DISPLAY=$DISPLAY dbus-launch --exit-with-session xfce4-session"

### disable screensaver and power management
# xset -dpms &
# xset s noblank &
# xset s off

