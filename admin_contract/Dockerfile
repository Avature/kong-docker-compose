FROM python:3.7-slim

WORKDIR /app

COPY init.sh /app
COPY . /app/
COPY requirements.txt /app

RUN apt update && apt install -y curl iputils-ping
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["/app/init.sh"]
