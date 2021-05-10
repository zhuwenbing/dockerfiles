FROM alpine

MAINTAINER KissIce Chu <i@kissice.cc>

ENV MONGODB_VERSION=3.6-latest \
    GLIBC_VERSION=2.33-r0 \
    GOSU_VERSION=1.12

COPY run.sh /usr/local/bin/docker-entrypoint.sh

RUN set -euxo pipefail; \
    chmod +x /usr/local/bin/docker-entrypoint.sh; \
    # backwards compat
    ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh; \
    apk update; \
    if ! command -v ps > /dev/null; then \
      apk add --no-cache procps; \
    fi; \
    # Install gosu.  https://github.com/tianon/gosu
    apk add --no-cache --virtual .gosu-deps \
        ca-certificates \
        dpkg \
        gnupg \
    ; \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
    # verify the signature
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
    command -v gpgconf && gpgconf --kill all || :; \
    rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
    # clean up fetch dependencies
    apk del --no-network .gosu-deps; \
    chmod +x /usr/local/bin/gosu; \
    # verify that the binary works
    gosu --version; \
    gosu nobody true; \
    # Install mongodb.
    apk add --no-cache \
        curl \
        libgcc \
        libstdc++ \
        tzdata \
    ; \
    addgroup -S mongodb && adduser -S mongodb -G mongodb; \
    cd /tmp; \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub; \
    curl -SLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk; \
    #apk add --allow-untrusted glibc-${GLIBC_VERSION}.apk; \
    apk add glibc-${GLIBC_VERSION}.apk; \
    # Eliminate '/usr/glibc-compat/lib/ld-linux-x86-64.so.2 is not a symbolic link' tips.
    mv /usr/glibc-compat/lib/ld-linux-x86-64.so.2 /usr/glibc-compat/lib/ld-linux-x86-64.so; \
    ln -s /usr/glibc-compat/lib/ld-linux-x86-64.so /usr/glibc-compat/lib/ld-linux-x86-64.so.2; \
    curl -SLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk; \
    #apk add --allow-untrusted glibc-bin-${GLIBC_VERSION}.apk; \
    apk add glibc-bin-${GLIBC_VERSION}.apk; \
    /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib; \
    mkdir -p mongodb-linux-x86_64; \
    curl -SLo- http://downloads.mongodb.org/linux/mongodb-linux-x86_64-v${MONGODB_VERSION}.tgz | tar xz -C ./mongodb-linux-x86_64 --strip-components 1; \
    mv mongodb-linux-x86_64/bin/mongo mongodb-linux-x86_64/bin/mongod /usr/local/bin/; \
    apk del curl; \
    rm -rf /var/cache/apk/*; \
    rm -rf /tmp/*

VOLUME [ "/data/db" ]
EXPOSE 27017

ENTRYPOINT [ "docker-entrypoint.sh" ]
CMD [ "mongod", "--bind_ip", "0.0.0.0" ]