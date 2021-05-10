FROM amazonlinux:2

MAINTAINER KissIce Chu <i@kissice.cc>

ENV MONGODB_VERSION=latest

COPY run.sh /usr/local/bin/docker-entrypoint.sh

RUN set -euxo pipefail; \
    chmod +x /usr/local/bin/docker-entrypoint.sh; \
    # backwards compat
    ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh; \
    yum clean all; \
    yum makecache fast; \
    yum update -y; \
    yum install -y --setopt=protected_multilib=false \
        gzip \
        htop \
        shadow-utils \
        tar \
        tzdata \
        util-linux \
    ; \
    groupadd -r mongodb && useradd -r mongodb -g mongodb; \
    cd /tmp && mkdir -p mongodb-linux-x86_64; \
    curl -SLo- http://downloads.mongodb.org/linux/mongodb-linux-x86_64-amazon2-${MONGODB_VERSION}.tgz | tar xz -C ./mongodb-linux-x86_64 --strip-components 1; \
    mv mongodb-linux-x86_64/bin/mongo mongodb-linux-x86_64/bin/mongod /usr/local/bin/; \
    yum remove -y \
      gzip \
      shadow-utils \
      tar \
    ; \
    yum clean all; \
    rm -rf /tmp/*;

VOLUME [ "/data/db" ]
EXPOSE 27017

ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "mongod", "--bind_ip", "0.0.0.0" ]
