FROM php:7.2-fpm
RUN apt-get update && apt-get install -y \
        git \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libcurl4-openssl-dev \
        libpng-dev \
        libssl-dev \
        zlib1g-dev libicu-dev g++ \
        libmagickwand-dev libmagickcore-dev \
        pkg-config \
        vim \
        mcrypt
RUN docker-php-ext-install -j$(nproc) iconv \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd bcmath intl zip opcache pdo_mysql \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && pecl install apcu \
    && docker-php-ext-enable apcu

COPY ssh/* /root/.ssh/
RUN curl https://getcomposer.org/composer.phar -o /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer && \
    composer global require "hirak/prestissimo:^0.3"
COPY config.json /root/.composer/
RUN chmod 0600 /root/.ssh/*
RUN echo "Asia/Shanghai" > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata
COPY php.ini /usr/local/etc/php/

RUN apt-get install -y wget python \
    && wget https://pypi.python.org/packages/source/s/supervisor/supervisor-3.2.0.tar.gz -O supervisor-3.2.0.tar.gz \
    && wget https://bootstrap.pypa.io/ez_setup.py -O - | python \
    && tar zxvf supervisor-3.2.0.tar.gz && cd supervisor-3.2.0 && python setup.py install \
    && mkdir -pv /etc/supervisor/conf.d/ /var/log/supervisor
COPY supervisor/supervisord.conf /etc/supervisor/supervisord.conf

ENTRYPOINT ["/usr/local/bin/supervisord","-c","/etc/supervisor/supervisord.conf"]
