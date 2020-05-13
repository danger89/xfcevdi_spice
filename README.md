# Ubuntu XFCE VDI (SPICE protocol)

This repository contains Ubuntu 20 Desktop with XFCE4 for Docker. By using the open-source [Spice protocol](https://en.wikipedia.org/wiki/Simple_Protocol_for_Independent_Computing_Environments).

## Base Docker Image

* [ubuntu:focal](https://registry.hub.docker.com/_/ubuntu/)

## Installation

1. Install [Docker](https://www.docker.com/).
2. Pull the images from Dockerhub directly: `docker pull danger89/xfcevdi`
3. *Alternatively:* you could instead build the image locally, via: `docker build --tag danger89/xfcevdi:latest .`

## Usage

Run VDI with Spice port (port 5900), HTTP server (8080) with websockify (5959):

`docker run -p 5900:5900 -p 8080:8080 -p 5959:5959 danger89/xfcevdi:latest`

*Note:* If you won't use the Spice HTML5 client, port `5900` would be sufficient enough.

Or run with terminal access open:

`docker run -it -p 5900:5900 -p 8080:8080 -p 5959:5959 danger89/xfcevdi:latest`

If you username locally is `myusername` with UID `1000` and you want to map your /home/myusername in Docker, try:

`docker run -p 5900:5900 -p 8080:8080 -p 5959:5959 -e SPICE_USER=myusername -e SPICE_UID=1000 -v /home/myusername:/home/myusername -e SPICE_PASSWD="azerty" -e SPICE_LOCAL="fr_FR.UTF-8" -e SPICE_RES="1366x768" danger89/xfcevdi:1.0`

### Clients

There are several Spice clients available under GNU/Linux.

**Note:** The default username is `user`, with the password: `password`.

#### Virt-viewer (Recommended)
Install the client via: `sudo apt install virt-viewer`.
Then use the command-line: `remote-viewer spice://localhost:5900`

You can also create a new file (eg. called `vdi`) with the content:

```
 [virt-viewer]
 type=spice
 host=localhost
 port=5900
 password=password
```

Then use it as follows: `remote-viewer vdi` (assuming the file is called `vdi` and you are within the same directory)

#### Browser Client

You can use the built-in Spice HTML5 client (within this docker image).

Open it in your webbrowser (Firefox, Chrome), go to: `http://localhost:8080`.
Don't forget to enter the password.

### Remmina

Use the another application called: `Remmina`.