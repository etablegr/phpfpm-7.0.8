# Forked and modified from https://hub.docker.com/r/supergramm/phpfpm-7.0.8/dockerfile
FROM php:7.0.8-fpm

MAINTAINER supergramm/phpfpm7
MAINTAINER Desyllas Dimitrios <d.desyllas@e-table.gr><pcmagas@disroot.org>

ENV DOCKER_UID=1000 \
    DOCKER_GID=1000 \
    XDEBUG_CONF_FILE=/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    XDEBUG_HOST="" \
    XDEBUG_IDE_KEY="" \
    XDEBUG_PORT=9000 \
    XDEBUG_DBGP=FALSE

RUN echo "Europe/Athens" > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata

RUN buildDeps=" \
    zlib1g-dev \
    libmemcached-dev \
    libmcrypt-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libzip-dev \
    libpq-dev \
    libxml2-dev \
    libpng12-dev \
    git  \
    net-tools \
    "; \
    set -x \
    && apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
    && pecl install redis \
    && docker-php-ext-install \
    mcrypt \
    mbstring \
    iconv \
    bcmath \
    opcache \
    mysqli \
    pgsql \
    zip \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    calendar \
    soap \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd \
    && docker-php-ext-enable redis

# Install memcached extension for php 7
RUN curl -L -o /tmp/memcached.tar.gz "https://github.com/php-memcached-dev/php-memcached/archive/php7.tar.gz" \
    && mkdir -p memcached \
    && tar -C memcached -zxvf /tmp/memcached.tar.gz --strip 1 \
    && ( \
    cd memcached \
    && phpize \
    && ./configure \
    && make -j$(nproc) \
    && make install \
    ) \
    && rm -r memcached \
    && rm /tmp/memcached.tar.gz \
    && docker-php-ext-enable memcached

RUN echo "Installing xdebug" &&\
    pecl install xdebug  &&\
    docker-php-ext-enable xdebug &&\
    echo "Configuring Xdebug \n" &&\
    echo "xdebug.remote_enable=1" >> ${XDEBUG_CONF_FILE} &&\
    echo "xdebug.max_nesting_level = 1000" >> ${XDEBUG_CONF_FILE} &&\
    echo "xdebug.remote_mode=req" >> ${XDEBUG_CONF_FILE} &&\
    echo "xdebug.remote_log=xdebug.log" >> ${XDEBUG_CONF_FILE} &&\
    cp ${XDEBUG_CONF_FILE} ${XDEBUG_CONF_FILE}.orig

COPY ./entrypoint/develop_entrypoint.sh /usr/local/bin/entrypoint.sh

RUN echo "Fixing Permissions on Entrypoint Script \n" &&\
    chown root:root /usr/local/bin/entrypoint.sh &&\
    chmod +x /usr/local/bin/entrypoint.sh &&\
    usermod --shell /bin/bash www-data

WORKDIR /var/www/html

ENTRYPOINT /usr/local/bin/entrypoint.sh php-fpm