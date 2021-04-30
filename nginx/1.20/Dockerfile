FROM nginx:1.20-alpine AS builder

# nginx:alpine contains NGINX_VERSION environment variable, like so:
# ENV NGINX_VERSION 1.15.0

ENV BROTLI_VERSION=1.0.0rc \
    DAV_EXT_VERSION=3.0.0 \
    FANCYINDEX_VERSION=0.5.1 \
    HEADERS_MORE_VERSION=0.33

# For latest build deps, see https://github.com/nginxinc/docker-nginx/blob/master/mainline/alpine/Dockerfile
RUN set -ex; \
    apk add --no-cache --virtual .build-deps \
        gcc \
        libc-dev \
        make \
        openssl-dev \
        pcre-dev \
        zlib-dev \
        linux-headers \
        libxslt-dev \
        gd-dev \
        geoip-dev \
        perl-dev \
        libedit-dev \
        mercurial \
        bash \
        alpine-sdk \
        findutils

RUN set -exo pipefail; \
    cd /tmp; \
    git clone --branch v${BROTLI_VERSION} https://github.com/google/ngx_brotli.git; \
    git clone --branch v${DAV_EXT_VERSION} https://github.com/arut/nginx-dav-ext-module.git; \
    git clone --branch v${FANCYINDEX_VERSION} https://github.com/aperezdc/ngx-fancyindex.git; \
    git clone --branch v${HEADERS_MORE_VERSION} https://github.com/openresty/headers-more-nginx-module.git; \
    wget "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" \
        -O - | tar -xzf -

# Reuse same cli arguments as the nginx:alpine image used to build
RUN set -euxo pipefail; \
    CONFARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p'); \
    cd /tmp/ngx_brotli; \
    git submodule update --init; \
    cd /tmp/nginx-$NGINX_VERSION; \
    /bin/sh -c "./configure $CONFARGS --with-compat --add-dynamic-module=/tmp/ngx_brotli --add-dynamic-module=/tmp/nginx-dav-ext-module --add-dynamic-module=/tmp/ngx-fancyindex --add-dynamic-module=/tmp/headers-more-nginx-module"; \
    make modules

FROM nginx:1.20-alpine
# Extract the dynamic modules from the builder image
COPY --from=builder \
    /tmp/nginx-${NGINX_VERSION}/objs/*_module.so \
    /usr/lib/nginx/modules/
