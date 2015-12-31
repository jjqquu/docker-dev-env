FROM golang

RUN yum -y install librados2-devel apr-util && \
    yum clean all

ENV DISTRIBUTION_DOWNLOAD_URL https://github.com/docker/distribution/archive/v2.2.1.zip
ENV DISTRIBUTION_HOME /go/src/github.com/docker/
ENV DISTRIBUTION_DIR $DISTRIBUTION_HOME/distribution
ENV GOPATH $DISTRIBUTION_DIR/Godeps/_workspace:$GOPATH
ENV DOCKER_BUILDTAGS include_rados include_oss include_gcs

RUN curl -fsSL "$DISTRIBUTION_DOWNLOAD_URL" -o registry.zip \
	&& mkdir -p /etc/docker/registry \
	&& mkdir -p $DISTRIBUTION_HOME \
        && unzip -d $DISTRIBUTION_HOME registry.zip \
        && mv $DISTRIBUTION_HOME/distribution-2.2.1 $DISTRIBUTION_DIR \
	&& cp $DISTRIBUTION_DIR/cmd/registry/config-dev.yml /etc/docker/registry/config.yml \
        && rm registry.zip \
	&& cd $DISTRIBUTION_DIR \
	&& make PREFIX=/go clean binaries

WORKDIR $DISTRIBUTION_DIR

VOLUME ["/var/lib/registry"]
EXPOSE 5000
ENTRYPOINT ["registry"]
CMD ["/etc/docker/registry/config.yml"]


