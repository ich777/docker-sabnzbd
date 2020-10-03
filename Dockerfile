FROM ich777/debian-baseimage:arm64

LABEL maintainer="admin@minenet.at"

RUN sed -i "/deb http:\/\/deb.debian.org\/debian buster main/c\deb http:\/\/deb.debian.org\/debian buster main non-free" /etc/apt/sources.list && \
	apt-get update && \
	apt-get -y install --no-install-recommends python3 python3-pip python3-setuptools python3-wheel p7zip-full unzip unrar par2 libssl-dev zlib1g-dev gcc g++ make python3-dev libffi-dev && \
	pip3 install sabyenc3 cheetah3 cryptography feedparser==5.2.1 configobj cherrypy portend chardet notify2 && \
	apt-get -y remove python3-pip python3-setuptools python3-wheel libssl-dev zlib1g-dev gcc g++ make python3-dev libffi-dev && \
	apt-get -y autoremove && \
	rm -rf /var/lib/apt/lists/*

ENV DATA_DIR="/sabnzbd"
ENV SABNZBD_REL="latest"
ENV START_PARAMS=""
ENV UMASK=0000
ENV DATA_PERM=770
ENV UID=99
ENV GID=100
ENV USER="sabnzbd"

RUN mkdir $DATA_DIR && \
	mkdir /mnt/downloads && \
	mkdir /mnt/incomplete && \
	useradd -d $DATA_DIR -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/ && \
	chmod -R 770 /mnt && \
	chown -R $UID:$GID /mnt

EXPOSE 8080 9090

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]