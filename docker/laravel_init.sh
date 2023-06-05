#!/bin/bash

# chown www-data

# I searched for one f*cking week and did not find another way to make it work inside WSL2 for now
# Because either www-data has permissions and you cant edit files from host/vscode
# Or host user has permissions and www-data can't write logs and stuff like that.
# What's been tried:
# - Changing UID of www-data to match host user UID (www-data still cant write)
# - Adding umask/fmask options in /etc/wsl.conf (still not enough permissions) 
#   Note: It should be possible to set it to 777 using this method, but it's more portable in here.
# And don't expect to make it work without changer the owner to www-data, even with mod 777 it wont write (why? I don't know)
chown -R www-data:www-data /var/www
chmod 777 -R *

# Different users = git not happy
git config safe.directory *

# Instead of bin/build, run commands here
# composer
composer install

php artisan migrate
php artisan storage:link
php artisan key:generate

# run php
exec php-fpm