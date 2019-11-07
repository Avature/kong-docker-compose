# Custom APIs KONG Distro

## Preconditions:

### Install docker && docker-compose (in a bash console):

* ensure that exist the path ''/usr/local/bin''. If not, create it with <pre>sudo mkdir -p /usr/local/bin</pre>
* install curl if not installed <pre>sudo apt-get install curl</pre>
* install docker -> https://docs.docker.com/install/linux/docker-ce/ubuntu/
* configure docker to execute without sudo -> https://docs.docker.com/install/linux/linux-postinstall/
* install docker-compose -> https://docs.docker.com/compose/install/#install-compose
* Clone the repo to your $HOME with: <pre>git clone https://gitlab.xcade.net/CustomAPIs/kong-docker</pre>
* If after installing DOCKER, your access to gitlab breakes, please follow the Julio's Magic in the wiki: https://wiki.xcade.net/wiki/Integrations_2.0:_Cells#How_to_install_Docker

## Usage:

* To start the Platform run: ./startLocal.sh

* To login with BASH into KONG (See logs, adjust configs: ./startBash.sh)

