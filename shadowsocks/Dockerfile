FROM alpine AS builder

LABEL maintainer="Mr. Chu"

RUN set -eux && \
    apk upgrade --update && \
    # Install build dependencies
    apk add --no-cache \
        build-base \
        cmake \
        c-ares-dev \
        git \
        libcap \
        libev-dev \
        libsodium-dev \
        linux-headers \
        mbedtls3-dev \
        pcre2-dev \
    && \
    # Build shadowsocks-libev
    cd /tmp && \
    git clone https://github.com/shadowsocks/shadowsocks-libev.git && \
    cd shadowsocks-libev && \
    git submodule update --init --recursive && \
    cmake . -DCMAKE_INSTALL_PREFIX=/usr/local -DBUILD_TESTING=OFF -DWITH_STATIC=OFF -DCMAKE_BUILD_TYPE=Release && \
    make -j$(getconf _NPROCESSORS_ONLN) && \
    make install && \
    cd /usr/local/bin && \
    ls /usr/local/bin/ss-* | xargs -n1 setcap cap_net_bind_service+ep && \
    ls /usr/local/bin | grep -Ev 'ss-nat|ss-setup' | xargs strip

FROM alpine
LABEL maintainer="Mr. Chu"

ENV SERVER_ADDR=0.0.0.0
ENV SERVER_PORT=8388
ENV PASSWORD=
ENV METHOD=aes-256-gcm
ENV TIMEOUT=300
ENV DNS_ADDRS="8.8.8.8,8.8.4.4"
ENV TZ=UTC
ENV ARGS=

COPY --from=builder /tmp/shadowsocks-libev/docker/alpine/entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY --from=builder /usr/local/bin/ss-server /usr/local/bin/

RUN set -eux && \
    apk upgrade --update && \
    # Runtime dependencies setup
    apk add --no-cache \
        ca-certificates \
        rng-tools \
        tzdata \
        $(scanelf --needed --nobanner /usr/local/bin/ss-server \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | sort -u) \
    && \
    # Clean
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/*

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 8388

STOPSIGNAL SIGINT

CMD ["ss-server"]
