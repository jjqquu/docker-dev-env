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
