FROM centos
MAINTAINER "Qu jinping"

RUN yum -y install epel-release \
	&& yum -y install  npm git nodejs \
	&& yum clean all

############################################################
# Install npm cache
############################################################
ADD npmrc /root/.npmrc

CMD ["npm"]
