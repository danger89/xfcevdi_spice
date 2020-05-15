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
SPICE_SOUND=${SPICE_SOUND:-false}
PASS_NEEDED=${PASS_NEEDED:-"false"}
SUDO=${SUDO:-false}

# Generate new locale & set timezone
locale-gen $SPICE_LOCAL
echo $TIMEZONE > /etc/timezone

# Create user and set password
useradd -ms /bin/bash -u $SPICE_UID $SPICE_USER
echo "$SPICE_USER:$SPICE_PASSWD" | chpasswd
# Add new user to several groups
if [ "$SUDO" = false ] ; then
  usermod -a -G sudo,adm,audio,video,plugdev $SPICE_USER
fi
if [ "$PASS_NEEDED" = false ] ; then
  # No password needed
  echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
fi

# Adapt several files
sed -i "s|#Option \"SpicePassword\" \"\"|Option \"SpicePassword\" \"$SPICE_PASSWD\"|" /etc/X11/spiceqxl.xorg.conf
unset SPICE_PASSWD
update-locale LANG=$SPICE_LOCAL
sed -i "s/XKBLAYOUT=.*/XKBLAYOUT=\"$SPICE_KB_LAYOUT\"/" /etc/default/keyboard
sed -i "s/XKBVARIANT=.*/XKBVARIANT=\"$SPICE_KB_VARIANT\"/" /etc/default/keyboard
sed -i "s/SPICE_KB_LAYOUT/$SPICE_KB_LAYOUT/" /etc/xdg/autostart/keyboard.desktop
sed -i "s/SPICE_KB_VARIANT/$SPICE_KB_VARIANT/" /etc/xdg/autostart/keyboard.desktop
sed -i "s/SPICE_RES/$SPICE_RES/" /etc/xdg/autostart/resolution.desktop
sed -i "s/SPICE_USER/$SPICE_USER/" /etc/xdg/autostart/xfcesettings.desktop
sed -i "s/SPICE_SOUND/$SPICE_SOUND/" /etc/xdg/autostart/xfcesettings.desktop
sed -i "s/SPICE_USER/$SPICE_USER/" /etc/xdg/autostart/sound.desktop

# Enable PulseAudio
if [ "$SPICE_SOUND" = true ] ; then
  mkdir /tmp/audio_fifo
  chown $SPICE_USER.$SPICE_USER /tmp/audio_fifo
  FIFO=/tmp/audio_fifo/audio.fifo

  # Append the pipe module with Pulse Audio default file
  echo "load-module module-pipe-sink sink_name=fifo file=$FIFO format=s16 rate=48000 channels=2" >> /app/default.pa
else
  # Disable audio
  rm -rf /etc/xdg/autostart/sound.desktop
fi

# Start system dbus & syslog
service rsyslog start
service dbus start

# Serve Spice client5 on port 8080
cd /app/spice-html5
mv spice.html index.html 2> /dev/null
python3 -m http.server 8080 > /dev/null 2>&1 &
cd /home/$SPICE_USER

# Workaround red-hat bug #1773148 in sudo
echo "Set disable_coredump false" >> /etc/sudo.conf

# TODO: --vdagent?
# Start both X server with Spice Server (don't ask for login)
if [ "$SPICE_SOUND" = true ] ; then
  Xspice --port 5900 --audio-fifo-dir=/tmp/audio_fifo --disable-ticketing $DISPLAY > /dev/null 2>&1 &
else
  Xspice --port 5900 --disable-ticketing $DISPLAY > /dev/null 2>&1 &
fi

sleep 1

# Enable WebSockify for SPICE HTML5 client
websockify 5959 localhost:5900 > /dev/null 2>&1 &

# Create user runtime directory
mkdir -p /run/user/$SPICE_UID
chown $SPICE_USER.$SPICE_USER /run/user/$SPICE_UID

# Export some env variables
export HOME=/home/$SPICE_USER
export DESKTOP_SESSION=xfce
export XDG_SESSION_TYPE=x11
export XDG_DATA_DIRS=/usr/share/xfce4:/usr/local/share:/usr/share
export XDG_SESSION_DESKTOP=xfce
export XDG_CURRENT_DESKTOP=XFCE
export XDG_CONFIG_DIRS=/etc/xdg/xdg-xfce:/etc/xdg
export XDG_RUNTIME_DIR=/run/user/$SPICE_UID

# Start DBUS session with XFCE4 session
# TODO: Later add also > /dev/null or add to supervisor
su $SPICE_USER -c "DISPLAY=$DISPLAY dbus-launch --exit-with-session xfce4-session"
