# Description:

This is the Avature's Kong API Gateway docker-compose distribution

## What it includes?

### It includes the following docker-compose services:

* kong: Kong 2.1.4 API Gateway
* konga: Konga Kong's UI (latest version)
* db: PostgreSQL 9.5 Databse
* nginx: Nginx (latest nginx docker image version) Proxy pass that exposes gateway, admin, and konga subdomains in a secured and unified way.
* startup: Startup script that sets up the admin API loopback and plugins configuration in an automated way.

### It also includes the following custom Kong plugins, pre-built and included in the docker-compose project:

- [MTLS Certificates Manager](plugins/mtls_certs_manager/README.md)

  This plugin allows the server to emit x509 certificates signed off by the server's CA certificate.

- [Client Consumer Validator](plugins/client_consumer_validator/README.md)

  This plugin allows the server to validate headers and json payload information against authenticated consumer
  This helps in use cases where we need to assure some configurations done to services and routes are only done by a particular consumer.

## Preconditions:

### Installing a development environment (debian based distro):

* ensure that the path ''/usr/local/bin'' exists. If not, create it with <pre>sudo mkdir -p /usr/local/bin</pre>
* install curl if not installed <pre>sudo apt-get install curl</pre>
* install docker -> https://docs.docker.com/install/linux/docker-ce/ubuntu/
* configure docker to execute without sudo -> https://docs.docker.com/install/linux/linux-postinstall/
* install docker-compose -> https://docs.docker.com/compose/install/#install-compose-on-linux-systems
* Clone the repo to your $HOME with: <pre>git clone https://this-repo-url/CustomAPIs/kong-docker-compose</pre>

# Basic usage:

* To start the Platform run: ./startDev.sh

* After that Konga UI must be up and running on the default URL: https://konga.kong-server.com

* Username: admin, Password: adminadminadmin

* To login with BASH into KONG after startup (See logs, adjust configs: ./startBash.sh)

* Refer to the Client-Auth section to know how to use the mTLS authentication

## Building debian package:

### Pre-requisites:

Install these dependencies:

1. fakeroot v1.22
2. debhelper (>= 9),
3. dh-exec


```bash
cd kong-docker-compose
./buildDebian.sh
```

# Installation

## Installing debian-package (production environment):

To install the debian package run:

```bash
dpkg -i ../kong-docker-compose_X.Y.Z_all.deb
```

Then run start or startDev script (according to your needs):

```bash
./{start, startDev}.sh
```

After installing, copy the .env.example file:

```bash
cp .env.example .env
```

And modify it according to your needs.

## FAQ/Troubleshooting Dev Environment:

* If when you run start this error appears:

```
Creating network "kong_kong-net" with the default driver
ERROR: could not find an available, non-overlapping IPv4 address pool among the defaults to assign to the network
```

Issue the following *container-destructive* commands:

```bash
yes | docker network prune
yes | docker system prune
sudo ip link delete tun0
```

* If when you run start this error appears:

```
genrsa: Can't open "certs/server-ca-key.key" for writing, No such file or directory
Can't open certs/server-ca-key.key for reading, No such file or directory
139896872256512:error:02001002:system library:fopen:No such file or directory:crypto/bio/bss_file.c:69:fopen('certs/server-ca-key.key','r')
```

## Client Authentication with mutual TLS

The connection between Kong's admin API and its clients must be done via mutual TLS client authentication using client certificates signed by the kong distribution server's CA.

To hit the secured admin API using mTLS you must first create a consumer using the register endpoint /instances/register provided by the mtls certs manager plugin, example call to create a consumer:

```json
{
  "csr": "Certificate sign request data",
  "instance": {
    "name": "test-instance.ourdomain.org", "description": "A description for the instance"
  }
}
```

Where:

* Certificate sign request data:

Is the content of a certificate signing request (including the markers of start and end) that can be generated with openssl command.

* test-instance.ourdomain.org:

Is the hostname of the consumer instance that will be client for the admin API of Kong.

* A description for the instance:

Is a string used to describe the client that will be added as a consumer for Kong that will be stored as a tag in the Kong's consumer table.

The certificates can be signed off by the mtls certs manager kong plugin via instances/register API endpoint.

For more details about client auth workflow [click here](CLIENT_AUTH.md)

# Running The Tests:

For contract tests run this command:

```bash
cd test && PACT_BROKER_URL=https://pact-broker.yourserver.com ./test_admin_api_contracts
```

Repleace the environment variable with your pact-broker deployment.

# Contribuiting:

* The recommended dev environment is VS Code with Python and LUA addons.

* The major parts of the application are dockerized so the environment leans mainly on docker and docker-compose.

## TODO:

1. The active boolean flag in the konga_kong_nodes table of the Konga DB isn't true by default which forces the user to manually "activate" the connection to the Kong server after setup (this could be automated some way)
