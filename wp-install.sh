#!/bin/bash
# GET ALL USER INPUT
echo "Domain Name (eg. example.com)?"
read DOMAIN
echo "Username (eg. mysitedatabase)?"
read USERNAME
echo "Updating OS................."
sleep 2;
sudo apt-get update

echo "Installing Nginx"
sleep 2;
sudo apt-get install nginx -y
sudo apt-get install zip -y
sudo apt install unzip -y
sudo apt-get install pwgen -y

echo "Sit back and relax :) ......"
sleep 2;
cd /etc/nginx/sites-available/
sudo wget -O "$DOMAIN" https://goo.gl/T3YBrn
sudo sed -i -e "s/example.com/$DOMAIN/" "$DOMAIN"
sudo sed -i -e "s/www.example.com/www.$DOMAIN/" "$DOMAIN"
sudo ln -s /etc/nginx/sites-available/"$DOMAIN" /etc/nginx/sites-enabled/

echo "Setting up Cloudflare FULL SSL"
sleep 2;
sudo mkdir /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt
sudo openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
cd /etc/nginx/
sudo mv nginx.conf nginx.conf.backup
sudo wget -O nginx.conf https://goo.gl/n8crcR
sudo mkdir /var/www/"$DOMAIN"
cd /var/www/"$DOMAIN"
sudo wget -O robots.txt https://goo.gl/a6oPLq
sudo su -c 'echo "<?php phpinfo(); ?>" |tee info.php'
cd ~
sudo wget wordpress.org/latest.zip
sudo unzip latest.zip
sudo mv wordpress/* /var/www/"$DOMAIN"/
sudo rm -rf wordpress latest.zip

echo "Nginx server installation completed"
sleep 2;
cd ~
sudo chown www-data:www-data -R /var/www/"$DOMAIN"
sudo systemctl restart nginx.service

echo "lets install php 7.0 and modules"
sleep 2;
sudo apt install php7.0 php7.0-fpm php7.0-mysqlnd -y
sudo apt-get -y install php7.0-curl php7.0-gd php7.0-imap php7.0-mcrypt php7.0-readline php7.0-common php7.0-recode php7.0-mysql php7.0-cli php7.0-curl php7.0-mbstring php7.0-bcmath php7.0-mysql php7.0-opcache php7.0-zip php7.0-xml php-memcached php-imagick php-memcache memcached graphviz php-pear php-xdebug php-msgpack  php7.0-soap

echo "Some php.ini tweaks"
sleep 2;
sudo sed -i "s/post_max_size = .*/post_max_size = 2000M/" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 3000M/" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/upload_max_filesize = .*/upload_max_filesize = 1000M/" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/max_execution_time = .*/max_execution_time = 18000/" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/; max_input_vars = .*/max_input_vars = 5000/" /etc/php/7.0/fpm/php.ini
sudo systemctl restart php7.0-fpm.service

echo "Instaling MariaDB"
sleep 2;
sudo apt install mariadb-server mariadb-client -y
sudo systemctl restart php7.0-fpm.service
sudo mysql_secure_installation
PASS=`pwgen -s 14 1`

sudo mysql -uroot <<MYSQL_SCRIPT
CREATE DATABASE $USERNAME;
CREATE USER '$USERNAME'@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON $USERNAME.* TO '$USERNAME'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "Here is the database"
echo "Database:   $USERNAME"
echo "Username:   $USERNAME"
echo "Password:   $PASS"

echo "Installation & configuration succesfully finished.
Twitter: @TeamKloudboy
e-mail: support@kloudboy.com
Bye!"
