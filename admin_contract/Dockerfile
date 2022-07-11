FROM python:3.7-slim

WORKDIR /app

RUN apt update && apt install -y curl iputils-ping
RUN pip install --upgrade pip
COPY requirements.txt /app/
RUN pip install -r requirements.txt

COPY init.sh /app
COPY . /app/


ENTRYPOINT ["/bin/sh", "-c"]
CMD ["/app/init.sh"]
