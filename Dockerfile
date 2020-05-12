# Xubuntu Desktop with SPICE
FROM ubuntu:focal

LABEL maintainer="melroy@melroy.org"

ARG DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1.0

WORKDIR /app

RUN apt-get update && apt-get -y install software-properties-common
RUN apt-get upgrade -y
RUN apt-get -y install xserver-xspice x11-xserver-utils locales apt-utils at-spi2-core dialog spice-html5 websockify
RUN apt-get update && apt-get -y --no-install-recommends install xfce4
RUN add-apt-repository ppa:papirus/papirus
RUN apt-get update && apt-get -y --no-install-recommends install xfce4-notifyd xfce4-statusnotifier-plugin \
    xfce4-terminal xfce4-goodies xfce4-pulseaudio-plugin \
    pulseaudio pavucontrol sudo dnsutils libssl-dev \
    libffi-dev net-tools libnss3-tools curl wget dbus-x11 ca-certificates bzip2
RUN apt-get -y --no-install-recommends install fonts-ubuntu breeze-gtk-theme papirus-icon-theme \
    gnome-icon-theme hicolor-icon-theme
# Additional applications
RUN apt-get -y --no-install-recommends install firefox htop nano git
RUN apt-get clean -y
RUN git clone https://gitlab.freedesktop.org/spice/spice-html5 /app/spice-html5

VOLUME /home

COPY ./configs/spiceqxl.xorg.conf /etc/X11/
COPY ./configs/resolution.desktop /etc/xdg/autostart/
COPY ./configs/keyboard.desktop /etc/xdg/autostart/
COPY ./configs/xfceboot.desktop /etc/xdg/autostart/
COPY ./xfce_settings.sh /tmp/
COPY ./run.sh ./

EXPOSE 5900 5959 8080
CMD ./run.sh
