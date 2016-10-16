#!/bin/bash
if [[ $UID -ne 0 ]]; then
	echo "Must be run as root"
	exit 1;
fi

#### Create user and group "plex". If already created, set the uid and gid to 1010(used by docker-compose)

if [[ ! $(grep "plex" /etc/passwd) ]]; then
	if [[ ! $(grep "plex" /etc/group) ]]; then
		groupadd -g 1010 plex
		useradd -g 1010 -u 1010 -m plex
	else
		groupmod -g 1010 plex
		useradd -g 1010 -u 1010 -m plex
	fi
else
	if [[ ! $(grep "plex" /etc/group) ]]; then
		groupadd -g 1010 plex
		usermod -g 1010 -u 1010 plex
	else
		groupmod -g 1010 plex
		usermod -g 1010 -u 1010 plex
	fi
fi

## Add fstab entries to bind mount our media and app config directories
echo "/home/plex/media /media none defaults,bind 0 0" >> /etc/fstab
echo "/home/plex/apps /apps none defaults,bind 0 0" >> /etc/fstab

## Create the /apps and /media directories
if [[ ! -d "/apps" ]]; then
	mkdir /apps
fi

if [[ ! -d "/media" ]]; then
	mkdir /media
fi

## bind mount the /apps and /media directories
mount /apps
mount /media

## Create subdirectories and change ownershihp to plex
mkdir -p /apps/configs/{plex,plexrequests,nzbget,sonarr,couchpotato,deluge}
mkdir -p /media/{movies,tv,downloads}
chown -R plex:plex /media /apps

## Create home for the the docker-compose.yml and copy it there
mkdir -p /usr/local/share/docker/docker-mediaserver/
cp ./docker-compose.yml /usr/local/share/docker/docker-mediaserver/

has_systemd=$(which systemctl);
if [[ ! -z $has_systemd ]]; then
	docker_path=$(which docker-compose)  
	cp ./systemd/compose-mediaserver.service /etc/systemd/system/
	if [[ ${docker_path} != "/usr/bin/docker-compose" ]]; then
		echo "Please edit /etc/systemd/system/compose-mediaserver.service to use the correct path to docker-compose"
	fi
	echo "Run systemctl enable compose-mediaserver.service to enable"
	echo "Run systemctl start compose-mediaserver.service to start"
fi



