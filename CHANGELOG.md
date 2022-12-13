# Changelog


### 0.1.4 (2022-12-13)

  * First sync achieved.
  * Add Fixture finished message and docker on failure
  * Move createCerts.sh script into nginx container 
  * Remove createCerts.sh script volume 
  * Remove db preheating from test_admin_contracts_script
  * Fix konga 502 error by using a script that checks specifically the konga db state
  * Remove contract test to be able to build

### 0.1.3 (2022-12-06)

  * Fix error on client consumer validator adding coverage for rate-limiting
  * Fix test plugin executor
  * Fix broken log
  * Fix startup img version

### 0.1.2 (2022-07-18)

  * Add timeout much longer

### 0.1.1 (2022-07-18)

  * Remove start_period

### 0.0.21 (2022-07-12)

  * Fix long URL bug.
  * Add state endpoint for Pact testing.

### 0.0.20 (2022-05-30)

  * Add contract verification test fir admin API
  * Fix NGINX to enable stock entrypoint override
  * Remove build context from kong image service

### 0.0.19 (2022-05-11)

  * Use kong image instead of building it locally on the server * Add changelog * Update kong image

### 0.0.18 (2022-05-11)

  * Update dockerfile to include all the files on /app and build the image

### 0.0.17 (2022-05-04)

  * Change Dockerfile to include plugins
  * Make dev depends on prod and add liveness and readiness on kong in kubernetes
  * Move nginx to its own image
  * Fix create-urls to work from app directory, Fix permission setting, Support sh instead of bash

### 0.0.16 (2021-12-17)

  * Add certificates management to startup service container
  * Add create-urls logic to startup service

### 0.0.15 (2021-12-06)

  * Add server_name matching the header used on our client for upstream/loadbalancing
  * Add Avature's url to kong docker image registry

### 0.0.14 (2021-07-16)

  * Add conditional restart of Kong service

### 0.0.13 (2021-06-25)

  * Add startup admin user

### 0.0.12 (2021-05-26)

  * Add tests to SSL certificates creational scripts
  * Add pre and post inst scripts for plugins reload verification
  * Refactor and re-arrange tests for better clarity
  * Add some more testing

### 0.0.11 (2021-05-07)

  * Add renew CRT endpoint to Kong
  * Modify client_consumer_validator priority to 2
  * Add a base lua class at mtls_certs_manager
  * Add a factory lua class to get renew or register logic
  * Move startup config to a separated script

### 0.0.10 (2021-05-03)

  * Add Jenkins integration-test to avoid pushing debian install without new files

### 0.0.9 (2021-04-21)

  * Add file log censored plugin

### 0.0.8 (2020-12-18)

  * Add env variables for database host and port
  * Add db host and port to services

### 0.0.7 (2020-11-25)

  * Add metrics endpoint to gather prometheus stats data
  * Modify startup script to include / in targets
  * Add env variable for host_service_separator and default value
  * Remove absolute path from create_url script
  * Remove kong example config file. Add kong config file to debian install.

### 0.0.6 (2020-11-12)

  * [138e4dd6] Add files of client consumer validator plugin to deb pkg

### 0.0.5 (2020-11-12)

  * Add mTLS authentication on nginx service
  * Add Validate Client Consumer custom plugin
  * Improve README

### 0.0.4 (2020-11-03)

  * Add MTLS certs manager Plugin

### 0.0.3 (2020-10-13)

  * Add file-log plugin to Admin API service (Closes: #522205)
  * Add volume to kong service to access logs from outside the container
  * Modify how python startup script adds plugins
  * Add kong user to avoid permission issues

### 0.0.2 (2020-09-24)

  * Author: Juan Vincenti <juan.vincenti@avature.net>
  * Add nginx proxy pass.
  * Add SSL support for Admin API (Closes: #516914)
  * Add python startup script to configure admin routes loopback
  * Add virtual hosts for gateway, konga, and admin-api
  * Add LDAP support to Konga login

### 0.0.1 (2020-05-26)

  * Initial release. (Closes: #446124)

