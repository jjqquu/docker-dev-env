#!/bin/bash

curl -X POST -H "Accept: application/json" -H "Content-Type: application/json" \
  192.168.99.100:8080/v2/apps -d '
{
    "id": "hello",
    "cpus": 0.1,
    "mem": 32,
    "cmd": "echo hello; sleep 10"
}'
