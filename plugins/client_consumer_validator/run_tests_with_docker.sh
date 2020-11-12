#!/bin/bash
docker run --rm -t -v `pwd`:/data imega/busted
echo "Exit code of the tests: $?"
