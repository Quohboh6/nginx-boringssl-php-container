#!/bin/bash

# cron start
service cron start

# PHP-FPM start
php-fpm &

# Nginx start
nginx -g 'daemon off;'
