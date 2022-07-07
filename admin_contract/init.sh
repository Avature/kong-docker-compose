#!/bin/bash

exit_code=0

healthcheck() {
  until [ \
    "$(curl -H "Content-Type: application/json" --insecure -s -w '%{http_code}' -d '{"csr":"", "instance":{"name":"", "description":""}}' -o /dev/null "https://admin.kong-server.com:443/instances/register")" \
    -eq 400 ]
  do
    echo >&2 'Kong down, retrying in 3s...'
    sleep 3
  done
}
export -f healthcheck

echo "Waiting Kong to be ready for tests..."

timeout 300s bash -c healthcheck

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
