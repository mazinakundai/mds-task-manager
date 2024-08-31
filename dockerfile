# Use the official PHP image with Apache
FROM php:8.1-apache

# Install dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    libzip-dev libpng-dev libjpeg-dev libfreetype6-dev \
    libonig-dev libxml2-dev git unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd zip mysqli pdo pdo_mysql

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set the working directory to /var/www/html
WORKDIR /var/www/html

# Copy Apache configuration
COPY .docker/vhost.conf /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Check if Laravel is already installed, if not, create it in the src folder
RUN if [ ! -d "src/vendor" ]; then \
    composer create-project --prefer-dist laravel/laravel src; \
    fi

# Set file permissions for Laravel
RUN chown -R www-data:www-data /var/www/html/src \
    && chmod -R 755 /var/www/html/src

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
