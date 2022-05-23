FROM python:3.7-slim

WORKDIR /app

COPY init.sh /app
COPY verify_contract.py /app
COPY requirements.txt /app

# RUN apk add gettext
# RUN apk add bash
# RUN apk add openssl

RUN pip install -r requirements.txt

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["/app/init.sh"]
