#!/bin/bash

cd /home/src/phantomjs/

python build.py --jobs 1

cp -r /home/src/phantomjs/bin /home/phantomjs/

cd /home/phantomjs/

