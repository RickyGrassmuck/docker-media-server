################################################################################################################
#### The script needs to perform the actions listed out below. They pretty much need to happen in the order
#### that they are listed. 
####
#### ** Bonus points for using tests to make sure things don't already exist as well as that they were created
####    properly afterwards.
################################################################################################################

#### Group that needs to be created

- media

#### Directories to create
## The directories below should be owned by user root and the group media

- /apps
- /apps/configs

## The directories below should be owned by the user plex and the group "media". Need to have permissions set to 0775

- /media 
- /media/movies
- /media/tv
- /media/nzbget/downloads

#### Yum stuffs to get things in order before we can use docker

## Add the docker repo, the command below is the exact command that needs to be executed to create the repo.

sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

## Install some goodies with yum

- yum update
- yum install epel-release
- yum install docker-engine git


