#!/bin/bash

WORKDIR=`pwd`

MARATHON_VERSION=0.14.0
MESOS_VERSION=0.26.0

function SETUP_MARATHON_BUILD {
cp docker/marathon/Dockerfile marathon/
cp docker/marathon/Dockerfile-dev marathon/
cp docker/marathon/repositories marathon/
cp docker/marathon/project/* marathon/project/
}

function SETUP_MESOS_BUILD {
cp docker/mesos/* mesos/
}


function BUILD_MESOS_IMAGE {
cd mesos
docker build -f Dockerfile -t mesos .
cd ..
}

wget -c https://github.com/mesosphere/marathon/archive/v${MARATHON_VERSION}.zip
unzip v${MARATHON_VERSION}.zip
mv marathon-${MARATHON_VERSION}/ marathon/
rm -f v${MARATHON_VERSION}.zip
SETUP_MARATHON_BUILD
cd $WORKDIR


wget -c https://github.com/apache/mesos/archive/${MESOS_VERSION}.zip
unzip ${MESOS_VERSION}.zip 
mv mesos-${MESOS_VERSION}/ mesos/
SETUP_MESOS_BUILD
BUILD_MESOS_IMAGE
rm -f ${MESOS_VERSION}.zip
cd $WORKDIR
