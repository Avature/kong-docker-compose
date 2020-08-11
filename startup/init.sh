#!/bin/sh

python3 -m venv venv

venv/bin/pip install requests==2.24.0
venv/bin/python ./app/createAdmin.py
