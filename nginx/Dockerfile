FROM nginx:stable-alpine

RUN mkdir -p /app
RUN chmod -R 777 /app

COPY . /etc/nginx/conf.d
COPY create-urls.sh /app
COPY entrypoint.sh /app

CMD ["/app/entrypoint.sh"]
