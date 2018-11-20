#!/bin/bash
# GET ALL USER INPUT
echo "Domain Name (eg. example.com)?"
read DOMAIN
echo "Username (eg. mywordpress)?"
read USERNAME

echo "Updating OS................."
sudo apt-get update
sudo apt install pwgen -y

echo "Sit back and relax :) ......"
cd /etc/nginx/sites-available/
sudo wget -O "$DOMAIN" https://raw.githubusercontent.com/bajpangosh/How-To-Install-WordPress-with-LEMP-on-Ubuntu-16.04/master/ubuntu-18.04/default
sudo sed -i -e "s/example.com/$DOMAIN/" "$DOMAIN"
sudo sed -i -e "s/www.example.com/www.$DOMAIN/" "$DOMAIN"
sudo ln -s /etc/nginx/sites-available/"$DOMAIN" /etc/nginx/sites-enabled/
echo "Setting up Wordpress With Cloudflare FULL SSL"
sleep 2;
sudo mkdir /var/www/"$DOMAIN"
cd /var/www/"$DOMAIN"
sudo wget -O robots.txt https://goo.gl/a6oPLq
sudo su -c 'echo "<?php phpinfo(); ?>" |tee info.php'
cd ~
sudo  wget wordpress.org/latest.zip
sudo  unzip latest.zip
sudo  mv wordpress/* /var/www/"$DOMAIN"/
sudo rm -rf wordpress latest.zip

echo "Nginx server installation completed"
sleep 2;
cd ~
sudo chown www-data:www-data -R /var/www/"$DOMAIN"
sudo systemctl restart nginx.service

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
sudo rm -rf wps-u18-04
