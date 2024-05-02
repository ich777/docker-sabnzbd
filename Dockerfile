FROM ich777/debian-baseimage

LABEL org.opencontainers.image.authors="admin@minenet.at"
LABEL org.opencontainers.image.source="https://github.com/ich777/docker-sabnzbd"

RUN apt-get update && \
	apt-get -y install --no-install-recommends python3 python3-pip python3-setuptools python3-wheel p7zip-full unzip libtbb-dev rustc cargo python3-dev libssl-dev libffi-dev libxml2-dev libxslt1-dev zlib1g-dev netcat-traditional xz-utils && \
	pip3 install --break-system-packages apprise==1.7.6 sabctools==8.1.0 CT3==3.3.3.post1 cffi==1.16.0 pycparser==2.22 feedparser==6.0.11 configobj==5.0.8 cheroot==10.0.1 six==1.16.0 cherrypy==18.9.0 jaraco.functools==4.0.1 jaraco.collections==5.0.0 jaraco.text==3.8.1 jaraco.classes==3.4.0 jaraco.context==4.3.0 more-itertools==10.2.0 zc.lockfile==3.0.post1 python-dateutil==2.9.0.post0 tempora==5.5.1 pytz==2024.1 sgmllib3k==1.0.0 portend==3.2.0 chardet==5.2.0 PySocks==1.7.1 puremagic==1.22 guessit==3.8.0 babelfish==0.6.0 rebulk==3.2.0 cryptography==42.0.5 ujson==5.9.0 notify2==0.3.1 requests==2.31.0 requests-oauthlib==2.0.0 PyYAML==6.0.1 markdown==3.6 paho-mqtt==2.0.0 charset_normalizer==3.3.2 idna==3.7 urllib3==2.2.1 certifi==2024.2.2 oauthlib==3.2.2 PyJWT==2.8.0 blinker==1.8.1 && \
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

RUN LAT_V_PAR2TURBO="$(wget -qO- https://api.github.com/repos/animetosho/par2cmdline-turbo/releases/latest | grep tag_name | cut -d '"' -f4)" && \
	cd /tmp && \
	wget -O par2turbo.xz "https://github.com/animetosho/par2cmdline-turbo/releases/download/${LAT_V_PAR2TURBO}/par2cmdline-turbo-${LAT_V_PAR2TURBO}-linux-amd64.xz" && \
	xz --decompress par2turbo.xz  && \
	chmod +x /tmp/par2turbo && \
	mv /tmp/par2turbo /usr/bin/par2turbo && \
	ln -s /usr/bin/par2turbo /usr/bin/par2

ENV DATA_DIR="/sabnzbd"
ENV SABNZBD_REL="latest"
ENV START_PARAMS=""
ENV CONNECTED_CONTAINERS=""
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