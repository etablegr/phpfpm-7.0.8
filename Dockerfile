FROM php:7.0.8-fpm

MAINTAINER supergramm/phpfpm7

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

WORKDIR /var/www
