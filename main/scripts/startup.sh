#!/bin/bash

yum -y install wget java-1.8.0-openjdk
mkdir -p /minecraft
mount ${device_name} /minecraft
chown /minecraft
chmod -R 700 /minecraft

source /minecraft

if [ ! -f "server.jar" ]; then
  wget https://launcher.mojang.com/v1/objects/35139deedbd5182953cf1caa23835da59ca3d7cd/server.jar
  # handle eula text
  java -Xms512M -Xmx512M -jar server.jar nogui
  echo eula=true > eula.txt
  # TODO: update server.properties
fi

setsid nohup java -Xms${min} -Xmx${max} -jar server.jar nogui &
