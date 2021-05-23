FROM ich777/debian-baseimage

LABEL maintainer="admin@minenet.at"

RUN sed -i "/deb http:\/\/deb.debian.org\/debian buster main/c\deb http:\/\/deb.debian.org\/debian buster main non-free" /etc/apt/sources.list && \
	apt-get update && \
	apt-get -y install --no-install-recommends p7zip-full unzip unrar par2 libssl-dev zlib1g-dev libffi-dev && \
	apt-get -y autoremove && \
	rm -rf /var/lib/apt/lists/*

RUN LAT_V_UNRAR="$(wget -qO- https://api.github.com/repos/ich777/unrar/releases/latest | grep tag_name | cut -d '"' -f4)" && \
	LAT_V_PAR2TBB="$(curl -qO- https://api.github.com/repos/ich777/par2tbb/releases/latest | grep tag_name | cut -d '"' -f4)" && \
	cd /tmp && \
	wget -O unrar.tar.gz "https://github.com/ich777/unrar/releases/download/$LAT_V_UNRAR/rar-v$LAT_V_UNRAR-arm64.tar.gz" && \
	wget -O par2tbb.tar.gz "https://github.com/ich777/par2tbb/releases/download/$LAT_V_PAR2TBB/par2-v$LAT_V_PAR2TBB-arm64.tar.gz" && \
	tar -C / -xvf /tmp/unrar.tar.gz && \
	tar -C / -xvf /tmp/par2tbb.tar.gz && \
	rm /tmp/unrar.tar.gz /tmp/par2tbb.tar.gz

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