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

# Install required packages for ARM64 and x86_64
RUN apk add --no-cache \
    libzip-dev \
    oniguruma-dev \
    && docker-php-ext-install \
    zip

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY tinyfilemanager.php index.php

# Expose port 80
EXPOSE 80

# Start PHP built-in server
CMD ["sh", "-c", "php -S 0.0.0.0:80"]
