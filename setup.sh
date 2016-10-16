#!/bin/bash
if [[ $UID -ne 0 ]]; then
    echo "Must be run as root"
    exit 1;
fi

docker_path=$(type -p docker)
docker_compose_path=$(type -p docker-compose)
systemctl_path=$(type -p systemctl)

script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
yml_path="${script_dir}/docker-compose.yml"
unit_file_path="${script_dir}/compose-mediaserver.service"
docker_mediaserver_dir="/usr/local/share/docker/docker-mediaserver"

## Tests
function tests() {
	
	tests=(${1} ${2})

	[[ ! -f ${docker_mediaserver_dir}/.setup_run ]] && setup_run=0 || setup_run=1

	if [[ ${setup_run} -eq 0 ]]; then
		len=${#tests[@]}
		i=0
		while [ $i -lt ${len} ]; do
        	if [[ -z ${tests[${i}]} ]]; then
				echo "${tests[${i}]} was not found, please install before running setup";
				exit 1;
			else
				echo "${tests[${i}]} found";
				i=$(( $i + 1 ))
			fi
		done
		
		if [[ ! -z ${3} ]]; then
			has_systemd=1
			echo "OS using Systemd"
		else
			has_systemd=0
		fi

	else
        echo "Setup Already ran"
        echo "To re-run, delete ${docker_mediaserver_dir}/.setup_run"
        exit 0;
    fi
}

function setup(){

	#### Create user and group "plex". If already created, set the uid and gid to 1010(used by docker-compose)
	plex_user=$(grep plex /etc/passwd)
	
	if [[ -z ${plex_user} ]]; then
		echo "Creating user plex"
		useradd -u 1010 -U -m plex
		plex_uid=$(id -u plex)
		plex_gid=$(id -g plex)
	else
		plex_uid=$(id -u plex)
		plex_gid=$(id -g plex)
	fi

	/usr/bin/perl -p -i.template -e "s/PUID=/PUID=${plex_uid}/g" ${yml_path}
	/usr/bin/perl -p -i.template -e "s/PGID=/PGID=${plex_gid}/g" ${yml_path}
    ## Add fstab entries to bind mount our media and app config directories
    fstab_media=$(grep "/home/plex/media /media" /etc/fstab)
    fstab_apps=$(grep "/home/plex/apps /apps" /etc/fstab)

    if [[ ! ${fstab_media} ]]; then
		echo "Adding /media bind mount to /etc/fstab"
		cat <<- 'EOF' >> /etc/fstab	
/home/plex/media /media none defaults,bind 0 0
EOF
	fi
	
	if [[ ! ${fstab_apps} ]]; then
		echo "Adding /apps bind mount to /etc/fstab"
		cat <<- 'EOF' >> /etc/fstab	
/home/plex/apps /apps none defaults,bind 0 0
EOF
	fi

    ## Create the /apps and /media directories
	if [[ ! -d "/apps" ]]; then
		echo "Creating /apps"
		mkdir /apps
	fi

	if [[ ! -d "/media" ]]; then
		echo "Creating /media"
		mkdir /media
    fi

	if [[ ! -d "/home/plex/media" ]] && [[ ! -d "/home/plex/media" ]]; then
		echo "Creating /home/plex/media and /home/plex/apps"
		mkdir -p /home/plex/{apps,media}
		chown plex:plex /home/plex/{apps,media}
	fi
	
    ## bind mount the /apps and /media directories
	apps_mount=$(mount | grep "/home/plex/apps")
	media_mount=$(mount | grep "/home/plex/media")
	if [[ ! ${apps_mount} ]]; then
		echo "Mounting /apps"
		mount /apps
	fi
	
	if [[ ! ${media_mount} ]]; then
		echo "Mounting /Media"
		mount /media
	fi

    ## Create subdirectories and change ownershihp to plex
	echo "Creating Config Directories"
	mkdir -p /apps/configs/{plex,plexrequests,nzbget,sonarr,couchpotato,deluge}
	echo "Creating Media Directories"
	mkdir -p /media/{movies,tv,downloads}
	echo "Changing Directory Ownership"
	chown -R plex:plex /media /apps

    ## Create home for the the docker-compose.yml and copy it there
	
	if [[ ${has_systemd} -eq 1 ]]; then
		echo "Creating application directory at ${docker_mediaserver_dir}"
		mkdir -p ${docker_mediaserver_dir}/
		echo "Moving docker compose to application directory"
		cp ${yml_path} ${docker_mediaserver_dir}/
		generate_unit_file
		mv ${unit_file_path} /etc/systemd/system/
		${systemctl_path} daemon-reload
		echo "Enabling compose-mediaserver.service"
		${systemctl_path} enable compose-mediaserver.service 
		echo "Run systemctl start compose-mediaserver.service to start"
    		touch "${docker_mediaserver_dir}/.setup_run"
	else
		touch "${script_dir}/.setup_run"
		echo "Run docker-compose up -d from:"
		echo "  ${script_dir}"	
	fi
	
	echo "Setup Complete"
}

## Function used to generate a systemd unit file with the proper configs
function generate_unit_file() {
	cat << EOF > ${unit_file_path}
[Unit]
Requires=docker.service
After=docker.service

[Service]
User=root
Restart=always
ExecStart=${docker_compose_path} -f ${docker_mediaserver_dir}/docker-compose.yml up
ExecStop=${docker_compose_path} -f ${docker_mediaserver_dir}/docker-compose.yml down

[Install]
WantedBy=default.target
EOF

}

tests ${docker_path} ${docker_compose_path} ${systemctl_path}
setup 
