FROM jdk

RUN wget --no-check-certificate -O /tmp/zookeeper-3.4.6.tar.gz.sha1 https://www.us.apache.org/dist/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz.sha1 && \
    wget --no-check-certificate -O /tmp/zookeeper-3.4.6.tar.gz http://mirror.bit.edu.cn/apache/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz && \
    cd /tmp && sha1sum -c zookeeper-3.4.6.tar.gz.sha1 && \
    tar -xzf /tmp/zookeeper-3.4.6.tar.gz -C /opt && \
    mv /opt/zookeeper-3.4.6 /opt/zookeeper 

EXPOSE 2181 2888 3888

WORKDIR /opt/zookeeper
COPY docker-entrypoint.sh /entrypoint.sh

VOLUME ["/var/lib/zookeeper", "/var/log/zookeeper"]

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/opt/zookeeper/bin/zkServer.sh", "start-foreground"]
