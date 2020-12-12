FROM openjdk:8-jre-slim
WORKDIR /usr/local/bin

EXPOSE 25565
EXPOSE 25575

ARG RCONPASSWORD

# mcrcon
ADD https://github.com/Tiiffi/mcrcon/releases/download/v0.7.1/mcrcon-0.7.1-linux-x86-64.tar.gz .
RUN tar -xvzf mcrcon-0.7.1-linux-x86-64.tar.gz

# minecraft (1.16.4)
WORKDIR /usr/src/app
ADD https://launcher.mojang.com/v1/objects/35139deedbd5182953cf1caa23835da59ca3d7cd/server.jar .

# First time setup
RUN java -Xmx1024M -Xms1024M -jar server.jar nogui
RUN echo "eula=true" > eula.txt
COPY server.properties .
RUN echo "rcon.password=${RCONPASSWORD}" >> server.properties


ENTRYPOINT ["java"]
CMD ["-Xms512M", "-Xmx960M", "-jar" "server.jar", "nogui"]