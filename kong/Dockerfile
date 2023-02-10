FROM kong:2.1.4
USER root

ARG UID
ARG GID

ENV UID=${UID:-1000}
ENV GID=${GID:-1000}

RUN addgroup -g ${GID} --system kong_grp
RUN adduser -G kong_grp --system -D -s /bin/sh -u ${UID} kong_usr

COPY ./conf/custom-entrypoint.sh /etc/kong/custom-entrypoint.sh
COPY ./conf/kong.conf /etc/kong/kong.conf
COPY ./plugins /usr/local/custom/kong/plugins
COPY ./wait-for-postgres.sh /wait-for-postgres.sh

RUN chmod +x /etc/kong/custom-entrypoint.sh
RUN apk --no-cache add shadow

ENTRYPOINT ["/etc/kong/custom-entrypoint.sh"]

USER kong_usr

CMD ["kong", "docker-start"]
