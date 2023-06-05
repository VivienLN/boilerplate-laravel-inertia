FROM php:8.2-fpm


# Set working directory
WORKDIR /var/www
USER $user

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
# COPY docker/resources/laravel/usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini-development
# COPY docker/resources/laravel/usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini-production
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

EXPOSE 9000