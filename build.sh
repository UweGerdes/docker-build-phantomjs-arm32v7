#!/bin/bash

cd /home/src/phantomjs/

# make sure to clean up when restarting build
git submodule foreach git clean -ddfx

python build.py --jobs 1 --git-clean-qtbase --git-clean-qtwebkit

cp -r /home/src/phantomjs/bin /home/phantomjs/

cd /home/phantomjs/

