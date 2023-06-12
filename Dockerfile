FROM ich777/debian-baseimage

LABEL org.opencontainers.image.authors="admin@minenet.at"
LABEL org.opencontainers.image.source="https://github.com/ich777/docker-sabnzbd"

RUN apt-get update && \
	apt-get -y install --no-install-recommends python3 python3-pip python3-setuptools python3-wheel p7zip-full unzip libtbb-dev rustc cargo python3-dev libssl-dev libffi-dev libxml2-dev libxslt1-dev zlib1g-dev par2 && \
	pip3 install sabctools cheetah3 cryptography feedparser configobj cherrypy portend chardet notify2 puremagic guessit PySocks --break-system-packages && \
	apt-get -y remove python3-pip python3-wheel rustc cargo python3-dev libssl-dev libffi-dev libxml2-dev libxslt1-dev zlib1g-dev && \
	apt-get -y autoremove && \
	rm -rf /var/lib/apt/lists/*

#Patch Python3.9 to be compatible with SABnzbd
#RUN sed -i 's/base64.decodestring/base64.decodebytes/g' /usr/local/lib/python3.9/dist-packages/feedparser.py

RUN LAT_V_UNRAR="$(wget -qO- https://api.github.com/repos/ich777/unrar/releases/latest | grep tag_name | cut -d '"' -f4)" && \
	cd /tmp && \
	wget -O unrar.tar.gz "https://github.com/ich777/unrar/releases/download/$LAT_V_UNRAR/rar-v$LAT_V_UNRAR.tar.gz" && \
	tar -C /usr/bin -xvf /tmp/unrar.tar.gz && \
	rm /tmp/unrar.tar.gz

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