#!/bin/bash
cd `dirname "$0"`
envsubst '$${HOST_SERVICE_SEPARATOR} $${BASE_HOST_DOMAIN}' < ./admin-url.conf.template > admin-url.conf
envsubst '$${HOST_SERVICE_SEPARATOR} $${BASE_HOST_DOMAIN}' < ./gateway-url.conf.template > gateway-url.conf
envsubst '$${HOST_SERVICE_SEPARATOR} $${BASE_HOST_DOMAIN}' < ./konga-url.conf.template > konga-url.conf
