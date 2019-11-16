# Docker image ready for Laravel

[TrafeX/docker-php-nginx](https://github.com/TrafeX/docker-php-nginx) is the origin of this repo. It's very minimal and has a very good performance of running php server. Most important thing is I have learn so many things from his setup <3.

Thus I decide to clone this repo and customize it further to suit for my laravel projects.

## Why cloning
* I have several laravel projects need to run on docker containers and I wish they could share the same image base, which suit for my needs.
* Origin repo doesn't installed with php extensions to run Laravel project.
* I like to use `bash` & `nano`
* I like to `envsub` to generate the `.env` when starting the container.

## What's included
* alpine 3.10
* nginx 1.6
* php-fpm 7.3
* php extensions to run laravel: php7-pdo php7-pdo_mysql php7-tokenizer php7-fileinfo
* linux binary I like to use: bash nano gettext
* alias ls='ls -lh' by default

## How to use
Kindly copy your laravel source code into `/var/www/html` with `nobody` user.

Nginx is already pointing the root directory to `/var/www/html/public`.

### example
```
FROM crossrt/nginx-php-fpm-laravel:latest

USER nobody
COPY --chown=nobody . /var/www/html
RUN rm -rf /var/www/html/.git/*
RUN rm -rf /var/www/html/.idea/*
RUN rm -rf /var/www/html/storage/logs/*
RUN rm -rf /var/www/html/storage/framework/cache/data/*
RUN rm -rf /var/www/html/storage/framework/views/*

# do your other stuff like add in the init.sh.
# which update your .env with container environments.
CMD /var/www/html/docker/init.sh
```
