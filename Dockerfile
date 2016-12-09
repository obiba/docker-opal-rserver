#
# R Server for Opal Dockerfile
#
# https://github.com/obiba/docker-opal-rserver
#

# Pull base image
FROM openjdk:8

MAINTAINER OBiBa <dev@obiba.org>

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
	&& wget -q -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -q -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true

ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8

ENV RSERVER_HOME=/srv
ENV JAVA_OPTS=-Xmx2G

# Install R Server for Opal
RUN \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https && \
  wget -q -O - https://pkg.obiba.org/obiba.org.key | apt-key add - && \
  echo 'deb https://pkg.obiba.org unstable/' | tee /etc/apt/sources.list.d/obiba.list && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-unauthenticated  opal-rserver

RUN chmod +x /usr/share/rserver/bin/rserver

COPY bin /opt/obiba/bin
COPY conf/Rserv.conf /var/lib/rserver/conf/Rserv.conf

RUN chmod +x -R /opt/obiba/bin && chown rserver:adm /var/lib/rserver/conf/Rserv.conf
RUN chown -R rserver /opt/obiba

VOLUME /srv

EXPOSE 6312 6311

# Define default command.
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["app"]
