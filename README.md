# Obsolete

I no longer use the SPICE protocol anymore. Instead use the X2Go protocol image, see: https://github.com/danger89/xfcevdi

# Ubuntu XFCE VDI (SPICE protocol)

This repository contains Ubuntu 20 (Focal Fossa) Desktop with XFCE4 for Docker. By using the open-source [Spice protocol](https://en.wikipedia.org/wiki/Simple_Protocol_for_Independent_Computing_Environments).

## Base Docker Image

* [ubuntu:focal](https://registry.hub.docker.com/_/ubuntu/)

## Installation

1. Install [Docker](https://www.docker.com/).
2. Pull the images from [Docker Hub](https://hub.docker.com/r/danger89/xfcevdi) directly: `docker pull danger89/xfcevdi`
3. *Alternatively:* you could instead build the image locally, via: `docker build --tag danger89/xfcevdi:latest .`
    
    Or when you have [apt-cacher](http://manpages.ubuntu.com/manpages/focal/man8/apt-cacher.8.html) proxy installed, use `APT_PROXY` parameter to set the proxy URL: `docker build --build-arg APT_PROXY=http://melroy-pc:3142 --tag danger89/xfcevdi:latest .`

## Usage

Run VDI with Spice port (port 5900), HTTP server (8080) with websockify (5959) in background (daemon):

```sh
docker run -d --shm-size 2g -p 5900:5900 -p 8080:8080 -p 5959:5959 danger89/xfcevdi:latest
```

*Note:* If you won't use the Spice HTML5 client, port `5900` would be sufficient enough.

Or run with terminal access open (in foreground):

```sh
docker run --shm-size 2g -it -p 5900:5900 -p 8080:8080 -p 5959:5959 danger89/xfcevdi:latest
```

Or run as daemon, map your /home/myusername, set your username (`john`) with UID `1000`, change password, change resolution and enable audio:

```sh
docker run -d --shm-size 2g -p 5900:5900 -p 8080:8080 -p 5959:5959 -v /home/john:/home/john -e SPICE_USER=john -e SPICE_UID=1000 -e SPICE_RES="1366x768" -e SPICE_PASSWD="azerty" -e SPICE_SOUND="true" danger89/xfcevdi:1.0
```

*Note:* `--shm-size 2g` option is to prevent Firefox from crashing (due to high memory usage). Alternatively, you can try to mount it on your host: `-v /dev/shm:/dev/shm`.

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
