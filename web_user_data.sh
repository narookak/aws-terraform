#!/bin/bash -v

RETRY=0
USER="${webuser_name}"
DOMAINNAME="${domain_name}"
WEBALIAS="www.${domain_name}"
AWS_REGION="${aws_region}"
WEBROOT="/home/$USER/web/$DOMAINNAME/public_html"
blowfish_secret=`head /dev/urandom | tr -dc A-Za-z0-9 | head -c72`

#Update system and install required packages
export DEBIAN_FRONTEND=noninteractive
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.2/ubuntu bionic main'
apt update
apt install -y debconf-utils nginx php-fpm php-dev php-pear php-mysql php-mbstring php-gd php-curl php-zip \
 unzip libmcrypt-dev wget mariadb-client-core-10.2 ruby
apt upgrade -y

#Install php-mycrypt extension 
sudo pecl install mcrypt-1.0.1
sudo echo "extension=mcrypt.so" > /etc/php/7.2/mods-available/mcrypt.ini
sudo phpenmod mcrypt
#Re-configure nginx config
sudo wget https://raw.githubusercontent.com/narookak/aws/master/nginx/nginx.conf -O /etc/nginx/nginx.conf

#Install PHPMyAdmin and configure nginx
sudo wget https://raw.githubusercontent.com/narookak/aws/master/nginx/phpmyadmin.inc -O /etc/nginx/conf.d/phpmyadmin.inc
sudo wget https://files.phpmyadmin.net/phpMyAdmin/4.8.3/phpMyAdmin-4.8.3-english.zip -O /tmp/phpMyAdmin-4.8.3-english.zip
cd /tmp
sudo unzip phpMyAdmin-4.8.3-english.zip
sudo mv phpMyAdmin-4.8.3-english /usr/share/myadminx

sudo sed -i 's%phpmyadmin%myadminx%' /etc/nginx/conf.d/phpmyadmin.inc
sudo sed -i 's%fastcgi_pass 127.0.0.1:9000;%fastcgi_pass unix:/run/php/php7.2-fpm.sock;%' /etc/nginx/conf.d/phpmyadmin.inc
sudo cp /usr/share/myadminx/config.sample.inc.php /usr/share/myadminx/config.inc.php
sed -i "s/\['host'\] = 'localhost'/\['host'\] = \'"${db_host}"\'/" /usr/share/myadminx/config.inc.php
sed -i "s/\['blowfish_secret'\] = ''/\['blowfish_secret'\] = \'$blowfish_secret\'/" /usr/share/myadminx/config.inc.php

# Setup website and configure nginx
sudo wget https://raw.githubusercontent.com/narookak/aws/master/web/templates/laravel.tpl -O /etc/nginx/conf.d/$DOMAINNAME.conf
sudo wget https://raw.githubusercontent.com/narookak/aws/master/php-fpm/www-pool.conf -O /etc/php/7.2/fpm/pool.d/$DOMAINNAME.conf
sudo useradd -m $USER
sudo mkdir -p $WEBROOT
sudo mkdir -p /home/$USER/tmp
sudo echo "<?php phpinfo();" > $WEBROOT/index.php
sudo echo "<?php phpinfo();" > $WEBROOT/elb-heartbeat.php
sudo chown $USER.$USER -R /home/$USER
sudo sed -i 's/%ip%:%web_port%;/80;/' /etc/nginx/conf.d/$DOMAINNAME.conf
sudo sed -i "s/%domain_idn%/$DOMAINNAME/" /etc/nginx/conf.d/$DOMAINNAME.conf
sudo sed -i "s/%alias_idn%/$WEBALIAS/" /etc/nginx/conf.d/$DOMAINNAME.conf
sudo sed -i "s@%docroot%@/home/$USER/web/$DOMAINNAME/public_html@" /etc/nginx/conf.d/$DOMAINNAME.conf
sudo sed -i "s@%backend_lsnr%@unix:/var/run/php/$DOMAINNAME.sock@" /etc/nginx/conf.d/$DOMAINNAME.conf
sudo sed -i "s/%domain%/$DOMAINNAME/" /etc/nginx/conf.d/$DOMAINNAME.conf


#update php-fpm pool for website
sudo sed -i "s/%backend%/$DOMAINNAME/" /etc/php/7.2/fpm/pool.d/$DOMAINNAME.conf
sudo sed -i "s/%user%/$USER/" /etc/php/7.2/fpm/pool.d/$DOMAINNAME.conf

#restart services
sudo mkdir -p /var/log/nginx/domains
sudo systemctl restart php7.2-fpm && systemctl restart nginx
sed -i 's/#Port 22/Port 7272/' /etc/ssh/sshd_config
#install codeDeploy Agent
wget http://aws-codedeploy-${aws_region}.s3.amazonaws.com/latest/install -O /tmp/aws-codedeploy
chmod +x /tmp/aws-codedeploy
/tmp/aws-codedeploy auto

reboot