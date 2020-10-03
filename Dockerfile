FROM ich777/debian-baseimage

LABEL maintainer="admin@minenet.at"

RUN apt-get update && \
	apt-get -y install --no-install-recommends python3 && \
	rm -rf /var/lib/apt/lists/*

ENV DATA_DIR="/sabnzbd"
ENV UMASK=0000
ENV DATA_PERM=770
ENV UID=99
ENV GID=100

RUN mkdir -p $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]