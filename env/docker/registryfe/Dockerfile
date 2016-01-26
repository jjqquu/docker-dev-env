FROM nodejs
MAINTAINER "Qu jinping"

USER root

############################################################
# Setup environment variables
############################################################

ENV SOURCE_DIR /source
ENV START_SCRIPT /root/start-develop.sh

RUN git config --global url."https://".insteadOf git://
# Avoid this: "Problem with the SSL CA cert (path? access rights?)"
RUN git config --global http.sslVerify false

############################################################
# Create start script
############################################################

# Exposed ports (only the grunt port 9000)
EXPOSE 9000

VOLUME ["/source"]

CMD $START_SCRIPT
