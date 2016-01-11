# Set the base image to use to Centos
FROM centos

# Set the file maintainer (your name - the file's author)
MAINTAINER qujinping

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r memcache && useradd -r -g memcache memcache

RUN yum -y install gcc libc6-dev make perl \
        && curl jaist.dl.sourceforge.net/project/levent/release-2.0.22-stable/libevent-2.0.22-stable.tar.gz -o libevent.tar.gz \
	&& mkdir -p /usr/src/libevent \
	&& tar -xzf libevent.tar.gz -C /usr/src/libevent --strip-components=1 \
	&& rm libevent.tar.gz \
	&& cd /usr/src/libevent \
	&& ./configure --prefix=/usr \
	&& make \
	&& make install \
	&& cd / && rm -rf /usr/src/libevent \
	&& curl -SL "http://memcached.org/files/memcached-1.4.25.tar.gz" -o memcached.tar.gz \
	&& echo "7fd0ba9283c61204f196638ecf2e9295688b2314 memcached.tar.gz" | sha1sum -c - \
	&& mkdir -p /usr/src/memcached \
	&& tar -xzf memcached.tar.gz -C /usr/src/memcached --strip-components=1 \
	&& rm memcached.tar.gz \
	&& cd /usr/src/memcached \
	&& ./configure --prefix=/usr \
	&& make \
	&& make install \
	&& cd / && rm -rf /usr/src/memcached \
	&& yum clean all

ENV LD_LIBRARY_PATH /usr/local/lib:/usr/lib:/lib
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod 755 /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

USER memcache
EXPOSE 11211
CMD ["memcached"]
