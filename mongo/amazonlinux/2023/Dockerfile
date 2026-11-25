FROM amazonlinux:2023

LABEL maintainer="Mr. Chu"

ARG TARGETARCH

# According to the compressed package I can download, MongoDB only supports Amazon Linux 2023 starting from version 7.0.
ARG MONGO_BUILD_VERSION=9.0

# Optional exact version, e.g. MONGO_VERSION=9.0.8.
# Leave empty to resolve the latest patch release of MONGO_BUILD_VERSION automatically.
ARG MONGO_VERSION=""

ENV GOSU_VERSION=1.20 \
    MONGOSH_VERSION=2.14.3

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
    # Install mongodb dependencies.
    dnf install -y --setopt=protected_multilib=false \
        tar \
        tzdata \
    && \
    groupadd -r mongodb && useradd -r mongodb -g mongodb && \
    ARCHITECTURE= && \
    if [ "$TARGETARCH" = "amd64" ] ; then ARCHITECTURE="x86_64" ; else ARCHITECTURE="aarch64" ; fi && \
    # MongoDB no longer serves "-latest" archives, so resolve the exact patch version first.
    if [ -z "${MONGO_VERSION}" ]; then \
      MONGO_VERSION="$(curl -fsSL https://downloads.mongodb.org/current.json \
        | grep -oE '"version": *"[0-9]+\.[0-9]+\.[0-9]+"' \
        | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' \
        | grep "^${MONGO_BUILD_VERSION}\." \
        | sort -V | tail -n 1)"; \
      # Series that are no longer listed on the download page are pinned here.
      case "${MONGO_BUILD_VERSION}" in \
        7.0) MONGO_VERSION="${MONGO_VERSION:-7.0.48}" ;; \
        8.0) MONGO_VERSION="${MONGO_VERSION:-8.0.38}" ;; \
        9.0) MONGO_VERSION="${MONGO_VERSION:-9.0.8}" ;; \
      esac; \
    fi; \
    if [ -z "${MONGO_VERSION}" ]; then echo "Unsupported MONGO_BUILD_VERSION: ${MONGO_BUILD_VERSION}" >&2; exit 1; fi; \
    cd /tmp && \
    mkdir -p mongodb-linux-${ARCHITECTURE} && \
    curl -fsSLo mongodb.tgz "https://fastdl.mongodb.org/linux/mongodb-linux-${ARCHITECTURE}-amazon2023-${MONGO_VERSION}.tgz" && \
    tar xzf mongodb.tgz -C ./mongodb-linux-${ARCHITECTURE} --strip-components 1 && \
    cd mongodb-linux-${ARCHITECTURE}/bin && \
    mv mongod /usr/local/bin/ && \
    if [ -f mongo ]; then \
      mv mongo /usr/local/bin/; \
    else \
      curl -fsSL -o mongodb-mongosh-${MONGOSH_VERSION}.${ARCHITECTURE}.rpm https://github.com/mongodb-js/mongosh/releases/download/v${MONGOSH_VERSION}/mongodb-mongosh-${MONGOSH_VERSION}.${ARCHITECTURE}.rpm && \
      dnf localinstall -y mongodb-mongosh-${MONGOSH_VERSION}.${ARCHITECTURE}.rpm; \
    fi && \
    # Make sure the binary actually runs on this image
    mongod --version && \
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
