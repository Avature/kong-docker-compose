# Custom APIs KONG Distro

## Preconditions:

### Install docker && docker-compose (in a bash console):

* ensure that exist the path ''/usr/local/bin''. If not, create it with <pre>sudo mkdir -p /usr/local/bin</pre>
* install curl if not installed <pre>sudo apt-get install curl</pre>
* install docker -> https://docs.docker.com/install/linux/docker-ce/ubuntu/
* configure docker to execute without sudo -> https://docs.docker.com/install/linux/linux-postinstall/
* install docker-compose -> https://docs.docker.com/compose/install/#install-compose-on-linux-systems
* Clone the repo to your $HOME with: <pre>git clone https://gitlab.xcade.net/CustomAPIs/kong-docker-compose</pre>
* If after installing DOCKER, your access to gitlab breakes, please follow the Julio's Magic in the wiki: https://wiki.xcade.net/wiki/Integrations_2.0:_Cells#How_to_install_Docker

## Usage:

* To start the Platform run: ./startLocal.sh

* To login with BASH into KONG (See logs, adjust configs: ./startBash.sh)

## Building debian package:

### Pre-requisites:

Install this dependencies:

1. fakeroot v1.22
2. debhelper (>= 9),
3. dh-exec


```console
cd kong-docker-compose
./buildDebian.sh
```

## Installing debian-package:

To install the debian package run:

```console
dpkg -i kong-docker-compose_0.0.1_all.deb
```
or either run this to install the dev version:

```console
dpkg -i kong-docker-compose-dev_0.0.1_all.deb
```
To run use this command (use start or startDev according to your needs):

```console
./{start, startDev}.sh
```

## FAQ/Troubleshooting:

If when you run start this error appears:

```
Creating network "kong_kong-net" with the default driver
ERROR: could not find an available, non-overlapping IPv4 address pool among the defaults to assign to the network
```

Issue the following *container-destructive* commands:

```
yes | docker network prune
yes | docker system prune
sudo ip link delete tun0
```

## TODO:

There are some pending tasks but for this beta version we need deploy a dev/qa server that doesn't need this features.

1. The connection between the iATS instances (either sandbox or productive/qa) and Kong and ALSO the connection between Konga and Kong admin interface are unencrypted and unprotected. We need to implement a sort of API key or some other authentication scheme.

2. The active boolean flag in the konga_kong_nodes table of the Konga DB isn't true by default which forces the user to manually "activate" the connection to the Kong server after setup (this could be automated some way)

3. Implement LDAP login on Konga UI
