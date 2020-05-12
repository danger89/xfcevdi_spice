# Xubuntu Desktop with SPICE
FROM ubuntu:focal

LABEL maintainer="melroy@melroy.org"

ARG DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1.0

RUN apt-get update && apt-get -y install software-properties-common
RUN apt-get upgrade -y
RUN apt-get -y install xserver-xspice x11-xserver-utils locales apt-utils at-spi2-core dialog spice-html5
RUN apt-get update && apt-get -y --no-install-recommends install xfce4
RUN add-apt-repository ppa:papirus/papirus
RUN apt-get update && apt-get -y --no-install-recommends install xfce4-notifyd xfce4-statusnotifier-plugin \
    xfce4-terminal xfce4-goodies xfce4-pulseaudio-plugin \
    pulseaudio pavucontrol sudo dnsutils libssl-dev \
    libffi-dev net-tools libnss3-tools curl wget dbus-x11 ca-certificates bzip2
RUN apt-get -y --no-install-recommends install fonts-ubuntu breeze-gtk-theme papirus-icon-theme \
    gnome-icon-theme hicolor-icon-theme
# Additional applications
RUN apt-get -y --no-install-recommends install firefox htop nano
RUN apt-get clean -y

VOLUME /home

COPY ./configs/spiceqxl.xorg.conf /etc/X11/
COPY ./configs/resolution.desktop /etc/xdg/autostart/
COPY ./configs/keyboard.desktop /etc/xdg/autostart/
COPY ./configs/terminalrc /root/
COPY ./configs/xsettings.xml /root/
COPY run.sh	/root/

EXPOSE 5900
CMD /root/run.sh
