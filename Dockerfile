FROM ich777/debian-baseimage

LABEL org.opencontainers.image.authors="admin@minenet.at"
LABEL org.opencontainers.image.source="https://github.com/ich777/docker-sabnzbd"

RUN apt-get update && \
	apt-get -y install --no-install-recommends python3 python3-pip python3-setuptools python3-wheel p7zip-full unzip libtbb-dev rustc cargo python3-dev libssl-dev libffi-dev libxml2-dev libxslt1-dev zlib1g-dev netcat-traditional xz-utils

RUN	LAT_SAB_V="$(wget -qO- https://api.github.com/repos/sabnzbd/sabnzbd/releases/latest | grep tag_name | cut -d '"' -f4)" && \
	cd /tmp && mkdir -p /tmp/sabnzbd && \
	wget -O sabnzbd.tar.gz "https://github.com/sabnzbd/sabnzbd/releases/download/$LAT_SAB_V/SABnzbd-$LAT_SAB_V-src.tar.gz" && \
	tar -C /tmp/sabnzbd --strip-components=1 -xvf /tmp/sabnzbd.tar.gz && \
	pip3 install --break-system-packages -r /tmp/sabnzbd/requirements.txt && \
	rm -rf /tmp/sabnzbd.tar.gz /tmp/sabnzbd

RUN	apt-get -y remove python3-pip python3-wheel rustc cargo python3-dev libssl-dev libffi-dev libxml2-dev libxslt1-dev zlib1g-dev && \
	apt-get -y autoremove && \
	rm -rf /var/lib/apt/lists/*

#Patch Python3.9 to be compatible with SABnzbd
#RUN sed -i 's/base64.decodestring/base64.decodebytes/g' /usr/local/lib/python3.9/dist-packages/feedparser.py

RUN LAT_V_UNRAR="$(wget -qO- https://api.github.com/repos/ich777/unrar/releases/latest | grep tag_name | cut -d '"' -f4)" && \
	cd /tmp && \
	wget -O unrar.tar.gz "https://github.com/ich777/unrar/releases/download/$LAT_V_UNRAR/rar-v$LAT_V_UNRAR.tar.gz" && \
	tar -C /usr/bin -xvf /tmp/unrar.tar.gz && \
	rm /tmp/unrar.tar.gz

RUN LAT_V_PAR2TURBO="$(wget -qO- https://api.github.com/repos/animetosho/par2cmdline-turbo/releases/latest | grep tag_name | cut -d '"' -f4)" && \
	cd /tmp && \
	wget -O par2turbo.xz "https://github.com/animetosho/par2cmdline-turbo/releases/download/${LAT_V_PAR2TURBO}/par2cmdline-turbo-${LAT_V_PAR2TURBO#v}-linux-amd64.xz" && \
	xz --decompress par2turbo.xz  && \
	chmod +x /tmp/par2turbo && \
	mv /tmp/par2turbo /usr/bin/par2turbo && \
	ln -s /usr/bin/par2turbo /usr/bin/par2

ENV DATA_DIR="/sabnzbd"
ENV SABNZBD_REL="latest"
ENV START_PARAMS=""
ENV CONNECTED_CONTAINERS=""
ENV CONNECTED_CONTAINERS_TIMEOUT=60
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