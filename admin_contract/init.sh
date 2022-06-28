#!/bin/bash

python3 state_endpoint/app.py &
background_flask_pid=$!

healthcheck() {
  while ! curl --insecure --silent --fail https://admin.kong-server.com:443/metrics; do
      echo >&2 'Kong down, retrying in 2s...'
      sleep 2
  done
}
export -f healthcheck

echo "Waiting Kong to be ready for tests..."

timeout 90s bash -c healthcheck

if [ $? -ne 124 ]; then
  echo "Waiting for Kong has timed out"
else
  echo "Running Contract Tests..."
  python3 -m unittest
fi

kill "$background_flask_pid"
