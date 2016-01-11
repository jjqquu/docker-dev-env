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

# step 2: get docker0 ip addr for dns purpose
docker-machine ssh default '/sbin/ifconfig docker0'  |grep "inet addr" |awk '{print $2}' |awk -F: '{print $2}' > dns.ip
