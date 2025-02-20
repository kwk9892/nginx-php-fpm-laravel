FROM alpine:3.19.1
LABEL Maintainer="crossRT <crossRT@gmail.com>" \
  Description="Docker image ready for Laravel"

# Install packages and remove default server definition
RUN apk --no-cache add php83 php83-fpm php83-opcache php83-mysqli php83-json php83-openssl php83-curl \
  php83-zlib php83-xml php83-phar php83-intl php83-dom php83-xmlreader php83-ctype php83-session php83-posix \
  php83-pdo php83-pdo_mysql php83-tokenizer php83-fileinfo bash nano gettext \
  php83-mbstring php83-gd php83-pcntl nginx supervisor curl \
  php83-xmlwriter php83-zip php83-simplexml php83-iconv \
  php83-dev php83-pear php83-pecl-redis php8-bcmath \
  gcc musl-dev make

# install dcron
RUN apk add --no-cache dcron libcap
RUN chown nobody:nobody /usr/sbin/crond
RUN setcap cap_setgid=ep /usr/sbin/crond
RUN chown -R nobody:nobody /var/spool/cron/crontabs/

# copy profile with some useful alias
COPY config/profile /.bashrc

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php83/php-fpm.d/www.conf
COPY config/php.ini /etc/php83/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup document root
RUN mkdir -p /var/www/html

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /var/www/html && \
  chown -R nobody.nobody /run && \
  chown -R nobody.nobody /var/lib/nginx && \
  chown -R nobody.nobody /var/log/nginx && \
  chown -R nobody.nobody /var/log/php83/

RUN ln -s /usr/bin/php83 /usr/bin/php
RUN ln -s /usr/sbin/php-fpm83 /usr/sbin/php-fpm

# Switch to use a non-root user from here on
USER nobody

# Add application
WORKDIR /var/www/html
COPY --chown=nobody src/ /var/www/html/public

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping
