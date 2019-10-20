FROM    php:5.6-fpm-alpine

LABEL	maintainer="Rizal Fauzie Ridwan <rizal@fauzie.my.id>"

ENV     SERVER_NAME=$DOCKER_HOST \
        HOME=/var/www \
        TZ=Asia/Jakarta \
        SSH_PORT=2345 \
        USERNAME=desa \
        USERGROUP=desa \
        DOCKERIZE_VERSION=v0.6.1 \
        OPENSID_VERSION=latest

RUN     apk add --update --no-cache openssh bash nano nginx supervisor \
        git mysql-client curl libmcrypt libpng libjpeg-turbo icu-libs gettext libintl

RUN     apk add --virtual .build-deps freetype libxml2-dev libpng-dev libjpeg-turbo-dev libwebp-dev zlib-dev \
        gettext-dev icu-dev libxpm-dev libmcrypt-dev make gcc g++ autoconf

RUN     docker-php-ext-configure opcache --enable-opcache && \
        docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr && \
        docker-php-ext-install -j$(nproc) gd intl gettext mysqli pdo_mysql soap opcache zip && \
        apk del .build-deps && \
        rm -rf /tmp/*

COPY    /rootfs /

WORKDIR /var/www
ENTRYPOINT /entrypoint.sh
