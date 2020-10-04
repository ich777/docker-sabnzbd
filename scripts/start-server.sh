#!/bin/bash
if [ "$SABNZBD_REL" == "latest" ]; then
    LAT_V="$(wget -qO- https://github.com/ich777/versions/raw/master/SABnzbd | grep LATEST | cut -d '=' -f2)"
elif [ "$SABNZBD_REL" == "prerelease" ]; then
    LAT_V="$(wget -qO- https://github.com/ich777/versions/raw/master/SABnzbd | grep PRERELEASE | cut -d '=' -f2)"
else
    echo "---Version manually set to: v$SABNZBD_REL---"
    LAT_V="$SABNZBD_REL"
fi

if [ ! -f ${DATA_DIR}/SABnzbd/SABnzbd.py ]; then
    CUR_V=""
else
    cd ${DATA_DIR}
    CUR_V="$(/usr/bin/python3 ${DATA_DIR}/SABnzbd/SABnzbd.py --version | grep SABnzbd.py- | cut -d '-' -f2-)"
fi

if [ -z $LAT_V ]; then
    if [ -z $CUR_V ]; then
        echo "---Can't get latest version of SABnzbd, putting container into sleep mode!---"
        sleep infinity
    else
        echo "---Can't get latest version of SABnzbd, falling back to v$CUR_V---"
    fi
fi

echo "---Version Check---"
if [ -z "$CUR_V" ]; then
    echo "---SABnzbd not found, downloading and installing v$LAT_V...---"
    cd ${DATA_DIR}
    if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/SABnzbd-v$LAT_V.tar.gz "https://github.com/sabnzbd/sabnzbd/releases/download/$LAT_V/SABnzbd-${LAT_V}-src.tar.gz" ; then
        echo "---Successfully downloaded SABnzbd v$LAT_V---"
    else
        echo "---Something went wrong, can't download SABnzbd v$LAT_V, putting container into sleep mode!---"
        sleep infinity
    fi
    mkdir ${DATA_DIR}/SABnzbd
    tar -C ${DATA_DIR}/SABnzbd --strip-components=1 -xf ${DATA_DIR}/SABnzbd-v$LAT_V.tar.gz
    rm ${DATA_DIR}/SABnzbd-v$LAT_V.tar.gz
elif [ "$CUR_V" != "$LAT_V" ]; then
    echo "---Version missmatch, installed v$CUR_V, downloading and installing latest v$LAT_V...---"
    cd ${DATA_DIR}
    if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${DATA_DIR}/SABnzbd-v$LAT_V.tar.gz "https://github.com/sabnzbd/sabnzbd/releases/download/$LAT_V/SABnzbd-${LAT_V}-src.tar.gz" ; then
        echo "---Successfully downloaded SABnzbd v$LAT_V---"
    else
        echo "---Something went wrong, can't download SABnzbd v$LAT_V, putting container into sleep mode!---"
        sleep infinity
    fi
    rm -R ${DATA_DIR}/SABnzbd
    mkdir ${DATA_DIR}/SABnzbd
    tar -C ${DATA_DIR}/SABnzbd --strip-components=1 -xf ${DATA_DIR}/SABnzbd-v$LAT_V.tar.gz
    rm ${DATA_DIR}/SABnzbd-v$LAT_V.tar.gz
elif [ "$CUR_V" == "$LAT_V" ]; then
    echo "---SABnzbd v$CUR_V up-to-date---"
fi

echo "---Preparing Server---"
if [ ! -f ${DATA_DIR}/sabnzbd.ini ]; then
    echo '[misc]
download_dir = /mnt/incomplete
complete_dir = /mnt/downloads
host = 0.0.0.0
url_base = ""
auto_browser = 0' > ${DATA_DIR}/sabnzbd.ini
fi
chmod -R ${DATA_PERM} ${DATA_DIR}

echo "---Starting SABnzbd---"
cd ${DATA_DIR}
/usr/bin/python3 -OO ${DATA_DIR}/SABnzbd/SABnzbd.py -f ${DATA_DIR}/sabnzbd.ini ${START_PARAMS}