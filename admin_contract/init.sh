#!/bin/bash

exit_code = 0

healthcheck() {
  while ! curl --insecure --silent --fail https://admin.kong-server.com:443/metrics; do
      echo >&2 'Kong down, retrying in 2s...'
      sleep 2
  done
}
export -f healthcheck

echo "Waiting Kong to be ready for tests..."

timeout 90s bash -c healthcheck

if [[ $? -eq 124 ]]; then
  echo "Waiting for Kong has timed out"
  exit_code=1
else
  echo "Running provider state endpoint..."
  python3 state_endpoint/app.py &
  background_flask_pid=$!
  echo "Running Contract Tests..."
  python3 -m unittest
  exit_code=$?
  echo "Killing provider state endpoint..."
  kill "$background_flask_pid"
fi

exit $exit_code
