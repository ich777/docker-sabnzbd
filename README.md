# SABnzbd in Docker optimized for Unraid
SABnzbd is a program to download binary files from Usenet servers. Many people upload all sorts of interesting material to Usenet and you need a special program to get this material with the least effort.

**Update:** The container will check on every start/restart if there is a newer version available (you can also choose between stabel and prereleases and switch between them - keep in mind sometimes downgrading from a prerelease version could break your configuration).

**Manual Version:** You can also set a version manually by typing in the version number that you want to use for example: '3.0.1' (without quotes) - you can also change it to 'latest' or 'prerelease' like described above.

**ATTENTION:** Don't change the IP adress or the port in the SABnzbd config itself - please also note if you change the WebGUI port from 8080 to anything else that it can happen that you have close and reopen the webpage since SABnzbd want's to redirect you to the wrong port after the initial setup.


## Env params
| Name | Value | Example |
| --- | --- | --- |
| DATA_DIR | Folder for configfiles and the application | /sabnzbd |
| SABNZBD_REL | Select if you want to download a stable or prerelease | latest |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |
| UMASK | Umask value for new created files | 0000 |
| DATA_PERMS | Data permissions for config folder | 770 |

## Run example
```
docker run --name SABnzbd -d \
	-p 8080:8080 \
	--env 'SABNZBD_REL=latest' \
	--env 'UID=99' \
	--env 'GID=100' \
	--env 'UMASK=0000' \
	--env 'DATA_PERMS=770' \
	--volume /mnt/cache/appdata/sabnzbd:/sabnzbd \
	--volume /mnt/user/Downloads:/mnt/downloads \
	--volume /mnt/user/Downloads/incomplete/:/mnt/incomplete \
	ich777/sabnzbd
```

This Docker was mainly edited for better use with Unraid, if you don't use Unraid you should definitely try it!
 
#### Support Thread: https://forums.unraid.net/topic/83786-support-ich777-application-dockers/