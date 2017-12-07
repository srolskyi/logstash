FROM centos:7
LABEL maintainer "Vladimir Goldetsky <goldetsky@gmail.com>"

ENV UUID 449
ENV GUID 449
ENV LOGSTASH_VERSION 5.5.1
ENV PATH /usr/share/logstash/bin:/sbin:$PATH
ENV DOWNLOAD_URL "https://artifacts.elastic.co/downloads/logstash"
ENV TARBALL "$DOWNLOAD_URL/logstash-${LOGSTASH_VERSION}.tar.gz"

RUN groupadd --gid ${GUID} logstash && \
    useradd --uid ${UUID} --gid ${GUID} \
      --home-dir /usr/share/logstash --no-create-home \
      logstash
USER logstash

RUN yum update -y \
  && yum install -y java-1.8.0-openjdk openssl wget \
  && yum clean all \
  && cd /tmp \
  && wget --progress=bar:force -O logstash.tar.gz "$TARBALL"; \
  tar -xzf logstash.tar.gz \
  && mv logstash-$LOGSTASH_VERSION /usr/share/logstash \
  && rm -rf /tmp/*

WORKDIR /usr/share/logstash

ADD config/log4j2.properties config/
RUN chown -R logstash:logstash /usr/share/logstash/

# Ensure Logstash gets a UTF-8 locale by default.
ENV LANG='en_US.UTF-8' LC_ALL='en_US.UTF-8'

# Place the startup wrapper script.
ADD bin/docker-entrypoint /usr/local/bin/
RUN chmod 0755 /usr/local/bin/docker-entrypoint

ADD env2yaml/env2yaml /usr/local/bin/

EXPOSE 9100

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]