#!/bin/bash
python -m coverage run -m unittest
python -m coverage html
mv htmlcov /tmp/
google-chrome /tmp/htmlcov/index.html
