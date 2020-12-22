#!/bin/bash

yum -y install wget java-1.8.0-openjdk git
mkdir -p /minecraft
mount ${device_name} /minecraft
chmod -R 700 /minecraft

if [ ! -f "/minecraft/BuildTools.jar" ]; then
  wget -P /minecraft https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
  java -jar -Xms512M /minecraft/BuildTools.jar --rev ${mc_version} # re-run this when you need to update to save bootup time
  echo "eula=true" > /minecraft/eula.txt
fi

mv /tmp/server.properties /minecraft
# wget -P /minecraft/plugins http://dynmap.us/releases/Dynmap-3.1-beta5-spigot.jar

cd /minecraft && setsid nohup java -Xms${min} -Xmx${max} -jar spigot-${mc_version}.jar nogui &

curl -v \
-H "Authorization: Bot ${discord_bot_token}" \
-H "Content-Type: application/json" \
-X POST \
-d '{"content":"hic - server up!"}' \
https://discordapp.com/api/channels/${discord_channel_id}/messages