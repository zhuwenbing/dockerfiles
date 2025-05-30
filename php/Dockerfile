ARG BASE_TAG_NAME=8.0-fpm-alpine

FROM php:$BASE_TAG_NAME

LABEL maintainer="Mr. Chu"

RUN set -eux && \
    apk upgrade --update && \
    # install depends
    apk add --no-cache --virtual .build-deps \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libpq-dev \
        libzip-dev \
    && \
    # install core extensions
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd && \
    docker-php-ext-install -j$(nproc) gd pdo_mysql pdo_pgsql zip && \
    apk del .build-deps && \
    apk add --update \
        freetype \
        libjpeg \
        libpng \
        libpq \
        libzip \
        fcgi \
    && \
    # clean
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/* && \
    # enable php fpm status page
    echo -e "pm.status_path = /status\naccess.log = /dev/null" >> /usr/local/etc/php-fpm.d/zz-docker.conf && \
    # install healthcheck
    wget -O /usr/local/bin/php-fpm-healthcheck https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck && \
    chmod +x /usr/local/bin/php-fpm-healthcheck

HEALTHCHECK --timeout=3s CMD php-fpm-healthcheck || exit 1
