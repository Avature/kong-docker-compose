FROM kong:2.1.4
USER root

COPY ./conf/custom-entrypoint.sh /etc/kong/custom-entrypoint.sh
COPY ./conf/kong.conf /etc/kong/kong.conf
COPY ./plugins /usr/local/custom/kong/plugins

RUN chmod +x /etc/kong/custom-entrypoint.sh

CMD ["/etc/kong/custom-entrypoint.sh"]
