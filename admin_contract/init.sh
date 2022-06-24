#!/bin/sh

python3 state_endpoint/app.py &

background_flask_pid=$!

python3 -m unittest

kill "$background_flask_pid"
