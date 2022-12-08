FROM nginx:stable-alpine
USER root

RUN mkdir -p /app
RUN chmod -R 777 /app
RUN apk add bash
RUN apk add openssl

COPY ./admin.conf /etc/nginx/conf.d/admin.conf
COPY ./gateway.conf /etc/nginx/conf.d/gateway.conf
COPY ./konga.conf /etc/nginx/conf.d/konga.conf
COPY ./20-custom-configs.conf /etc/nginx/conf.d/20-custom-configs.conf

COPY ./createCerts.sh /etc/ssl/createCerts.sh
COPY ./server_hosts/create-urls.sh /app/create-urls.sh
COPY ./server_hosts/admin-url.conf.template /app/admin-url.conf.template
COPY ./server_hosts/gateway-url.conf.template /app/gateway-url.conf.template
COPY ./server_hosts/konga-url.conf.template /app/konga-url.conf.template
COPY ./entrypoint.sh /docker-entrypoint.d/0-entrypoint.sh
