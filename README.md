[![Docker Stars](https://img.shields.io/docker/stars/eugenmayer/confluence.svg)](https://hub.docker.com/r/EugenMayer/confluence/) [![Docker Pulls](https://img.shields.io/docker/pulls/eugenmayer/confluence.svg)](https://hub.docker.com/r/eugenmayer/confluence/)

# Docker images for Atlassian Confluence

Production ready AND **development** ready, up to date builds of Atlassian Confluence - right from the original binary download based on

  - adoptjdk openjdk 11 (Confluence 7) 
  - adoptjdk openjdk 8 (Confluence 6)

You can run those images for production use ( see `./examples` ) or for developming with auto-setup and debugging.

## Automatic builds
This project is build by concourse.ci, see [our oss pipelines here](https://github.com/EugenMayer/concourse-our-open-pipelines)

## Supported tags and respective Dockerfile links

| Product |Version | Tags  | Dockerfile |
|---------|--------|-------|------------|
| Confluence 7.x (adopt openjdk java11) | 7.0-7.x(latest) | [see tags](https://hub.docker.com/r/eugenmayer/confluence/tags/) | [Dockerfile](https://github.com/EugenMayer/docker-image-atlassian-confluence/blob/master/Dockerfile) |
| Confluence 6.13.x+ (adopt openjdk java8) | 6.13.x<7.x(latest) | [see tags](https://hub.docker.com/r/eugenmayer/confluence/tags/) | [Dockerfile_java8](https://github.com/EugenMayer/docker-image-atlassian-confluence/blob/master/Dockerfile_java8) |

# Quickstart

```bash
docker-compose up
```

## Configuration

Please see the `docker-compose.yml` for the configuration variables

Also see the folder `examples/` for different examples with postgres or mysql

# Environment variables

Configures the db host to wait for the DB to come up. Those variables are not used by confluence during the installation
- CONFLUENCE_DB_HOST=db 
- CONFLUENCE_DB_PORT=5432

Set the DEBUG port, e.g. for development
- JPDA_ADDRESS=5005
- JPDA_TRANSPORT=dt_socket

Configuration
- CATALINA_OPTS=-Xms256m -Xmx1g
- CONFLUENCE_CONTEXT_PATH= # context path like `/confluence`
- CONFLUENCE_DELAYED_START= # seconds to wait before starting confluence
- CONFLUENCE_PROXY_NAME= # your.domatina.tld (no scheme!)- your outer proxy domain, e.g. if you use external ssl offloading
- CONFLUENCE_PROXY_PORT= # proxy port, 443 , e.g. if you use external ssl offloading
- CONFLUENCE_PROXY_SCHEME= # http or https - https if you use external ssl offloading


# Volumes for persistence

You will need to persist 
  - the confluence data under `/var/atlassian/confluence`
  - the database folder postgres: `/var/lib/postgresql/data` or mysql: `/var/lib/mysql`

# Custom scripts

You can add custom startup scripts to customize your confluence during the startup.
Let's assume you have a setup.sh in your folder

Your script `setup.sh` might look like this, setting up a confluence as fast as possible with 

 - preconfigured server id
 - a preset license
 - pre-configured database settings
 
Moving you as fast as possible to have a blank and working confluence installation. Be sure to replace the

 - <YOUR LICENSE> part and adjust the serverid
 - adjust your database name, user and password if needed

```bash
#!/bin/bash
set -e

# set the confluence installation set to DB select
xmlstarlet ed --pf --inplace --update "//setupType" --value "custom" ${CONF_HOME}/confluence.cfg.xml
xmlstarlet ed --pf --inplace --update "//setupStep" --value "setupdbchoice-start" ${CONF_HOME}/confluence.cfg.xml

# configure our serverID and license
xmlstarlet ed --pf --inplace --subnode '//properties' --type elem --name 'property' --value "B2DL-7TV3-LFUU-8DDD" -i '//properties/property[not(@name)]' --type attr --name 'name' --value "confluence.setup.server.id" ${CONF_HOME}/confluence.cfg.xml
xmlstarlet ed --pf --inplace --subnode '//properties' --type elem --name 'property' --value "<YOUR LICENSE>" -i '//properties/property[not(@name)]' --type attr --name 'name' --value "atlassian.license.message" ${CONF_HOME}/confluence.cfg.xml

xmlstarlet ed --pf --inplace --subnode '//properties' --type elem --name 'property' --value "postgresql" -i '//properties/property[not(@name)]' --type attr --name 'name' --value "confluence.database.choice" ${CONF_HOME}/confluence.cfg.xml
xmlstarlet ed --pf --inplace --subnode '//properties' --type elem --name 'property' --value "database-type-standard" -i '//properties/property[not(@name)]' --type attr --name 'name' --value "confluence.database.connection.type" ${CONF_HOME}/confluence.cfg.xml
xmlstarlet ed --pf --inplace --subnode '//properties' --type elem --name 'property' --value "org.postgresql.Driver" -i '//properties/property[not(@name)]' --type attr --name 'name' --value "hibernate.connection.driver_class" ${CONF_HOME}/confluence.cfg.xml
xmlstarlet ed --pf --inplace --subnode '//properties' --type elem --name 'property' --value "verybigsecretrootpassword" -i '//properties/property[not(@name)]' --type attr --name 'name' --value "hibernate.connection.password" ${CONF_HOME}/confluence.cfg.xml
xmlstarlet ed --pf --inplace --subnode '//properties' --type elem --name 'property' --value "confluencedb" -i '//properties/property[not(@name)]' --type attr --name 'name' --value "hibernate.connection.username" ${CONF_HOME}/confluence.cfg.xml
xmlstarlet ed --pf --inplace --subnode '//properties' --type elem --name 'property' --value "jdbc:postgresql://db:5432/confluencedb" -i '//properties/property[not(@name)]' --type attr --name 'name' --value "hibernate.connection.url" ${CONF_HOME}/confluence.cfg.xml
xmlstarlet ed --pf --inplace --subnode '//properties' --type elem --name 'property' --value "com.atlassian.confluence.impl.hibernate.dialect.PostgreSQLDialect" -i '//properties/property[not(@name)]' --type attr --name 'name' --value "hibernate.dialect" ${CONF_HOME}/confluence.cfg.xml

# commong settings confluencese expects
xmlstarlet ed --pf --inplace --subnode '//properties' --type elem --name 'property' --value "" -i '//properties/property[not(@name)]' --type attr --name 'name' --value "confluence.webapp.context.path" ${CONF_HOME}/confluence.cfg.xml
xmlstarlet ed --pf --inplace --subnode '//properties' --type elem --name 'property' --value 'READ_WRITE' -i '//properties/property[not(@name)]' --type attr --name 'name' --value "access.mode" ${CONF_HOME}/confluence.cfg.xml
xmlstarlet ed --pf --inplace --subnode '//properties' --type elem --name 'property' --value '${localHome}/index' -i '//properties/property[not(@name)]' --type attr --name 'name' --value "lucene.index.dir" ${CONF_HOME}/confluence.cfg.xml
xmlstarlet ed --pf --inplace --subnode '//properties' --type elem --name 'property' --value "true" -i '//properties/property[not(@name)]' --type attr --name 'name' --value "synchrony.encryption.disabled" ${CONF_HOME}/confluence.cfg.xml
xmlstarlet ed --pf --inplace --subnode '//properties' --type elem --name 'property' --value "true" -i '//properties/property[not(@name)]' --type attr --name 'name' --value "synchrony.proxy.enabled" ${CONF_HOME}/confluence.cfg.xml
xmlstarlet ed --pf --inplace --subnode '//properties' --type elem --name 'property' --value '${localHome}/temp' -i '//properties/property[not(@name)]' --type attr --name 'name' --value "webwork.multipart.saveDir" ${CONF_HOME}/confluence.cfg.xml
xmlstarlet ed --pf --inplace --subnode '//properties' --type elem --name 'property' --value '${confluenceHome}/attachments' -i '//properties/property[not(@name)]' --type attr --name 'name' --value "attachments.dir" ${CONF_HOME}/confluence.cfg.xml
```

So now mount it in your docker-compose file for the confluence server

```yaml
volumes:
  - setup.sh:/docker-entrypoint.d/setup.sh
```

After starting the stack, just access your confluence instance once `http://localhost` and wait for about 1 minute.
The confluence database is setup with all the bits and pieces. Then you just select which type of profile ( blank db or example )
and create your admin account - that's it!


# Build The Image

    git clone https://github.com/EugenMayer/docker-image-atlassian-confluence
    cd docker-image-atlassian-confluence
    
For any version of Confluence >= 7.0.0

    export VERSION=7.1.2
    docker build . -t eugenmayer/confluence:# $VERSION --build-args CONFLUENCE_VERSION=$VERSION

For any version of Confluence <= 7.0.0, we neeed Java 8

    export VERSION=6.17.1
    docker build . -f Dockerfile_java8 -t eugenmayer/confluence:# $VERSION --build-args CONFLUENCE_VERSION=$VERSION


## Related Images

You may also like:

* [jira](https://github.com/EugenMayer/docker-image-atlassian-jira)
* [bitbucket](https://github.com/EugenMayer/docker-image-atlassian-bitbucket)
* [rancher catalog - corresponding catalog for confluence](https://github.com/EugenMayer/docker-rancher-extra-catalogs/tree/master/templates/confluence)
* [development - running this image for development with debugging](https://github.com/EugenMayer/docker-image-atlassian-confluence/tree/master/examples/debug)


