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

- Home Assistant
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

### ESPHome

For ESPHome i'm using the Docker Image from [ESPHome](https://esphome.io/guides/getting_started_command_line.html)

```yaml
---
services:
  esphome:
    container_name: esphome
    image: ghcr.io/esphome/esphome
    network_mode: bridge
    volumes:
    - /home/docker/smarthome/esphome/config:/config
    - /etc/localtime:/etc/localtime:ro
    restart: always
    privileged: true
    ports:
    - '8124:6052'
    environment:
    #- USERNAME=test
    #- PASSWORD=ChangeMe
    - PUID=${ID}
    - PGID=${ID}
    - TZ=${TIME_ZONE}
```
### Zigbee2MQTT

For Zigbee2MQTT i'm using the Docker Image from [Zigbee2MQTT](https://www.zigbee2mqtt.io/guide/installation/02_docker.html#rootless-container)

```yaml
---
services:
  zigbee2mqtt:
    container_name: zigbee2mqtt
    image: koenkk/zigbee2mqtt
    restart: unless-stopped
    network_mode: bridge
    volumes:
      - /home/docker/smarthome/zigbe2mqtt/data:/app/data
      - /run/udev:/run/udev:ro
    ports:
      - '8125:8080'
    environment:
      - TZ=${TIME_ZONE}
      - PUID=${ID}
      - PGID=${ID}
    #devices:
      #Make sure this matched your adapter location
      #- /dev/serial/by-id/usb-Texas_Instruments_TI_CC2531_USB_CDC___0X00124B0018ED3DDF-if00:/dev/ttyACM0
```

### mosquitto

For mosquitto i'm using the Docker Image from [Zigbee2MQTT](https://www.zigbee2mqtt.io/guide/installation/02_docker.html#rootless-container)

```yaml
---
services:
  eclipse-mosquitto:
    image: eclipse-mosquitto
    container_name: mosquitto
    volumes:
        - /home/docker/smarthome/mosquitto/log:/mosquitto/log
        - /home/docker/smarthome/mosquitto/data:/mosquitto/data
        - /home/docker/smarthome/mosquitto/config:/mosquitto/config
        #- /home/docker/smarthome/mosquitto/mosquitto.conf:/mosquitto/config/mosquitto.conf
    ports:
      - '1883:1883'
      - '1884:1884'
      - '8883:8883'
      - '8884:8884' 
      - '9001:9001'
    tty: true
    stdin_open: true
    environment:
      - PUID=${ID}
      - PGID=${ID}
```

### code-server

For code-server i'm using the Docker Image from [LinuxServer.io](https://docs.linuxserver.io/images/docker-code-server/)

```yaml
---
services:
  code-server:
    image: lscr.io/linuxserver/code-server:latest
    container_name: code-server
    environment:
      - TZ=${TIME_ZONE}
      #- PASSWORD=password #optional
      #- HASHED_PASSWORD= #optional
      #- SUDO_PASSWORD=password #optional
      #- SUDO_PASSWORD_HASH= #optional
      #- PROXY_DOMAIN=code-server.my.domain #optional
      - DEFAULT_WORKSPACE=/config/workspace #optional
      - PUID=${ID}
      - PGID=${ID}
    volumes:
      - /home/docker/smarthome/code-server/config:/config
      - /home/docker/smarthome/homeassistant/config:/config/workspace/homeassistant
      - /home/docker/smarthome/mosquitto/config:/config/workspace/mosquitto
      - /home/docker/smarthome/zigbe2mqtt/data:/config/workspace/zigbe2mqtt
    ports:
      - 8126:8443
    restart: unless-stopped
```

### MariaDB

For MariaDB i'm using the Docker Image from [LinuxServer.io](https://docs.linuxserver.io/images/docker-mariadb)

```yaml
---
services:
  mariadb:
    image: lscr.io/linuxserver/mariadb:latest
    container_name: mariadb
    environment:
      - PUID=${ID}
      - PGID=${ID}
      - TZ=${TIME_ZONE}
      - MYSQL_ROOT_PASSWORD=${ROOT_ACCESS_PASSWORD}
      - MYSQL_DATABASE=${USER_DB_NAME}
      - MYSQL_USER=${MYSQL_USER}
      - MYSQL_PASSWORD=${DATABASE_PASSWORD} #optional
      #- REMOTE_SQL=http://URL1/your.sql,https://URL2/your.sql #optional
    volumes:
      - /home/docker/smarthome/mariadb/config:/config
    ports:
      - 3306:3306
    restart: unless-stopped
```

### phpMyAdmin

For phpMyAdmin i'm using the Docker Image from [LinuxServer.io](https://docs.linuxserver.io/images/docker-phpmyadmin/)

```yaml
---
services:
  phpmyadmin:
    image: lscr.io/linuxserver/phpmyadmin:latest
    container_name: phpmyadmin
    environment:
      - PUID=${ID}
      - PGID=${ID}
      - TZ=${TIME_ZONE}
      - PMA_HOST=192.168.178.147
      - PMA_PORT=3306
      #- PMA_ARBITRARY=1 #optional
      #- PMA_ABSOLUTE_URI=https://phpmyadmin.example.com #optional
    volumes:
      - /home/docker/smarthome/phpmyadmin/config:/config
    ports:
      - 8127:80
    restart: unless-stopped
```