# Ubuntu XFCE VDI (SPICE protocol)

This repository contains Ubuntu 20 Desktop with XFCE4 for Docker. By using the open-source [Spice protocol](https://en.wikipedia.org/wiki/Simple_Protocol_for_Independent_Computing_Environments).

## Base Docker Image

* [ubuntu:focal](https://registry.hub.docker.com/_/ubuntu/)

## Installation

1. Install [Docker](https://www.docker.com/).
2. Pull the images from Dockerhub directly: `docker pull danger89/xfcevdi`

   (alternatively, you could build the image locally via: `docker build --tag danger89/xfcevdi:1.0 .`)

## Usage

`docker run -p 5900:5900 danger89/xfcevdi:1.0`

Or run with terminal access open:

`docker run -itp 5900:5900 danger89/xfcevdi:1.0`

If you username locally is `myusername` with UID `1000` and you want to map your /home/myusername in Docker, try:

`docker run -p 5900:5900 -e SPICE_USER=myusername -e SPICE_UID=1000 -v /home/myusername:/home/myusername -e SPICE_PASSWD="azerty" -e SPICE_LOCAL="fr_FR.UTF-8" -e SPICE_RES="1366x768" danger89/xfcevdi:1.0`

### Clients

There are several Spice clients availible.

Either use on the command line: `remote-viewer spice://localhost:5900`

Or you could use an application like: `Remmina`.

**Note:** The default username is `user`, with the password: `password`.

