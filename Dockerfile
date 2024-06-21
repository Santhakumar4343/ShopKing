# Use the official PHP image with Apache
FROM php:8.2.0-apache

# Install dependencies
RUN apt-get update && apt-get install -y \
    # Install required system packages
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    libmagickwand-dev \
    imagemagick \
    pkg-config \
    unzip \
    git \
    # Install Composer
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer --version \
    # Install PHP extensions
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install zip \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install mbstring \
    && docker-php-ext-install xml \
    && docker-php-ext-install exif \
    && docker-php-ext-install fileinfo \
    && docker-php-ext-install ctype \
    && docker-php-ext-install bcmath \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && a2enmod rewrite

# Disable open_basedir
RUN echo "php_admin_value open_basedir none" >> /etc/apache2/apache2.conf

# Set the working directory
WORKDIR /var/www/html

# Copy the application files to the working directory
COPY . /var/www/html

# Install Composer dependencies
RUN composer install --no-interaction --optimize-autoloader --ignore-platform-reqs

# Set permissions for Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Start Apache
CMD ["apache2-foreground"]


# Start the application
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
