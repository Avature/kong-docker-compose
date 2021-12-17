#!/bin/bash
cd `dirname "$0"`

TARGET_DIR="${TARGET_DIR:-./}"

envsubst '$${HOST_SERVICE_SEPARATOR} $${BASE_HOST_DOMAIN}' < ./admin-url.conf.template > "$TARGET_DIR"admin-url.conf
envsubst '$${HOST_SERVICE_SEPARATOR} $${BASE_HOST_DOMAIN}' < ./gateway-url.conf.template > "$TARGET_DIR"gateway-url.conf
envsubst '$${HOST_SERVICE_SEPARATOR} $${BASE_HOST_DOMAIN}' < ./konga-url.conf.template > "$TARGET_DIR"konga-url.conf
