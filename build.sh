#!/bin/bash
git clone git://github.com/ariya/phantomjs.git
cd ./phantomjs/
git checkout ${PHANTOM_JS_VERSION}
git submodule init
git submodule update
python build.py --jobs 1
