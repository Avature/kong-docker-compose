FROM pantsel/konga:next

COPY konga/custom-entrypoint.sh /custom-entrypoint.sh
COPY check/wait-for-postgres.sh /wait-for-postgres.sh

RUN chmod +x /custom-entrypoint.sh

ENTRYPOINT ["/custom-entrypoint.sh"]
