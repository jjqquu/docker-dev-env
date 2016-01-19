#!/bin/bash


function INIT_CFG_MYID() {
if [ -f "/opt/zookeeper/conf/zoo.cfg" ]; then
    echo "zookeeper config found, thank you"
else
    if [ -z "${ZK_CONFIG}" ]; then
        echo "zookeeper config not found, here are the options:"
        echo "  - bind-mount /opt/zookeeper/conf/zoo.cfg"
        echo "  - specify ZK_CONFIG env variable with config values"
        exit 1
    fi

    echo "dataDir=/var/lib/zookeeper" > "/opt/zookeeper/conf/zoo.cfg"
    echo "dataLogDir=/var/log/zookeeper" >> "/opt/zookeeper/conf/zoo.cfg"

    for line in $(echo "${ZK_CONFIG}" | tr "," "\n"); do
        echo "$line" >> "/opt/zookeeper/conf/zoo.cfg"
    done
fi

if [ -e "/var/lib/zookeeper/myid" ]; then
    echo "zookeeper node id found, using it"
else
    if [ -z "${ZK_ID}" ]; then
        echo "zookeeper node id not found, here are your options:"
        echo "  - bind-mount /var/lib/zookeeper with myid"
        echo "  - specify ZK_ID env variable with id"
        exit 1
    fi

    echo "${ZK_ID}" > "/var/lib/zookeeper/myid"
fi
}

set -e

# if command starts with an option, prepend mysqld
if [ "$1" = 'start-foreground' ]; then
	set -- /opt/zookeeper/bin/zkServer.sh start-foreground 
	INIT_CFG_MYID
fi

if [ "$1" = '/opt/zookeeper/bin/zkServer.sh' ]; then
	INIT_CFG_MYID
fi

exec "$@"
