# Xubuntu Desktop with SPICE
FROM ubuntu:focal

LABEL maintainer="melroy@melroy.org"

ARG DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:2.0
ENV DBUS_SYSTEM_BUS_ADDRESS='unix:path=/var/run/dbus/system_bus_socket'

WORKDIR /app

RUN apt-get update && apt-get -y install software-properties-common
RUN apt-get upgrade -y
RUN apt-get -y --no-install-recommends install xserver-xspice x11-xserver-utils locales apt-utils at-spi2-core dialog spice-html5 websockify
RUN apt-get update && apt-get -y --no-install-recommends install xfce4 supervisor
RUN add-apt-repository ppa:papirus/papirus
RUN apt-get update && apt-get -y --no-install-recommends install xfce4-notifyd xfce4-statusnotifier-plugin \
    xfce4-terminal xfce4-pulseaudio-plugin \
    pulseaudio pavucontrol sudo dnsutils libssl-dev \
    libffi-dev dbus-x11 rsyslog net-tools libnss3-tools \
    wget ca-certificates bzip2 curl zip xdg-utils xz-utils \
    util-linux git
RUN apt-get -y --no-install-recommends install fonts-ubuntu fonts-dejavu-core breeze-gtk-theme papirus-icon-theme \
    gnome-icon-theme hicolor-icon-theme
# Get latest Spice html5 client
RUN git clone https://gitlab.freedesktop.org/spice/spice-html5 /app/spice-html5
# Additional applications
RUN apt-get -y --no-install-recommends install firefox htop nano gnome-calculator
# Clean-up
RUN apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apk/*

VOLUME /home

COPY ./configs/spiceqxl.xorg.conf /etc/X11/
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
