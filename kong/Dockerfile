FROM kong:2.1.4
USER root
RUN apk add bash
RUN apk add jq
RUN apk add vim
RUN apk add git
RUN apk add curl

COPY ./conf/custom-entrypoint.sh /etc/kong/custom-entrypoint.sh
COPY ./conf/custom-nginx.conf /usr/local/kong/custom-nginx.conf
COPY ./plugins /usr/local/custom/kong/plugins
COPY ./conf/kong.conf /etc/kong/kong.conf

RUN chmod +x /etc/kong/custom-entrypoint.sh

CMD ["/etc/kong/custom-entrypoint.sh"]
