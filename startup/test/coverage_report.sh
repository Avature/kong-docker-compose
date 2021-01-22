#!/bin/bash
cd ..
pip3 install coverage
python -m coverage run -m unittest
python -m coverage html
cp -r htmlcov /tmp/
rm -rf htmlcov
google-chrome /tmp/htmlcov/index.html
