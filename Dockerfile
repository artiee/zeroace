# this creates a base system for custom made IDE
FROM ubuntu:latest
MAINTAINER tuomas.palenius@gmail.com

RUN apt-get update && apt-get install -y git nodejs npm ssh sudo nano

# process manager:
RUN npm install -g pm2

# use node instead of nodejs to run node apps (nodejs installed from apt-get, conflicts with node package)
RUN ln -s /usr/bin/nodejs /usr/bin/node

# install ide
RUN cd /opt && git clone https://github.com/artiee/zeroace.git && cd zeroace && npm install

# install wetty
RUN cd /opt/zeroace && git clone https://github.com/krishnasrinivas/wetty && cd wetty && npm install

RUN cd /opt/zeroace && mv lib wetty/public && mv index.html wetty/public

# create the start script:
RUN echo "service ssh start && pm2 start /opt/zeroace/wetty/app.js -- -p 8087 --sshuser ide
 --sshhost localhost --sshport 3022 && pm2 start /opt/zeroace/file-browser/index.js" > /opt/start.sh

# create user ide with home dir and bash shell
RUN useradd -d /home/ide -m -s /bin/bash ide

# set password for ide (password: ide)
RUN echo 'ide:ide' | chpasswd

# give access to root
RUN adduser ide sudo

# grant ssh privilege
RUN echo "AllowUsers ide" > /etc/ssh/sshd_config
RUN echo "Port 3022" >> /etc/ssh/sshd_config

# set environment variable
ENV TERM=xterm

# expose ports for wetty, file-browser, ssh (you still need to map them when starting container)
EXPOSE 8087 8088 3022

# start services and leave process running (so container will keep running)
CMD sh /opt/start.sh && tail -F /var/log/faillog

