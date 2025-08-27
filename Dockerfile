# how to build?
# docker login
## .....input your docker id and password
# docker build . -t tinyfilemanager/tinyfilemanager:master
# docker push tinyfilemanager/tinyfilemanager:master
# how to use?
# docker run -d -v /absolute/path:/var/www/html/data -p 80:80 --restart=always --name tinyfilemanager tinyfilemanager/tinyfilemanager:master

# Use multi-platform base image with newer PHP version
FROM php:8.3-cli-alpine

# if run in China
# RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

# Install multimedia and image processing packages
RUN apk add --no-cache \
    # Basic dependencies
    libzip-dev \
    oniguruma-dev \
    # Image processing
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
    freetype-dev \
    imagemagick-dev \
    libavif-dev \
    # Video processing
    ffmpeg \
    ffmpeg-dev \
    # Audio processing
    lame \
    flac \
    vorbis-tools \
    # Raw image support (for ARW, CR2, NEF, etc.)
    libraw-dev \
    exiftool \
    # Additional useful tools
    ghostscript \
    && docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
        --with-webp \
    && docker-php-ext-install \
        zip \
        gd \
        exif \
    # Install ImageMagick PHP extension
    && apk add --no-cache --virtual .build-deps \
        autoconf \
        gcc \
        g++ \
        make \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && apk del .build-deps

# Set working directory
WORKDIR /var/www/html

# Configure PHP for multimedia processing
RUN echo "memory_limit = 512M" >> /usr/local/etc/php/conf.d/multimedia.ini \
    && echo "upload_max_filesize = 100M" >> /usr/local/etc/php/conf.d/multimedia.ini \
    && echo "post_max_size = 100M" >> /usr/local/etc/php/conf.d/multimedia.ini \
    && echo "max_execution_time = 300" >> /usr/local/etc/php/conf.d/multimedia.ini \
    && echo "max_input_time = 300" >> /usr/local/etc/php/conf.d/multimedia.ini

# Copy application files
COPY tinyfilemanager.php index.php

# Expose port 80
EXPOSE 80

# Start PHP built-in server
CMD ["sh", "-c", "php -S 0.0.0.0:80"]
