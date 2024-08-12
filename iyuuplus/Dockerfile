ARG PHP_VERSION=8.3

FROM php:$PHP_VERSION-alpine

LABEL maintainer="Mr. Chu"

ARG PECL_EVENT_VERSION=3.1.4

RUN set -eux && \
    apk upgrade --update && \
    # 安装构建依赖
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
    # 配置和安装 PHP 扩展
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
    # 安装 event 扩展（https://pecl.php.net/package/event）
    pecl install event-${PECL_EVENT_VERSION} && \
    docker-php-ext-enable --ini-name zz-event.ini event && \
    # 移除构建依赖
    apk del .build-deps && \
    # 安装运行时依赖项
    apk add --no-cache --update \
        freetype \
        git \
        libevent \
        libjpeg \
        libpng \
        libwebp \
        libzip \
        zlib \
    && \
    # 解决 git 命令可能无法在以下目录中执行 pull 等操作问题
    git config --global --add safe.directory /var/www/html && \
    # 清理apk缓存和临时数据
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/*

# 设置工作目录
WORKDIR /var/www/html
