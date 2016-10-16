# Docker Media Server

## Requirements

- docker
- docker-compose
- mount.bind

## Usage

1) Clone the repo and cd into it
2) Run `bash setup.sh` with root privileges
3) If OS uses systemd, run `systemctl start compose-mediaserver.service` with root privileges
4) If no systemd, simply run `docker-compose up -d` with root privileges from the project directory
5) Profit


