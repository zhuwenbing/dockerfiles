ARG BASE_TAG_NAME=8.3-alpine

FROM php:$BASE_TAG_NAME

LABEL maintainer="Mr. Chu"

COPY entrypoint.sh /usr/local/bin/docker-entrypoint.sh

ARG PECL_EVENT_VERSION=3.1.4

RUN set -eux && \
    apk upgrade --update && \
    # Install build dependencies
    apk add --no-cache --virtual .build-deps \
        ${PHPIZE_DEPS} \
        linux-headers \
        freetype-dev \
        libevent-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libwebp-dev \
        libxml2-dev \
        libzip-dev \
        openssl-dev \
    && \
    # Configure and install PHP extensions
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd && \
    docker-php-ext-configure pcntl --enable-pcntl && \
    docker-php-ext-install -j$(nproc) \
        bz2 \
        bcmath \
        dom \
        fileinfo \
        gd \
        opcache \
        pcntl \
        pdo \
        pdo_mysql \
        phar \
        posix \
        simplexml \
        sockets \
        xml \
        zip \
    && \
    # Install event extension (https://pecl.php.net/package/event)
    pecl install event-${PECL_EVENT_VERSION} && \
    docker-php-ext-enable --ini-name zz-event.ini event && \
    # Remove build dependencies
    apk del .build-deps && \
    # Install runtime dependencies
    apk add --no-cache \
        freetype \
        git \
        libevent \
        libjpeg \
        libpng \
        libwebp \
        libzip \
        zlib \
    && \
    chmod +x /usr/local/bin/docker-entrypoint.sh && \
    # Backwards compat
    ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh && \
    # Clean
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/*

ENTRYPOINT [ "docker-entrypoint.sh" ]
