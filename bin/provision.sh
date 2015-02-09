#!/bin/bash

# Ubuntu 14.04 LAMP provisioner script

ip_address=192.168.33.206
host_name=lamp.dev

printf "\n [*] Installing required packages\n"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get --yes install git-core curl postfix unzip make \
    libxml2-dev libpcre3-dev yui-compressor libicu-dev \
    php5-mysql php5-sqlite php5-curl php5-mcrypt php-apc php5-dev php-pear php5-curl \
    php-apc php5-intl php5-gd libapache2-mod-php5 apache2 php5 php5-sqlite php5-memcache \
    python-software-properties vim nodejs language-pack-en
apt-get --yes upgrade

printf "\n [*] Apache configuration\n"
a2enmod rewrite
sh -c 'echo "ServerName lamp.dev" >> /etc/apache2/apache2.conf'
sed -i -e 's/\/var\/www\/html/\/var\/www\/website\/web/g' /etc/apache2/sites-enabled/000-default.conf
service apache2 restart

printf "\n [*] Installing Composer\n"
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

echo "[*] Installing PHPUnit using Composer"
/usr/local/bin/composer --quiet global require 'phpunit/phpunit=3.7.*'
/usr/local/bin/composer --quiet global require phpunit/phpunit-selenium:*

echo "[*] Applying Vagrant apache service fix"
echo "start on vagrant-mounted" > /etc/init/vagrant-mounted.conf
echo "exec sudo service apache2 start" >> /etc/init/vagrant-mounted.conf

printf "\n [*] Creating www-user\n"
useradd -m -g www-data -G sudo -s /bin/bash www-user
echo "www-user:vagrant" | chpasswd

echo "Done."
echo ""
echo "Don't forget to enter this line in your hosts file:"
echo "${ip_address}    ${host_name}"
