# 第一阶段：构建阶段
ARG PHP_BUILD_VERSION=8.3-fpm-alpine

FROM --platform=$TARGETPLATFORM php:$PHP_BUILD_VERSION AS builder

# 安装构建依赖
RUN apk update && \
    apk add --no-cache --update linux-headers ${PHPIZE_DEPS} && \
    apk add \
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
        zlib-dev

# 配置和安装 PHP 扩展
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd && \
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
        zip

# 安装 event 扩展（https://pecl.php.net/package/event）
RUN pecl install event-3.1.4 && \
    docker-php-ext-enable --ini-name zz-event.ini event

# 下载应用程序代码
RUN git clone https://github.com/ledccn/iyuuplus-dev.git /usr/src/iyuuplus

# 第二阶段：生成最终的运行镜像
FROM --platform=$TARGETPLATFORM php:$PHP_BUILD_VERSION

# 安装运行时依赖项
RUN apk update && \
    apk add --no-cache \
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
        zlib

# 复制第一阶段中安装的 PHP 扩展
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/

# 拷贝应用程序代码
COPY --from=builder /usr/src/iyuuplus /var/www/iyuuplus

# 设置工作目录
WORKDIR /var/www/iyuuplus

# 设置数据卷
VOLUME /var/www/

# 设置启动命令为运行 start.php
CMD ["php", "start.php"]
