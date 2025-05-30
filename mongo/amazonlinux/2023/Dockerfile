FROM amazonlinux:2023

LABEL maintainer="Mr. Chu"

ARG TARGETARCH

# According to the compressed package I can download, MongoDB only supports Amazon Linux 2023 starting from version 5.0.
ARG MONGO_BUILD_VERSION=5.0

ENV MONGODB_VERSION=$MONGO_BUILD_VERSION-latest \
    GOSU_VERSION=1.17 \
    MONGOSH_VERSION=2.4.2

COPY run.sh /usr/local/bin/docker-entrypoint.sh
COPY check.sh /usr/local/bin/docker-healthcheck.sh

RUN set -euxo pipefail && \
    chmod +x /usr/local/bin/docker-entrypoint.sh && \
    chmod +x /usr/local/bin/docker-healthcheck.sh && \
    # backwards compat
    ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh && \
    ln -s /usr/local/bin/docker-healthcheck.sh /healthcheck.sh && \
    # Update
    dnf clean all && \
    dnf makecache && \
    dnf update -y && \
    # gpg: keyserver receive failed: No dirmngr -> https://github.com/amazonlinux/amazon-linux-2023/issues/243
    dnf swap -y gnupg2-minimal gnupg2 && \
    # Install gosu.  https://github.com/tianon/gosu
    gpg --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${TARGETARCH}" && \
    curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${TARGETARCH}.asc" && \
    gpg --verify /usr/local/bin/gosu.asc && \
    rm /usr/local/bin/gosu.asc && \
    gpgconf --kill gpg-agent && \
    rm -r /root/.gnupg/ && \
    chmod +x /usr/local/bin/gosu && \
    # Verify that the binary works
    gosu --version && \
    gosu nobody true && \
    # Install mongodb.
    dnf install -y --setopt=protected_multilib=false \
        tar \
        tzdata \
    && \
    groupadd -r mongodb && useradd -r mongodb -g mongodb && \
    ARCHITECTURE= && \
    if [ "$TARGETARCH" = "amd64" ] ; then ARCHITECTURE="x86_64" ; else ARCHITECTURE="aarch64" ; fi && \
    cd /tmp && mkdir -p mongodb-linux-${ARCHITECTURE} && \
    curl -SLo- https://fastdl.mongodb.org/linux/mongodb-linux-${ARCHITECTURE}-amazon2023-v${MONGODB_VERSION}.tgz | tar xz -C ./mongodb-linux-${ARCHITECTURE} --strip-components 1 && \
    cd mongodb-linux-${ARCHITECTURE}/bin && \
    mv mongod /usr/local/bin/ && \
    if [ -f mongo ]; then \
      mv mongo /usr/local/bin/; \
    else \
      curl -SL -o mongodb-mongosh-${MONGOSH_VERSION}.${ARCHITECTURE}.rpm https://github.com/mongodb-js/mongosh/releases/download/v${MONGOSH_VERSION}/mongodb-mongosh-${MONGOSH_VERSION}.${ARCHITECTURE}.rpm && \
      dnf localinstall -y mongodb-mongosh-${MONGOSH_VERSION}.${ARCHITECTURE}.rpm; \
    fi && \
    dnf remove -y \
      tar \
    && \
    dnf clean all && \
    rm -rf /tmp/*

VOLUME [ "/data/db" ]
EXPOSE 27017

ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "mongod", "--bind_ip", "0.0.0.0" ]

HEALTHCHECK --timeout=3s CMD [ "docker-healthcheck.sh" ]
