FROM pantsel/konga:next

RUN apk add postgresql-client

COPY ./custom-entrypoint.sh /custom-entrypoint.sh
COPY ./wait-for-postgres.sh /wait-for-postgres.sh
COPY ./check_konga_db.sh /check_konga_db.sh

RUN chmod +x /custom-entrypoint.sh

ENTRYPOINT ["/custom-entrypoint.sh"]
