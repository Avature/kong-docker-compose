# Changelog


### 0.0.1 (2020-06-16)

  * [0cb10b28] Add dev docker-compose file * Add environment variables to .env * Start kong dev environment script * Specify kong-dev package file copying instructions * Update README.md
  * [5375a46a] Add kong tag to the image * Add docker dependencies to the deb package
  * [ead66dad] Add script to build debian * Improve konga connection mechanism
  * [93513a9b] Add different network numeration to avoid collisions
  * [90456ff7] Add comments explaining each service * Fix connect to db scripts
  * [fa1535e6] Fix db healthcheck which breakes dev env * Fix Kong tag arg not passing to dockerfile * Add too to README.md
  * [3ae9c001] Fix buildDebian script to match company policies * Add .env to gitignore, instead track an example file * Add rename .env.example to .env in install script * Automatic rename of .env in case of not existent for start script
  * [453485d1] Add  plugins volume and base config
  * [95b20958] Add example kong file with plugins added and remove plugins of default config file

### 0.0.1 (2020-05-26)

  * Initial release. (Closes: #446124)

