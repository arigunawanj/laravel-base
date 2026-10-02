# syntax=docker/dockerfile:1
# Image dasar Laravel: php-fpm + nginx + supervisor + ekstensi PHP.
#
# Dibangun SEKALI (dan dibangun ulang berkala), lalu dipakai `FROM` oleh semua
# project Laravel. Kompilasi gd/intl/zip/redis makan 3-4 menit; di sini biayanya
# dibayar sekali, bukan di tiap deploy.
#
# Tidak ada kode, secret, atau konfigurasi project di dalam image ini.
FROM php:8.4-fpm-alpine

RUN apk add --no-cache \
      nginx supervisor \
      libpng libjpeg-turbo freetype libzip icu-libs libpq \
  && apk add --no-cache --virtual .build-deps \
      libpng-dev libjpeg-turbo-dev freetype-dev libzip-dev icu-dev \
      postgresql-dev \
      $PHPIZE_DEPS \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j"$(nproc)" \
      pdo_mysql pdo_pgsql gd zip intl bcmath pcntl opcache \
  && pecl install redis \
  && docker-php-ext-enable redis \
  && apk del .build-deps

# OPcache production tuning
RUN { \
      echo "opcache.enable=1"; \
      echo "opcache.enable_cli=0"; \
      echo "opcache.memory_consumption=128"; \
      echo "opcache.interned_strings_buffer=16"; \
      echo "opcache.max_accelerated_files=10000"; \
      echo "opcache.validate_timestamps=0"; \
    } > /usr/local/etc/php/conf.d/opcache.ini

# nginx.conf project menjalankan worker sebagai www-data, tapi paket apk mengirim
# /var/lib/nginx milik nginx:nginx (mode 750) — tanpa ini buffering fastcgi gagal
# "Permission denied" untuk response yang lebih besar dari buffer memori.
RUN chown -R www-data:www-data /var/lib/nginx

WORKDIR /var/www/html
