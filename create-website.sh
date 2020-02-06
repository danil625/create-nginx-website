#!/bin/bash

HOME_BASE="/home"
PHP_VERSION="7.3"

NGINX_USER='www-data'
NGINX_SITES_DIR='/etc/nginx/sites-available'
NGINX_ENABLED_DIR='/etc/nginx/sites-enabled'
PHP_POOL_DIR="/etc/php/${PHP_VERSION}/fpm/pool.d"
NGINX_RELOAD='systemctl reload nginx.service'
PHP_FPM_RESTART="systemctl restart php${PHP_VERSION}-fpm.service"
USER_SHELL="/bin/false"

#=====================================================================

# reading the username and groupname
echo -n "Enter new username... "
read USERNAME

if [[ ! $USERNAME =~ ^[-.0-9a-z]+$ ]] ; then
    echo "Wrong symbols in username. Exiting"
    sleep 2
    exit 1;
fi

# reading the domain address
echo -n "Enter website domain address... "
read DOMAIN

PATTERN="^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$";
if [[ ! $DOMAIN =~ $PATTERN ]] ; then
    echo "Wrong symbols in domain. Exiting"
    sleep 2
    exit 1;
fi

#if [[ ! $website =~ ^[-.0-9a-z]+$ ]] ; then


# create group, user, homedir
echo ".. creating group"
groupadd $USERNAME
if [ ! $? -eq 0 ]; then
    #most likely that group already exists
    sleep 2
    exit 1;
fi

echo ".. creating user"
useradd -m -b $HOME_BASE -g $USERNAME -s $USER_SHELL $USERNAME
echo ".. adding user www-data to new group"
usermod -a -G $USERNAME $NGINX_USER

# create folders for websites
echo ".. creating folders for website"
mkdir $HOME_BASE/$USERNAME/public_html
chown $USERNAME:$USERNAME $HOME_BASE/$USERNAME/public_html
chmod 750 $HOME_BASE/$USERNAME/public_html

mkdir $HOME_BASE/$USERNAME/private_html
chown $USERNAME:$USERNAME $HOME_BASE/$USERNAME/private_html
chmod 700 $HOME_BASE/$USERNAME/private_html


# create an nginx config-file
echo ".. creating the Nginx config"
NGINX_CONFIG=$NGINX_SITES_DIR/$USERNAME.conf
cp -i nginx_template.conf	$NGINX_CONFIG
sed -i "s/@@DOMAIN@@/$DOMAIN/g"		$NGINX_CONFIG
sed -i "s/@@USER@@/$USERNAME/g"		$NGINX_CONFIG
sed -i "s#@@HOME_BASE@@#$HOME_BASE#g"	$NGINX_CONFIG

echo ".. enabling the new website in Nginx"
ln -s $NGINX_CONFIG $NGINX_ENABLED_DIR/$USERNAME.conf


# create a php-fpm pool
echo ".. creating the PHP-FPM config"
PHP_CONFIG=$PHP_POOL_DIR/$USERNAME.conf
cp -i php-fpm_template.conf $PHP_CONFIG
sed -i "s/@@USER@@/$USERNAME/g"     $PHP_CONFIG


# create a dir for php-logs, if it doesn't yet exist
if [[ ! -d /var/log/php ]]; then
    echo ".. creating folder for PHP-logs - /var/log/php"
    mkdir -p /var/log/php
fi

echo ".. that's all, restarting services..."
$NGINX_RELOAD
$PHP_FPM_RESTART
