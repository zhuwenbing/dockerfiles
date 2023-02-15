FROM amazonlinux:2

LABEL maintainer="Mr. Chu"

ARG MONGO_BUILD_VERSION=4.2

ENV MONGODB_VERSION=$MONGO_BUILD_VERSION-latest \
    GOSU_VERSION=1.16

COPY <<EOF /etc/yum.repos.d/mongodb-org-$MONGO_BUILD_VERSION.repo
[mongodb-org-${MONGO_BUILD_VERSION}]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/\$releasever/mongodb-org/$MONGO_BUILD_VERSION/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-$MONGO_BUILD_VERSION.asc
EOF

COPY run.sh /usr/local/bin/docker-entrypoint.sh
COPY check.sh /usr/local/bin/docker-healthcheck.sh

RUN set -euxo pipefail; \
    chmod +x /usr/local/bin/docker-entrypoint.sh; \
    chmod +x /usr/local/bin/docker-healthcheck.sh; \
    # backwards compat
    ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh; \
    ln -s /usr/local/bin/docker-healthcheck.sh /healthcheck.sh; \
    # Install gosu.  https://github.com/tianon/gosu
    gpg --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
    curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64"; \
    curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-amd64.asc"; \
    gpg --verify /usr/local/bin/gosu.asc; \
    rm /usr/local/bin/gosu.asc; \
    rm -r /root/.gnupg/; \
    chmod +x /usr/local/bin/gosu; \
    # Verify that the binary works
    gosu --version; \
    gosu nobody true; \
    # Install mongodb.
    yum clean all; \
    yum makecache fast; \
    yum update -y; \
    yum install -y --setopt=protected_multilib=false \
        gzip \
        mongodb-mongosh \
        shadow-utils \
        tar \
        tzdata \
    ; \
    groupadd -r mongodb && useradd -r mongodb -g mongodb; \
    cd /tmp && mkdir -p mongodb-linux-x86_64; \
    curl -SLo- http://downloads.mongodb.org/linux/mongodb-linux-x86_64-amazon2-v${MONGODB_VERSION}.tgz | tar xz -C ./mongodb-linux-x86_64 --strip-components 1; \
    mv mongodb-linux-x86_64/bin/* /usr/local/bin/; \
    yum remove -y \
      gzip \
      shadow-utils \
      tar \
    ; \
    yum clean all; \
    rm -rf /tmp/*

VOLUME [ "/data/db" ]
EXPOSE 27017

ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "mongod", "--bind_ip", "0.0.0.0" ]

HEALTHCHECK --timeout=3s CMD [ "docker-healthcheck.sh" ]
