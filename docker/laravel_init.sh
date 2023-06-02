#!/bin/bash

# chown www-data
chown -R www-data:www-data /var/www

# Instead of bin/build, run commands here
# composer
composer install

php artisan migrate
php artisan storage:link
php artisan key:generate

# run php
exec php-fpm