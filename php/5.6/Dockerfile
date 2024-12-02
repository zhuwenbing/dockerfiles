FROM php:5.6-fpm-alpine

LABEL maintainer="Mr. Chu"

RUN set -eux && \
    apk upgrade --update && \
    # install depends
    apk add --no-cache --virtual .build-deps \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libzip-dev \
        postgresql-dev \
    && \
    # install core extensions
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ && \
    docker-php-ext-configure zip --with-libzip && \
    # -j$(nproc)
    docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) gd zip mysqli pdo pdo_mysql mysql pdo_pgsql pgsql && \
    apk del .build-deps && \
    apk add --update \
        freetype \
        libjpeg \
        libpng \
        libzip \
        fcgi \
        postgresql \
    && \
    # clean
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/* && \
    # enable php fpm status page
    echo "pm.status_path = /status" >> /usr/local/etc/php-fpm.d/zz-docker.conf && \
    # install healthcheck
    wget -O /usr/local/bin/php-fpm-healthcheck https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck && \
    chmod +x /usr/local/bin/php-fpm-healthcheck

HEALTHCHECK --timeout=3s CMD php-fpm-healthcheck || exit 1
