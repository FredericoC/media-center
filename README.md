# Intro
Quick setup for Emby, Radarr, Sonarr, Jackett and Transmission (ProtonVPN) using Docker

*Emby*
A personal media server application like Plex. Has an app to stream your movie/tv show/etc library.

*Radarr*
Automatically download, manage, and organise movies (only). Depends on Jackett for Torrent site search and Transmission for torrent download

*Sonarr*
Same as Radarr but for TV shows.

*Jackett*
Jackett acts as a bridge between Radarr, Sonarr and torrent or Usenet indexers.

*Transmission* 
Bittorrent client. We're using a docker image that enforces OpenVPN when downloading Transmission.

## Requirements:

* Docker: https://docs.docker.com/engine/install/
* Docker compose: https://docs.docker.com/compose/install/linux/#install-using-the-repository

## Get started

```
git clone git@github.com:FredericoC/media-center.git
cd media-center
```

**OpenVPN setup**

You can run the following script to set the structure as per docker-compose.yml;
```
sudo bash setup_structure.sh
```

In the `docker-compose.yml` you must setup the `OPENVPN_` variables under the `environment:` key.
See here for more information: https://haugene.github.io/docker-transmission-openvpn/config-options/

In this case we're using ProtonVPN as a custom OpenVPN provider. Exact steps how to configure below;
https://haugene.github.io/docker-transmission-openvpn/provider-specific/#protonvpn

Notes about configuring ProtonVPN;
- The `update-port.sh` needs to be executable and owned by 1000:1000 (or whatever ids specified in docker-compose.yml)
  - ```sudo chown -R 1000:1000 ./protonvpn && chmod +x ./protonvpn/update-port.sh```
- Credentials are under `openvpn_creds` file, which sits in the same folder as the docker-compose.yml file. See this repo for a sample. 
- Attach `+pmp` to the username to setup port forwarding, which accelerates torrent downloading.

**Directories / Volumes setup**

Both Radarr and Sonarr copy completed downloads from Transmission's "downloads" folder into their configured "root folders".
The "root folder" is configured on web interface for Radarr & Sonarr via the "Settings > Media Management" page and it should be `/movies` for Radarr and  `/tv` for Sonarr.
Do not include the `/data` folder as a root folder. 

Folder structure is
```
docker-compose.yml
openvpn_creds # proton openvpn specific credentials
protonvpn # custom openvpn setup for transmission
└───*.protonvpn.udp.ovpn 
└───update-port.sh
apps # configuration folders
└───emby
└───jackett
└───radarr
└───sonarr
└───transmission
data
└───media
│   └───movies
│   └───tv
└───downloads # managed by transmission
│   └───completed
│   └───incomplete
```

- Download `*.protonvpn.udp.ovpn` from https://account.protonvpn.com/downloads
- Download `update-port.sh` from https://github.com/haugene/vpn-configs-contrib/blob/main/openvpn/protonvpn/update-port.sh

**Finally run**
(`--detach` is for starting in the background)
```
docker compose up --detach
```

The services are available on the localhost addresses:

* Emby: http://127.0.0.1:8096/
* Radarr: http://127.0.0.1:7878/
* Sonarr: http://127.0.0.1:8989/
* Jackett: http://127.0.0.1:9117/
* Transmission: http://127.0.0.1:9091/
 
When you are accessing the server from outside the server (over SSH for example) replace 127.0.0.1 with the IP of your server.

**Service configuration from scratch**
- Configure "Emby" first by adding a library for "movies" and one for "tv" (choose the relevant folders)
- Configure "Jackett" by adding an indexer (usually TL) 
- Configure "Radarr" / "Sonarr" by 
  - Add an indexer following the instructions in the "Jackett" web interface. They have the URL and API key
  - Add Transmission as the torrent downloader
  - Configure the "Profiles" so it downloads the correct releases
- Transmission is usually automatically configured. 
 
**Samba**
The SMB share is available on the same ip address without credentials. When credentials are needed look at these options:
https://github.com/dperson/samba#configuration

## Some useful links and tips:

* Check the running containers with `docker compose ps`
* Check logs of the containers with `docker compose logs <container name>` container name is visible in the docker ps output.
  For example: `docker compose logs radarr`
* Container can connect between eachother on their name in the compose file, for example `http://jackett:9117` as Jackett Server and `http://radarr:7878` as Radarr server.
* Update the containers to their latest version with `docker compose pull` and `docker compose up -d`
