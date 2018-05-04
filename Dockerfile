FROM centos:7

MAINTAINER "Vladimir Goldetsky <goldetsky@gmail.com>"

ENV LOGSTASH_VERSION 6.2.0
ENV UUID 449
ENV GUID 449
ENV ELASTIC_CONTAINER true
ENV PATH=/usr/share/logstash/bin:$PATH
ENV JAVA_HOME /usr/lib/jvm/jre-1.8.0-openjdk

RUN yum update -y && yum install -y java-1.8.0-openjdk-devel wget which ruby git && yum clean all

RUN groupadd --gid ${GUID} logstash && \
    adduser --uid ${UUID} --gid ${GUID} --home-dir /usr/share/logstash --no-create-home logstash

WORKDIR /usr/share/logstash

RUN wget --progress=bar:force https://artifacts.elastic.co/downloads/logstash/logstash-${LOGSTASH_VERSION}.tar.gz && \
    tar zxf logstash-${LOGSTASH_VERSION}.tar.gz && \
    chown -R logstash:logstash logstash-${LOGSTASH_VERSION} && \
    mv logstash-${LOGSTASH_VERSION}/* . && \
    rmdir logstash-${LOGSTASH_VERSION} && \
    rm logstash-${LOGSTASH_VERSION}.tar.gz 

ADD config/log4j2.properties config/
#ADD pipeline/default.conf pipeline/logstash.conf
#RUN chown --recursive logstash:logstash config/ pipeline/

ENV LANG='en_US.UTF-8' LC_ALL='en_US.UTF-8'

# Place the startup wrapper script.
#ADD bin/docker-entrypoint /usr/local/bin/
#RUN chmod 0755 /usr/local/bin/docker-entrypoint
ADD bin/logstash-docker /usr/local/bin/
RUN chmod 0755 /usr/local/bin/logstash-docker

USER root

RUN cd /usr/share/logstash && logstash-plugin install logstash-filter-translate logstash-filter-json_encode logstash-filter-prune x-pack

EXPOSE 9100 9600 5044

#ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]

CMD [ "/bin/bash", "/usr/local/bin/logstash-docker" ]


