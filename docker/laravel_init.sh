#!/bin/bash

# Run commands here

# composer
composer install

php artisan migrate
php artisan storage:link
php artisan key:generate

# run php
exec php-fpm