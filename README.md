# Avature's KONG Distro

This is the Avature's Kong API Gateway docker-compose distribution

## What it includes?

### It includes the following docker-compose services services:

* kong: Kong 2.1.4 API Gateway
* konga: Konga Kong's UI (latest version)
* db: PostgreSQL 9.5 Databse
* nginx: Nginx (latest nginx docker image version) Proxy pass that exposes gateway, admin, and konga subdomains in a secured and unified way.
* startup: Startup script that setups the admin API loopback and plugins configuration in an automated way

### It also includes the following custom Kong plugins, pre-built and included in the docker-compose project:

- [MTLS Certificates Manager](plugins/mtls_certs_manager/README.md)

  This plugin allows the server to emit x509 certificates signed off by the server's CA certificate.

- [Client Consumer Validator](plugins/client_consumer_validator/README.md)

  This plugin allows the server to validate headers and json payload information agains authenticated consumer
  This helps in use cases where we need to assure some configurations done to services and routes are only done by a particular consumer.

## Preconditions:

### Install docker && docker-compose (in a bash console):

* ensure that exist the path ''/usr/local/bin''. If not, create it with <pre>sudo mkdir -p /usr/local/bin</pre>
* install curl if not installed <pre>sudo apt-get install curl</pre>
* install docker -> https://docs.docker.com/install/linux/docker-ce/ubuntu/
* configure docker to execute without sudo -> https://docs.docker.com/install/linux/linux-postinstall/
* install docker-compose -> https://docs.docker.com/compose/install/#install-compose-on-linux-systems
* Clone the repo to your $HOME with: <pre>git clone https://this-repo-url/CustomAPIs/kong-docker-compose</pre>

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

## Client Authentication with mutual TLS

The connection between Kong's admin API and its clients must be done via mutual TLS client authentication using client certificates signed by the kong distribution server's CA.

The certificates can be signed off by the mtls certs manager kong plugin via instances/register API endpoint.

For more details about client auth workflow [click here](CLIENT_AUTH.md)

## TODO:

1. The active boolean flag in the konga_kong_nodes table of the Konga DB isn't true by default which forces the user to manually "activate" the connection to the Kong server after setup (this could be automated some way)
