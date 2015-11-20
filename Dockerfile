#
# R Server for Opal Dockerfile
#
# https://github.com/obiba/docker-opal-rserver
#

# Pull base image
FROM r-base

MAINTAINER OBiBa <dev@obiba.org>

ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8

# Install R Server for Opal
RUN \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https && \
  wget -q -O - https://pkg.obiba.org/obiba.org.key | apt-key add - && \
  echo 'deb https://pkg.obiba.org stable/' | tee /etc/apt/sources.list.d/obiba.list && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y opal-rserver

COPY bin /opt/obiba/bin
COPY conf/Rserv.conf /var/lib/rserver/conf/Rserv.conf

RUN chmod +x -R /opt/obiba/bin && chown rserver:adm /var/lib/rserver/conf/Rserv.conf

# Define default command.
ENTRYPOINT ["/opt/obiba/bin/start.sh"]

EXPOSE 6312 6311 