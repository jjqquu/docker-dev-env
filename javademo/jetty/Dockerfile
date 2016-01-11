FROM mvn

ADD . /usr/local/helloworld
RUN cd /usr/local/helloworld && mvn -s settings.xml clean install

CMD ["java", "-Djava.security.egd=file:/dev/urandom", "-Xdebug", "-Xrunjdwp:transport=dt_socket,address=62911,server=y,suspend=n", "-Xnoagent", "-jar", "/usr/local/helloworld/target/try-1.0.jar", "-p", "5001"]
