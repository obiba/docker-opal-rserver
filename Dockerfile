#
# R Server for Opal Dockerfile
#
# https://github.com/obiba/docker-opal-rserver
#

FROM obiba/docker-gosu:latest AS gosu

FROM obiba/obiba-r:4.0

LABEL OBiBa <dev@obiba.org>

ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8

ENV RSERVER_HOME=/srv
ENV JAVA_OPTS=-Xmx2G

ENV RSERVER_ADMIN_VERSION 1.6.0
ENV RSERVE_VERSION 1.8-7
ENV RSERVE_PORT_MIN 53000
ENV RSERVE_PORT_MAX 53200

# Install R Server admin
RUN set -x && \
  cd /usr/share/ && \
  wget -q -O rserver-admin.zip https://github.com/obiba/rserver-admin/releases/download/${RSERVER_ADMIN_VERSION}/rserver-admin-${RSERVER_ADMIN_VERSION}-dist.zip && \
  unzip -q rserver-admin.zip && \
  rm rserver-admin.zip && \
  mv rserver-admin-${RSERVER_ADMIN_VERSION} rserver && \
  ln -s /usr/share/rserver /var/lib/rserver # for Rprofile.R legacy

# Make sure latest known Rserve is installed with fork port range hack
RUN wget -q https://www.rforge.net/Rserve/snapshot/Rserve_${RSERVE_VERSION}.tar.gz && \
  tar -xf Rserve_${RSERVE_VERSION}.tar.gz && \
  rm Rserve_${RSERVE_VERSION}.tar.gz && \
  sed -i "s/32768)>65000/${RSERVE_PORT_MIN})>${RSERVE_PORT_MAX}/" Rserve/src/Rserv.c && \
  sed -i "s/Binary R server/Binary R server (${RSERVE_VERSION}-obiba)/" Rserve/DESCRIPTION && \
  tar -czvf Rserve_${RSERVE_VERSION}-obiba.tar.gz Rserve && \
  R CMD INSTALL Rserve_${RSERVE_VERSION}-obiba.tar.gz

COPY --from=gosu /usr/local/bin/gosu /usr/local/bin/

RUN chmod +x /usr/share/rserver/bin/rserver

COPY bin /opt/obiba/bin
COPY conf/Rserv.conf /usr/share/rserver/conf/Rserv.conf
COPY conf/Rprofile.R /usr/share/rserver/conf/Rprofile.R
RUN mkdir -p $RSERVER_HOME/conf && cp -r /usr/share/rserver/conf/* $RSERVER_HOME/conf
RUN adduser --system --home $RSERVER_HOME --no-create-home --disabled-password rserver

RUN chmod +x -R /opt/obiba/bin && chown -R rserver:adm $RSERVER_HOME
RUN chown -R rserver:adm /opt/obiba

# Additional system dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y libsasl2-dev libssh-dev libgit2-dev libmariadbclient-dev libpq-dev libsodium-dev libgit2-dev libssh2-1-dev libgdal-dev gdal-bin libproj-dev proj-data proj-bin libgeos-dev
RUN Rscript -e "update.packages(ask = FALSE, repos = c('https://cloud.r-project.org'), instlib = '/usr/local/lib/R/site-library')"
RUN Rscript -e "install.packages(c('gh', 'Cairo', 'multcomp', 'lme4', 'betareg', 'modeltools', 'mvtnorm', 'TH.data', 'nloptr', 'flexmix'), repos=c('https://cloud.r-project.org'), dependencies=TRUE, lib='/usr/local/lib/R/site-library')"
RUN Rscript -e "BiocManager::install(c('Biobase','GWASTools', 'limma', 'SummarizedExperiment', 'SNPRelate', 'GENESIS', 'MEAL', 'CopyNumber450kData'), ask = FALSE, dependencies=TRUE, lib='/usr/local/lib/R/site-library')"
RUN Rscript -e "devtools::install_github('perishky/meffil', repos=c('https://cloud.r-project.org'), lib='/usr/local/lib/R/site-library')"

VOLUME /srv

EXPOSE 6312 6311
EXPOSE ${RSERVE_PORT_MIN}-${RSERVE_PORT_MAX}

# Define default command.
COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["app"]
