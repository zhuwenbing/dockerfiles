ARG VERSION=stable

FROM nginx:${VERSION}-alpine-slim AS builder

# nginx:xxx-alpine contains NGINX_VERSION environment variable, like so:
# ENV NGINX_VERSION 1.23.2

# ENV BROTLI_VERSION=1.0.0rc \
#    HEADERS_MORE_VERSION=0.33
ENV HEADERS_MORE_VERSION=0.38 \
    GEOIP2_VERSION=3.4

# For latest build deps, see https://github.com/nginxinc/docker-nginx/blob/master/mainline/alpine/Dockerfile
RUN set -ex && \
    apk add --no-cache --virtual .build-deps \
        gcc \
        libc-dev \
        make \
        openssl-dev \
        pcre2-dev \
        zlib-dev \
        linux-headers \
        libxslt-dev \
        gd-dev \
        geoip-dev \
        libedit-dev \
        bash \
        alpine-sdk \
        findutils \
        libmaxminddb-dev

RUN set -exo pipefail && \
    cd /tmp && \
    # git clone --branch v${BROTLI_VERSION} https://github.com/google/ngx_brotli.git && \
    git clone https://github.com/google/ngx_brotli.git && \
    git clone --branch v${HEADERS_MORE_VERSION} https://github.com/openresty/headers-more-nginx-module.git && \
    git clone --branch ${GEOIP2_VERSION} https://github.com/leev/ngx_http_geoip2_module.git && \
    wget "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" \
        -O - | tar -xzf -

# Reuse same cli arguments as the nginx:alpine image used to build
RUN set -euxo pipefail && \
    CONFARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p') && \
    cd /tmp/ngx_brotli && \
    git submodule update --init && \
    cd /tmp/nginx-${NGINX_VERSION} && \
    /bin/sh -c "./configure ${CONFARGS} --with-compat --add-dynamic-module=/tmp/ngx_brotli --add-dynamic-module=/tmp/headers-more-nginx-module --add-dynamic-module=/tmp/ngx_http_geoip2_module" && \
    make modules

FROM nginx:${VERSION}-alpine-slim
# Extract the dynamic modules from the builder image
COPY --from=builder \
    /tmp/nginx-${NGINX_VERSION}/objs/*_module.so \
    /usr/lib/nginx/modules/
RUN apk add --no-cache libmaxminddb && \
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/*
