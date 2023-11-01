FROM --platform=$TARGETPLATFORM amazonlinux:2023

LABEL maintainer="Mr. Chu"

ARG TARGETARCH

ARG MONGO_BUILD_VERSION=4.4

ENV MONGODB_VERSION=$MONGO_BUILD_VERSION-latest \
    GOSU_VERSION=1.16

COPY <<EOF /etc/yum.repos.d/mongodb-org-$MONGO_BUILD_VERSION.repo
[mongodb-org-${MONGO_BUILD_VERSION}]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/amazon/2023/mongodb-org/$MONGO_BUILD_VERSION/\$basearch/
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
    dnf clean all; \
    dnf makecache timer; \
    dnf update -y; \
    dnf install -y --setopt=protected_multilib=false --allowerasing \
        dirmngr \
        gzip \
        shadow-utils \
        tar \
        tzdata \
    ; \
    gpg --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
    curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${TARGETARCH}"; \
    curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${TARGETARCH}.asc"; \
    gpg --verify /usr/local/bin/gosu.asc; \
    rm /usr/local/bin/gosu.asc; \
    rm -rf /root/.gnupg/; \
    chmod +x /usr/local/bin/gosu; \
    # Verify that the binary works
    gosu --version; \
    gosu nobody true; \
    # Install mongodb.
    groupadd -r mongodb && useradd -r mongodb -g mongodb; \
    ARCHITECTURE=; \
    if [ "$TARGETARCH" = "amd64" ] ; then ARCHITECTURE="x86_64" ; else ARCHITECTURE="aarch64" ; fi; \
    cd /tmp && mkdir -p mongodb-linux-${ARCHITECTURE}; \
    curl -SLo- http://downloads.mongodb.org/linux/mongodb-linux-${ARCHITECTURE}-amazon2023-v${MONGODB_VERSION}.tgz | tar xz -C ./mongodb-linux-${ARCHITECTURE} --strip-components 1; \
    cd mongodb-linux-${ARCHITECTURE}/bin; \
    mv mongod /usr/local/bin/; \
    [ -f mongo ] || dnf install -y mongodb-mongosh; \
    [ -f mongo ] && mv mongo /usr/local/bin/; \
    dnf remove -y \
      dirmngr \
      gzip \
      shadow-utils \
      tar \
    ; \
    dnf clean all; \
    rm -rf /tmp/*

VOLUME [ "/data/db" ]
EXPOSE 27017

ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "mongod", "--bind_ip", "0.0.0.0" ]

HEALTHCHECK --timeout=3s CMD [ "docker-healthcheck.sh" ]
