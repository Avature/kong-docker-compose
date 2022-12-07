FROM pantsel/konga:next

COPY ./custom-entrypoint.sh /custom-entrypoint.sh
COPY ./wait-for-postgres.sh /wait-for-postgres.sh

RUN chmod +x /custom-entrypoint.sh

ENTRYPOINT ["/custom-entrypoint.sh"]
