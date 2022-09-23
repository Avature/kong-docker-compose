FROM kong:2.1.4
USER root

COPY kong/conf/custom-entrypoint.sh /etc/kong/custom-entrypoint.sh
COPY kong/conf/kong.conf /etc/kong/kong.conf
COPY kong/plugins /usr/local/custom/kong/plugins
COPY check/wait-for-postgres.sh /wait-for-postgres.sh

RUN chmod +x /etc/kong/custom-entrypoint.sh

ENTRYPOINT ["/etc/kong/custom-entrypoint.sh"]
CMD ["kong", "docker-start"]
