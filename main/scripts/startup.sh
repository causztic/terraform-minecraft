#!/bin/bash

sudo yum -y install wget java-1.8.0-openjdk
sudo mkdir -p /minecraft
sudo chmod 777 /minecraft
sudo mount ${device_name} /minecraft
sudo chown ec2-user /minecraft

if [ ! -f "/minecraft/server.jar" ]; then
  wget -P /minecraft https://launcher.mojang.com/v1/objects/35139deedbd5182953cf1caa23835da59ca3d7cd/server.jar
  # handle eula text
  java -Xms512M -Xmx512M -jar server.jar nogui
  echo eula=true > /minecraft/eula.txt
  # TODO: update server.properties
fi

java -Xms${min} -Xmx${max} -jar server.jar nogui
