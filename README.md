# All-in-One-SmartHome-Docker

## Requirements
On your Docker Host you need to create an Group and User with the PUID and PGID 1000
This is needed that the Containers can write Files from other Containers, like Code Server.

```bash
groupadd -g 1000 [GROUPNAME]
useradd [USERNAME] -u 1000 -g 1000 -m -s /bin/bash
```

With the Command
```bash
id [USERNAME]
```
should be the result like that:
**uid=1000(user) gid=1000(dockerusers) groups=1000(dockerusers)**

After that all you need to change the Owner of you persistant Data folder to the new User and Group.
In my case it looks like that:
```bash
chown -R 1000:1000 /home/docker/*
```
## Which Applications I'm using on my "All-In-One-SmartHome-Docker"

- HomeAssistant
- ESPHome
- Zigbee2MQTT
- mosquitto
- Code Server
- MariaDB
- phpMyAdmin

### Home Assistant

For Home Assistant i'm using the Docker Image from [LinuxServer.io](https://docs.linuxserver.io/images/docker-homeassistant/)

```yaml
---
services:
  homeassistant:
    image: lscr.io/linuxserver/homeassistant:latest
    container_name: homeassistant
    network_mode: bridge
    environment:
      - TZ=${TIME_ZONE}
      - PUID=1000
      - PGID=1000
    volumes:
      - /home/docker/smarthome/homeassistant/config:/config
    ports:
      - '8123:8123'
    #devices:
    #  - /path/to/device:/path/to/device #optional
    restart: unless-stopped
```
