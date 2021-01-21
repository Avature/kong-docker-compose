#!/bin/sh

python3 -m venv venv

venv/bin/pip3 install requests==2.24.0
venv/bin/python3 ./app/createAdmin.py
