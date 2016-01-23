#
# This is the official docker image that is used for production deployments of docker.
#
# It has the marathon startup script as entrypoint.
#
# It will reresolve all dependencies on every change (as opposed to Dockerfile.development)
# but it ultimately results in a smaller docker image.
#
FROM mesos

COPY . /marathon
WORKDIR /marathon

ADD repositories /root/.sbt/repositories

RUN eval $(sed s/sbt.version/SBT_VERSION/ </marathon/project/build.properties) && \
    mkdir -p /usr/local/bin && \
    wget -P /usr/local/bin/ http://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/$SBT_VERSION/sbt-launch.jar && \
    cp /marathon/project/sbt /usr/local/bin && chmod +x /usr/local/bin/sbt && \
    sbt -Dsbt.override.build.repos=true -Dsbt.log.format=false assembly && \
    mv $(find target -name 'marathon-assembly-*.jar' | sort | tail -1) ./ && \
    rm -rf target/* ~/.sbt ~/.ivy2 && \
    mv marathon-assembly-*.jar target && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENTRYPOINT ["./bin/start"]
