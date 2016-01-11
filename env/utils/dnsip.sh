#!/bin/bash

# get docker0 ip addr for dns purpose
docker-machine ssh default '/sbin/ifconfig docker0'  |grep "inet addr" |awk '{print $2}' |awk -F: '{print $2}' > dns.ip
