#!/bin/sh

python3 -m venv venv

venv/bin/pip3 install -r requirements.txt
venv/bin/python3 ./app/createAdmin.py
