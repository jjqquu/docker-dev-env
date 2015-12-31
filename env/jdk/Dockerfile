#
# Oracle Java 8 Dockerfile
#

FROM centos

# Install Java.
RUN cd /tmp \
	&& wget --retry-connrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 0 --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u20-b26/jdk-8u20-linux-x64.rpm" \
	&& rpm -Uvh jdk-8u20-linux-x64.rpm \
	&& rm -f /tmp/jdk-8u20-linux-x64.rpm \
	&& alternatives --install /usr/bin/java java /usr/java/latest/bin/java 200000 \
	&& alternatives --install /usr/bin/javaws javaws /usr/java/latest/bin/javaws 200000 \
	&& alternatives --install /usr/bin/javac javac /usr/java/latest/bin/javac 200000 \
	&& alternatives --install /usr/bin/jar jar /usr/java/latest/bin/jar 200000

# Define working directory.
WORKDIR /data

ENV JAVA_HOME /usr/java/latest
ENV PATH /usr/java/latest/bin/:$PATH

# Define default command.
CMD ["bash"]
