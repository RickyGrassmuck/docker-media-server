# Docker Media Server

**NOTE: HERE BE DRAGONS! Seriously though, it appears this repo has been getting a bit of traffic lately. Please keep in mind that this project is not polished at all so be sure to only use it if you understand what the script does and can deal with fixing shit that will inevitably go wrong when using.

That said, I will be overhauling this very soon to make it more robust and easier to use since people seem to be having a good use for it.

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


