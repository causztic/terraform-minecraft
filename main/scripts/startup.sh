#!/bin/bash

if sudo file -s ${device_name} | grep -q 'data$'; then
  echo 'filesystem not formatted - formatting now'
  sudo yum install xfsprogs
  sudo mkfs -t xfs ${device_name}
fi

sudo mkdir -p /minecraft
sudo chmod 666 /minecraft
sudo mount ${device_name} /minecraft

if [ ! -f "/minecraft/server.jar" ]; then
  wget https://github.com/Tiiffi/mcrcon/releases/download/v0.7.1/mcrcon-0.7.1-linux-x86-64.tar.gz
  tar -xvzf mcrcon-0.7.1-linux-x86-64.tar.gz
  rm mcrcon-0.7.1-linux-x86-64.tar.gz
  sudo mv mcrcon /usr/local/bin
  wget -P /minecraft https://launcher.mojang.com/v1/objects/35139deedbd5182953cf1caa23835da59ca3d7cd/server.jar
fi
