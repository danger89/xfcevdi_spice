# Xubuntu-Desktop in Spice Docker
FROM ubuntu:focal

LABEL maintainer="melroy@melroy.org"

ARG DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1.0

# TODO: Add to install: spice-html5
RUN apt-get update && apt-get -y install software-properties-common
RUN apt-get upgrade -y
RUN apt-get -y install xserver-xspice x11-xserver-utils dbus-x11 locales apt-utils at-spi2-core sudo
RUN apt-get update && apt-get -y --no-install-recommends install xfce4
RUN apt-get update && apt-get -y --no-install-recommends install xfce4-notifyd xfce4-statusnotifier-plugin xfce4-terminal xfce4-goodies gnome-icon-theme hicolor-icon-theme pulseaudio xfce4-pulseaudio-plugin pavucontrol
# sudo add-apt-repository ppa:papirus/papirus
# sudo apt-get update
# sudo apt-get install papirus-icon-theme
RUN apt-get update && apt-get -y --no-install-recommends install firefox htop nano
RUN apt-get clean -y

VOLUME /home

COPY spiceqxl.xorg.conf /etc/X11/	   
COPY resolution.desktop /etc/xdg/autostart/
COPY keyboard.desktop /etc/xdg/autostart/
COPY run.sh	/root/

EXPOSE 5900
CMD /root/run.sh
