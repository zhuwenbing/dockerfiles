ARG PHP_VERSION=8.3

ARG PECL_EVENT_VERSION=3.1.4

FROM --platform=$TARGETPLATFORM php:$PHP_VERSION-fpm-alpine

LABEL maintainer="Mr. Chu"

RUN set -eux && \
    apk upgrade --update && \
    # 安装构建依赖
    apk add --no-cache --virtual .build-deps \
        ${PHPIZE_DEPS} \
        linux-headers \
        curl-dev \
        freetype-dev \
        git \
        libevent-dev \
        libjpeg-turbo-dev \
        libpng-dev \
        libsodium-dev \
        libwebp-dev \
        libxml2-dev \
        libzip-dev \
        oniguruma-dev \
        sqlite-dev \
        zlib-dev \
    && \
    # 配置和安装 PHP 扩展
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd && \
    docker-php-ext-configure pcntl --enable-pcntl && \
    docker-php-ext-install -j$(nproc) \
        bz2 \
        bcmath \
        curl \
        dom \
        fileinfo \
        gd \
        mbstring \
        opcache \
        pcntl \
        pdo \
        pdo_mysql \
        pdo_sqlite \
        phar \
        posix \
        simplexml \
        sockets \
        sodium \
        xml \
        zip \
    && \
    # 安装 event 扩展（https://pecl.php.net/package/event）
    pecl install event-${PECL_EVENT_VERSION} && \
    docker-php-ext-enable --ini-name zz-event.ini event && \
    # 下载应用程序代码
    git clone https://github.com/ledccn/iyuuplus-dev.git /var/www/iyuuplus && \
    # 移除构建依赖
    apk del .build-deps && \
    # 安装运行时依赖项
    apk add --no-cache --update \
        freetype \
        libevent \
        libjpeg \
        libpng \
        libsodium \
        libwebp \
        libxml2 \
        libzip \
        oniguruma \
        sqlite \
        zlib \
    && \
    # 清理apk缓存和临时数据
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/*

# 设置工作目录
WORKDIR /var/www/iyuuplus

# 设置数据卷
VOLUME /var/www/iyuuplus

# 设置启动命令为运行 start.php
CMD ["php", "start.php", "start"]
