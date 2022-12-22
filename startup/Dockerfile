FROM python:alpine

WORKDIR /app

COPY src/. /app/

RUN apk add gettext
RUN apk add bash
RUN apk add openssl

RUN pip install -r requirements.txt

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["/app/init.sh"]
