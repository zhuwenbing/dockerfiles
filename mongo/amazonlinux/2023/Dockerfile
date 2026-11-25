FROM amazonlinux:2023

LABEL maintainer="Mr. Chu"

ARG TARGETARCH

# MongoDB only ships Amazon Linux 2023 packages for 7.0 and above.
ARG MONGO_BUILD_VERSION=9.0

# Optional exact version, e.g. 9.0.8. Leave empty to resolve the latest patch release.
ARG MONGO_VERSION=""

ENV GOSU_VERSION=1.20 \
    MONGOSH_VERSION=2.14.3

COPY run.sh /usr/local/bin/docker-entrypoint.sh
COPY check.sh /usr/local/bin/docker-healthcheck.sh

# MongoDB no longer serves "-latest" archives, so the exact patch version is
# resolved from the download API first, with pinned fallbacks for every series.
# MONGODB_VERSION must not share the ARG name, otherwise the build frontend
# replaces ${MONGO_VERSION} with the ARG value before the shell ever runs.
RUN set -euxo pipefail && \
    MONGODB_VERSION="${MONGO_VERSION}" && \
    if [ -z "${MONGODB_VERSION}" ]; then \
      MONGODB_VERSION="$(curl -fsSL https://downloads.mongodb.org/current.json | grep -oE '"version": *"[0-9]+\.[0-9]+\.[0-9]+"' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | grep "^${MONGO_BUILD_VERSION}\." | sort -V | tail -n 1)" || MONGODB_VERSION=""; \
    fi; \
    if [ -z "${MONGODB_VERSION}" ]; then \
      case "${MONGO_BUILD_VERSION}" in \
        7.0) MONGODB_VERSION="7.0.48" ;; \
        8.0) MONGODB_VERSION="8.0.38" ;; \
        9.0) MONGODB_VERSION="9.0.8" ;; \
      esac; \
    fi; \
    echo "MongoDB version: ${MONGODB_VERSION}" && \
    test -n "${MONGODB_VERSION}" && \
    chmod +x /usr/local/bin/docker-entrypoint.sh && \
    chmod +x /usr/local/bin/docker-healthcheck.sh && \
    ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh && \
    ln -s /usr/local/bin/docker-healthcheck.sh /healthcheck.sh && \
    dnf clean all && \
    dnf makecache && \
    dnf update -y && \
    dnf swap -y gnupg2-minimal gnupg2 && \
    gpg --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${TARGETARCH}" && \
    curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/${GOSU_VERSION}/gosu-${TARGETARCH}.asc" && \
    gpg --verify /usr/local/bin/gosu.asc && \
    rm /usr/local/bin/gosu.asc && \
    gpgconf --kill gpg-agent && \
    rm -rf /root/.gnupg/ && \
    chmod +x /usr/local/bin/gosu && \
    gosu --version && \
    gosu nobody true && \
    dnf install -y --setopt=protected_multilib=false \
        tar \
        tzdata \
    && \
    groupadd -r mongodb && useradd -r mongodb -g mongodb && \
    ARCHITECTURE= && \
    if [ "$TARGETARCH" = "amd64" ] ; then ARCHITECTURE="x86_64" ; else ARCHITECTURE="aarch64" ; fi && \
    cd /tmp && \
    mkdir -p mongodb-linux-${ARCHITECTURE} && \
    curl -fsSLo mongodb.tgz "https://fastdl.mongodb.org/linux/mongodb-linux-${ARCHITECTURE}-amazon2023-${MONGODB_VERSION}.tgz" && \
    tar xzf mongodb.tgz -C ./mongodb-linux-${ARCHITECTURE} --strip-components 1 && \
    cd mongodb-linux-${ARCHITECTURE}/bin && \
    mv mongod /usr/local/bin/ && \
    if [ -f mongo ]; then \
      mv mongo /usr/local/bin/; \
    else \
      curl -fsSL -o mongodb-mongosh-${MONGOSH_VERSION}.${ARCHITECTURE}.rpm https://github.com/mongodb-js/mongosh/releases/download/v${MONGOSH_VERSION}/mongodb-mongosh-${MONGOSH_VERSION}.${ARCHITECTURE}.rpm && \
      dnf localinstall -y mongodb-mongosh-${MONGOSH_VERSION}.${ARCHITECTURE}.rpm; \
    fi && \
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
