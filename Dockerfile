FROM php:7.4.3-fpm

WORKDIR /var/www/app

# install dependency
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libzip-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    npm

# clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

#install extension
RUN docker-php-ext-install pdo_mysql zip exif pcntl
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/
RUN docker-php-ext-install gd && docker-php-ext-install bcmath

# update node version
RUN npm cache clean -f && npm install -g n && n stable
RUN PATH="$PATH"

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# add user for laravel
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# copy application folder
COPY . /var/www/app/

# copy existing permissions from folder to docker

COPY --chown=www:www . /var/www/app/
RUN chown -R www-data:www-data /var/www/app

USER www

EXPOSE 9000

CMD ["php-fpm"]