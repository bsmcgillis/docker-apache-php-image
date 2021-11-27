FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -yqq && apt-get install -yq --no-install-recommends \
    apt-utils \
    curl \
    # Install git
    git \
    # Install apache
    apache2 \
    # Install php 7.2
    php7.2 \
    libapache2-mod-php7.2 \
    php7.2-cli \
    php7.2-json \
    php7.2-curl \
    php7.2-fpm \
    php7.2-dev \
    php7.2-gd \
    php7.2-ldap \
    php7.2-mbstring \
    php7.2-bcmath \
    php7.2-mysql \
    php7.2-soap \
    php7.2-sqlite3 \
    php7.2-xml \
    php7.2-zip \
    php7.2-intl \
    libldap2-dev \
    libaio1 \
    libaio-dev \
    # Install tools
    openssl \
    nano \
    ghostscript \
    iputils-ping \
    locales \
    rlwrap \
    php-pear \
    make \
    unzip \
    zip \
    tar \
    vim \
    ca-certificates \
    && apt-get clean
    

# Install Node and NPM
ENV NODE_VERSION=10.13.0
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"
RUN node --version
RUN npm --version

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set locales
RUN locale-gen en_US.UTF-8 en_GB.UTF-8 de_DE.UTF-8 es_ES.UTF-8 fr_FR.UTF-8 it_IT.UTF-8 km_KH sv_SE.UTF-8 fi_FI.UTF-8

# Configure PHP for GhoulPool
COPY ghoulpool.ini /etc/php/7.2/mods-available/
RUN phpenmod ghoulpool

# Configure apache for GhoulPool
RUN a2enmod rewrite expires
RUN echo "ServerName localhost" | tee /etc/apache2/conf-available/servername.conf
RUN a2enconf servername

# Configure vhost for GhoulPool
COPY ghoulpool-vhost.conf /etc/apache2/sites-available/
RUN a2dissite 000-default
RUN a2ensite ghoulpool-vhost.conf

EXPOSE 80 443

WORKDIR /var/www

CMD apachectl -D FOREGROUND