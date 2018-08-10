#
# R Server for Opal Dockerfile
#
# https://github.com/obiba/docker-opal-rserver
#

# Pull base image
FROM openjdk:7

MAINTAINER OBiBa <dev@obiba.org>

# grab gosu for easy step-down from root
# see https://github.com/tianon/gosu/blob/master/INSTALL.md
ENV GOSU_VERSION 1.10
ENV GOSU_KEY B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN set -ex; \
  \
  fetchDeps=' \
    ca-certificates \
    wget \
  '; \
  apt-get update; \
  apt-get install -y --no-install-recommends $fetchDeps; \
  rm -rf /var/lib/apt/lists/*; \
  \
  dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
  wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
  wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
  \
# verify the signature
  export GNUPGHOME="$(mktemp -d)"; \
  gpg --keyserver pgp.mit.edu --recv-keys "$GOSU_KEY" || \
  gpg --keyserver keyserver.pgp.com --recv-keys "$GOSU_KEY" || \
  gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GOSU_KEY"; \
  gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
  rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
  \
  chmod +x /usr/local/bin/gosu; \
# verify that the binary works
  gosu nobody true;

ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8

ENV RSERVER_HOME=/srv
ENV JAVA_OPTS=-Xmx2G

ENV RSERVER_ADMIN_VERSION 1.4.0

# Install latest R
RUN \
  echo 'deb http://cran.rstudio.com/bin/linux/debian jessie-cran35/' | tee /etc/apt/sources.list.d/r.list && \
  apt-key adv --keyserver keys.gnupg.net --recv-key E19F5F87128899B192B1A2C2AD5F960A256A04AF && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y r-base

# Install R Server for Opal
RUN \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https && \
  apt-key adv --keyserver keys.gnupg.net --recv-keys 379CE192D401AB61 && \
  echo 'deb https://dl.bintray.com/obiba/deb all main' | tee /etc/apt/sources.list.d/obiba.list && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y rserver-admin=$(apt-cache madison rserver-admin | cut -d ' ' -f 3 | grep ${RSERVER_ADMIN_VERSION}-b) opal-rserver

# Make sure latest Rserve is installed
RUN Rscript -e "install.packages('Rserve', repos='http://cran.rstudio.com')"

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
