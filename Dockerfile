FROM alpine:3.18.3
LABEL Maintainer="crossRT <crossRT@gmail.com>" \
  Description="Docker image ready for Laravel"

# Install packages and remove default server definition
RUN apk --no-cache add php php-fpm php-opcache php-mysqli php-json php-openssl php-curl \
  php-zlib php-xml php-phar php-intl php-dom php-xmlreader php-ctype php-session \
  php-pdo php-pdo_mysql php-tokenizer php-fileinfo bash nano gettext \
  php-mbstring php-gd nginx supervisor curl

# copy profile with some useful alias
COPY config/profile /.bashrc

# Configure nginx
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php/php-fpm.d/www.conf
COPY config/php.ini /etc/php/conf.d/custom.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup document root
RUN mkdir -p /var/www/html

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /var/www/html && \
  chown -R nobody.nobody /run && \
  chown -R nobody.nobody /var/lib/nginx && \
  chown -R nobody.nobody /var/log/nginx && \
  chown -R nobody.nobody /var/log/php81/

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
