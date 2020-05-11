# Xubuntu-Desktop in Spice Docker
FROM ubuntu:14.04
MAINTAINER Melroy van den Berg
RUN apt-get update && apt-get -y install software-properties-common 
RUN add-apt-repository ppa:serge-hallyn/virt && apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install xserver-xspice x11-xserver-utils
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get -y --no-install-recommends install xfce4
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get -y --no-install-recommends install tango-icon-theme xfce4-notifyd xfce4-terminal xfce4-artwork xubuntu-icon-theme
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get -y --no-install-recommends install firefox
COPY spiceqxl.xorg.conf /etc/X11/	   
COPY resolution.desktop /etc/xdg/autostart/
COPY keyboard.desktop /etc/xdg/autostart/
COPY run.sh	/root/
VOLUME ["/home"]
EXPOSE 5900
CMD /root/run.sh
