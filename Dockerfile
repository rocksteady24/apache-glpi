# Use the official PHP image with Apache
FROM php:8.3-apache

# Install required packages and extensions
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libicu-dev \
    libldap2-dev \
    libbz2-dev \
    libzip-dev && \
    docker-php-ext-install gd mysqli intl exif ldap bz2 zip opcache && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set the working directory
WORKDIR /var/www/html

# Make public dir
RUN mkdir -p /var/www/html/public

# Set permissions
RUN chown -R www-data:www-data /var/www/html

# Configure Apache to use /var/www/html/public as the document root
RUN echo \
" \
<VirtualHost *:80>\n\
    ServerName glpi.localhost\n\
    DocumentRoot /var/www/html/public\n\
    <Directory /var/www/html/public>\n\
        Require all granted\n\
        RewriteEngine On\n\
        RewriteCond %{HTTP:Authorization} ^(.+)$\n\
        RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]\n\
        RewriteCond %{REQUEST_FILENAME} !-f\n\
        RewriteRule ^(.*)$ index.php [QSA,L]\n\
    </Directory>\n\
</VirtualHost>\n\
" > /etc/apache2/sites-available/000-default.conf

# Set PHP session cookie security
RUN echo "session.cookie_httponly = 1" >> /usr/local/etc/php/conf.d/security.ini
RUN echo "max_input_vars = 5000" >> /usr/local/etc/php/conf.d/custom.ini

# Expose port 80
EXPOSE 80
