#!/bin/bash

yum -y install wget java-1.8.0-openjdk
mkdir -p /minecraft
mount ${device_name} /minecraft
chown /minecraft
chmod -R 700 /minecraft

if [ ! -f "/minecraft/BuildTools.jar" ]; then
  wget -P /minecraft https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
fi

java -jar BuildTools.jar

if [ ! -f "/minecraft/server.jar" ]; then
  wget -P /minecraft https://launcher.mojang.com/v1/objects/35139deedbd5182953cf1caa23835da59ca3d7cd/server.jar
  # handle eula text
  java -Xms512M -Xmx512M -jar /minecraft/server.jar nogui
  echo eula=true > /minecraft/eula.txt
fi

mv /tmp/server.properties /minecraft

# wget https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
# cd /minecraft && setsid nohup java -Xms${min} -Xmx${max} -jar server.jar nogui &
# curl -v \
# -H "Authorization: Bot ${discord_bot_token}" \
# -H "Content-Type: application/json" \
# -X POST \
# -d '{"content":"hic - server up!"}' \
# https://discordapp.com/api/channels/${discord_channel_id}/messages