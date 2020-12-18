#!/bin/bash

yum -y install wget java-1.8.0-openjdk
mkdir -p /minecraft
mount ${device_name} /minecraft
chown /minecraft
chmod -R 700 /minecraft

if [ ! -f "/minecraft/server.jar" ]; then
  wget -P /minecraft https://launcher.mojang.com/v1/objects/35139deedbd5182953cf1caa23835da59ca3d7cd/server.jar
  # handle eula text
  java -Xms512M -Xmx512M -jar /minecraft/server.jar nogui
  echo eula=true > /minecraft/eula.txt
fi

# server-properties
cat <<EOT > /minecraft/server.properties
enable-jmx-monitoring=false
rcon.port=25575
level-seed=
gamemode=survival
enable-command-block=false
enable-query=false
generator-settings=
level-name=world
motd=${motd}
query.port=25565
pvp=true
generate-structures=true
difficulty=normal
network-compression-threshold=256
max-tick-time=60000
max-players=20
use-native-transport=true
online-mode=false
enable-status=true
allow-flight=false
broadcast-rcon-to-ops=true
view-distance=8
max-build-height=256
server-ip=
allow-nether=true
server-port=25565
enable-rcon=true
sync-chunk-writes=true
op-permission-level=4
prevent-proxy-connections=false
resource-pack=
entity-broadcast-range-percentage=100
rcon.password=${rcon_password}
player-idle-timeout=0
force-gamemode=false
rate-limit=0
hardcore=false
white-list=false
broadcast-console-to-ops=true
spawn-npcs=true
spawn-animals=true
snooper-enabled=false
function-permission-level=2
level-type=default
spawn-monsters=true
enforce-whitelist=false
resource-pack-sha1=
spawn-protection=16
max-world-size=29999984
EOT

cd /minecraft && setsid nohup java -Xms${min} -Xmx${max} -jar server.jar nogui &
