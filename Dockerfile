FROM bellsoft/liberica-openjre-debian:11

ARG CONFLUENCE_VERSION=7.1.0
# permissions
ARG CONTAINER_UID=1000
ARG CONTAINER_GID=1000

# Setup useful environment variables
ENV CONF_HOME=/var/atlassian/confluence \
  CONF_INSTALL=/opt/atlassian/confluence \
  MYSQL_DRIVER_VERSION=5.1.48

COPY bin/custom_scripts.sh /usr/local/bin/custom_scripts.sh
COPY bin/wait-for-it.sh /usr/local/bin/wait-for-it

RUN echo "deb http://deb.debian.org/debian buster contrib" > /etc/apt/sources.list.d/contrib.list

# Install Atlassian Confluence
RUN export CONTAINER_USER=confluence \
  && export CONTAINER_GROUP=confluence \
  && addgroup --gid $CONTAINER_GID $CONTAINER_GROUP \
  && adduser --uid $CONTAINER_UID \
  --gid $CONTAINER_GID \
  --home /home/$CONTAINER_USER \
  --shell /bin/bash \
  $CONTAINER_USER \
  && apt-get update \
  && apt-get install -y \
  ca-certificates \
  locales \
  gzip \
  curl \
  tar \
  ttf-mscorefonts-installer \
  fontconfig \
  libmotif-common \
  ghostscript \
  graphviz \
  xmlstarlet \
  bash \
  wget \
  tini \
  postgresql-client \
  && fc-cache -f \
  && locale-gen \
  && mkdir -p ${CONF_HOME} \    
  && chown -R confluence:confluence ${CONF_HOME} \
  && mkdir -p ${CONF_INSTALL}/conf \
  && export CONFLUENCE_BIN=atlassian-confluence-${CONFLUENCE_VERSION}.tar.gz \    
  && wget -O $CONFLUENCE_BIN https://www.atlassian.com/software/confluence/downloads/binary/${CONFLUENCE_BIN} \
  && tar xzf $CONFLUENCE_BIN --strip-components=1 -C ${CONF_INSTALL} \
  && echo "confluence.home=${CONF_HOME}" > ${CONF_INSTALL}/confluence/WEB-INF/classes/confluence-init.properties \
  # Install database drivers
  && rm -f ${CONF_INSTALL}/lib/mysql-connector-java*.jar \
  && wget -O /tmp/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz \
  && tar xzf /tmp/mysql-connector-java-${MYSQL_DRIVER_VERSION}.tar.gz -C /tmp \
  && cp /tmp/mysql-connector-java-${MYSQL_DRIVER_VERSION}/mysql-connector-java-${MYSQL_DRIVER_VERSION}.jar ${CONF_INSTALL}/lib/mysql-connector-java-${MYSQL_DRIVER_VERSION}.jar \
  && chown -R confluence:confluence ${CONF_INSTALL} \
  # Adding letsencrypt-ca to truststore
  && export KEYSTORE=$JRE_HOME/lib/security/cacerts \
  # Install atlassian ssl tool
  && wget -O /home/${CONTAINER_USER}/SSLPoke.class https://confluence.atlassian.com/kb/files/779355358/779355357/1/1441897666313/SSLPoke.class \
  && chown -R confluence:confluence /home/${CONTAINER_USER} \
  # Install Tini Zombie Reaper And Signal Forwarder
  && mkdir -p /docker-entrypoint.d \
  && chmod +x /usr/local/bin/custom_scripts.sh \
  && chmod +x /usr/local/bin/wait-for-it \
  # Clean caches and tmps
  && apt-get -y autoremove \
  && rm -rf /tmp/* /var/tmp/* \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && rm -fr /tmp/*.deb \
  && rm -rf /usr/share/man/?? \
  && rm -rf /usr/share/man/??_*


# Expose default HTTP connector port.
EXPOSE 8090 8091

COPY confluence.cfg.xml.tpl ${CONF_HOME}/confluence.cfg.xml
RUN chown confluence:confluence ${CONF_HOME}/confluence.cfg.xml

USER confluence

VOLUME ["/var/atlassian/confluence"]
# Set the default working directory as the Confluence home directory.
WORKDIR ${CONF_HOME}
COPY bin/docker-entrypoint.sh /home/confluence/docker-entrypoint.sh

ENTRYPOINT ["/usr/bin/tini","--","/home/confluence/docker-entrypoint.sh"]
CMD ["confluence"]

LABEL org.opencontainers.image.source = "https://github.com/EugenMayer/docker-image-atlassian-confluence"
