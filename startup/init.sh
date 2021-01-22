#!/bin/sh

cd /app

pip install -r requirements.txt
python createAdmin.py
