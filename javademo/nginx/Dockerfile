FROM centos

MAINTAINER qujinping <qujinping@xiaomi.com>

# Install base stuff.
RUN rpm -ivh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
RUN yum -y install nginx && yum clean all 

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx", "/var/www"]

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]

