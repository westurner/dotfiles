#!/bin/sh
#wget https://bitbucket.org/pypa/setuptools/raw/tip/ez_setup.py
curl -SL peak.telecommunity.com/dist/ez_setup.py > ez_setup.py
python ./ez_setup.py -U setuptools
python ./ez_setup.py -U pip
python ./ez_setup.py -U virtualenv
