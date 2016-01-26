#!/bin/bash

WORKDIR=`pwd`

# step 1: build required images
cd centos
docker build --rm -t centos .
cd $WORKDIR

cd jdk
docker build --rm -t jdk .
cd $WORKDIR

cd maven
docker build --rm -t mvn .
cd $WORKDIR

cd maven-onbuild
docker build --rm -t mvn-onbuild .
cd $WORKDIR

cd golang
docker build --rm -t golang .
cd $WORKDIR

cd golang-onbuild
docker build --rm -t golang-onbuild .
cd $WORKDIR

cd zk
docker build --rm -t zk .
cd $WORKDIR

cd nodejs
docker build --rm -t nodejs .
cd $WORKDIR

git clone https://github.com/kwk/docker-registry-frontend.git registryfe
cp docker/registryfe/Dockerfile registryfe/



