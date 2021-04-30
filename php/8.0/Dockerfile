FROM php:8.0-fpm-alpine

MAINTAINER KissIce Chu <i@kissice.cc>

RUN set -eux; \
    apk upgrade --update; \
    # install depends
    apk add --no-cache --virtual .build-deps \
        freetype-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libzip-dev \
    ; \
    # install core extensions
    docker-php-ext-configure gd --with-freetype --with-jpeg; \
    docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd; \
    docker-php-ext-install -j$(nproc) gd pdo_mysql zip; \
    apk del .build-deps; \
    apk add --update \
        freetype \
        libjpeg \
        libpng \
        libzip \
     ; \
    # clean
    rm -rf /var/cache/apk/*; \
    rm -rf /tmp/*