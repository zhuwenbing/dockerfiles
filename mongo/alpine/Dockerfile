FROM alpine

LABEL maintainer="Mr. Chu"

ARG MONGO_BUILD_VERSION=4.0

ENV MONGODB_VERSION=$MONGO_BUILD_VERSION-latest \
    GOSU_VERSION=1.17

COPY run.sh /usr/local/bin/docker-entrypoint.sh
COPY check.sh /usr/local/bin/docker-healthcheck.sh

RUN set -euxo pipefail && \
    chmod +x /usr/local/bin/docker-entrypoint.sh && \
    chmod +x /usr/local/bin/docker-healthcheck.sh && \
    # backwards compat
    ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh && \
    ln -s /usr/local/bin/docker-healthcheck.sh /healthcheck.sh && \
    # Update and install dependences
    apk update && \
    if ! command -v ps > /dev/null; then \
      apk add --no-cache procps; \
    fi && \
    apk add --no-cache \
        libgcc \
        libstdc++ \
        tzdata \
    && \
    # Install gosu.  https://github.com/tianon/gosu
    apk add --no-cache --virtual .gosu-deps \
        ca-certificates \
        dpkg \
        gnupg \
    && \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" && \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" && \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" && \
    # verify the signature
    export GNUPGHOME="$(mktemp -d)" && \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu && \
    command -v gpgconf && gpgconf --kill all || : && \
    rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc && \
    # clean up fetch dependencies
    apk del --no-network .gosu-deps && \
    chmod +x /usr/local/bin/gosu && \
    # verify that the binary works
    gosu --version && \
    gosu nobody true && \
    cd /tmp && \
    # Install glibc
    echo 'https://alpine.sev.monster/edge/testing' | tee -a /etc/apk/repositories && \
    wget https://alpine.sev.monster/edge/testing/x86_64/sevmonster-keys-1-r0.apk && \
    apk add --allow-untrusted ./sevmonster-keys-1-r0.apk && \
    apk update && \
    apk del gcompat && \
    apk add --force-overwrite glibc && \
    apk add glibc-bin && \
    # Install mongodb.
    addgroup -S mongodb && adduser -S mongodb -G mongodb && \
    mkdir -p mongodb-linux-x86_64 && \
    apk add --no-cache curl && \
    curl -SLo- https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-v${MONGODB_VERSION}.tgz | tar xz -C ./mongodb-linux-x86_64 --strip-components 1 && \
    apk del curl && \
    mv mongodb-linux-x86_64/bin/mongo mongodb-linux-x86_64/bin/mongod /usr/local/bin/ && \
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/*

VOLUME [ "/data/db" ]
EXPOSE 27017

ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "mongod", "--bind_ip", "0.0.0.0" ]

HEALTHCHECK --timeout=3s CMD [ "docker-healthcheck.sh" ]
