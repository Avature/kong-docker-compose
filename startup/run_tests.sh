#!/bin/bash
cd test
pip install -r requirements.txt
cd ..
python -m unittest
