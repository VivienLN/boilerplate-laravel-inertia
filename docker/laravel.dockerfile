FROM php:8.2-fpm

# Fix (hopefully) for all the permission issues with WSL2
# See: https://aschmelyun.com/blog/fixing-permissions-issues-with-docker-compose-and-php/

# 1. Fetch UID/GID from: Host env variables => docker-compose.yaml => compose ARG => docker env variables
ARG UID
ARG GID
ENV UID=${UID}
ENV GID=${GID}

# 2. Add user and group "laravel", assign same UID and GID as host user 
#    (host env variables => dockercompose args => variables here)
RUN addgroup --system --gid ${GID} laravel
RUN adduser --system --uid ${UID} --disabled-login --gid ${GID} laravel 

# 3. Update php conf to run as the "laravel" user
RUN sed -i "s/user = www-data/user = laravel/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/group = laravel/g" /usr/local/etc/php-fpm.d/www.conf

# Set working directory
WORKDIR /var/www

# Copy config
COPY docker/resources/laravel/php/php.ini $PHP_INI_DIR/php.ini

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    zip \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# PHP config
RUN echo 'memory_limit = 1024M' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini

# Imagick
RUN apt-get update && apt-get install -y libmagickwand-dev --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN printf "\n" | pecl install imagick
RUN docker-php-ext-enable imagick

# Get Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Dont know why old version is cached but let's fix it this way for now
RUN /usr/bin/composer self-update

# Artisan alias
RUN echo 'alias a="php artisan"' >> ~/.bashrc

# Set user to laravel
USER laravel

EXPOSE 9000