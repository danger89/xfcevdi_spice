# Xubuntu Desktop with SPICE
FROM ubuntu:focal

LABEL maintainer="melroy@melroy.org"

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_PROXY
ENV DISPLAY ${DISPLAY:-:1}
ENV DBUS_SYSTEM_BUS_ADDRESS 'unix:path=/var/run/dbus/system_bus_socket'

WORKDIR /app

# Enable APT proxy (if APT_PROXY is set)
COPY ./configs/apt.conf ./
COPY ./apt_proxy.sh ./
RUN ./apt_proxy.sh

# Install packages
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get -y install software-properties-common apt-utils
RUN apt-get -y --no-install-recommends install xserver-xorg-video-qxl spice-vdagent xserver-xspice ffmpeg sudo locales at-spi2-core dialog spice-html5 websockify dirmngr libgtk2.0-0 libgtk-3-0 libsoup2.4-1 x11-xserver-utils exo-utils supervisor \
    && apt-get -y --no-install-recommends install libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio \
    && apt-get -y --no-install-recommends install xfce4 \
    && apt-get -y --no-install-recommends install xfdesktop4 xfce4-appfinder tumbler xfce4-terminal xfce4-clipman-plugin xfce4-screenshooter xfce4-notifyd \
    && apt-get -y --no-install-recommends install xfce4-pulseaudio-plugin xfce4-statusnotifier-plugin \
    && apt-get -y --no-install-recommends install pulseaudio pavucontrol git dnsutils dbus-x11 rsyslog \
    && apt-get -y --no-install-recommends install net-tools libnss3-tools wget ca-certificates bzip2 sudo curl zip xdg-utils xz-utils util-linux x11-utils x11-xkb-utils tmux
RUN add-apt-repository ppa:papirus/papirus
RUN apt-get update \
    && apt-get -y --no-install-recommends install fonts-ubuntu fonts-dejavu-core breeze-gtk-theme papirus-icon-theme
# Get latest Spice html5 client
RUN git clone https://gitlab.freedesktop.org/spice/spice-html5 /app/spice-html5
# Additional applications
RUN apt-get -y --no-install-recommends install firefox htop nano gnome-calculator mousepad
# Clean-up
RUN apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apk/*

VOLUME /home

COPY ./configs/50-nostandby.conf /usr/share/X11/xorg.conf.d
COPY ./configs/xfcesettings.desktop /etc/xdg/autostart/
COPY ./configs/resolution.desktop /etc/xdg/autostart/
COPY ./configs/keyboard.desktop /etc/xdg/autostart/
COPY ./configs/sound.desktop /etc/xdg/autostart/
COPY ./configs/client.conf ./
COPY ./configs/default.pa ./
COPY ./configs/terminalrc ./
COPY ./xfce_settings.sh ./
COPY ./sound.sh ./
COPY ./run.sh ./

EXPOSE 5900 5959 8080

# TODO: Use entrypoint of the script?
# ENTRYPOINT ["/bin/run.sh"]
# and CMD for supervisord?
# See: https://github.com/danielguerra69/alpine-xfce4-xrdp/blob/master/etc/supervisord.conf
# CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]

CMD ./run.sh
