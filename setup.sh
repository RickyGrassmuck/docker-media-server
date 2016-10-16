################################################################################################################
#### The script needs to perform the actions listed out below. They pretty much need to happen in the order
#### that they are listed. 
####
#### ** Bonus points for using tests to make sure things don't already exist as well as that they were created
####    properly afterwards.
################################################################################################################

#### User and Group that needs to be created

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

echo "/home/plex/media /media none defaults,bind 0 0" >> /etc/fstab
echo "/home/plex/apps /apps none defaults,bind 0 0" >> /etc/fstab

mkdir /apps

mount /apps
mount /media

#### Directories to create
## The directories below should be owned by user plex and group plex

mkdir -p /apps/configs/{plex,plexrequests,nzbget,sonarr,couchpotato}
chown -R plex:plex /apps

## The directories below should be owned by the user plex and the group plex. Need to have permissions set to 0775

mkdir -p /media/{movies,tv,nzbget}
chown -R plex:plex /media

#### Yum stuffs to get things in order before we can use docker

## Add the docker repo, the command below is the exact command that needs to be executed to create the repo.

sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/fedora/${releasever}/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

## Install some goodies with yum

dnf update -y
dnf install -y nginx docker-engine docker-compose

