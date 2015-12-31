FROM centos
MAINTAINER qujinping 

RUN yum -y install dnsmasq dnsmasq-utils && yum clean all

COPY dnsmasq.conf /etc/
COPY resolv.dnsmasq.conf /etc/

EXPOSE 5353

CMD ["dnsmasq", "-d"]
