# Changelog


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

