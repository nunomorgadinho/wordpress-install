#!/bin/bash

# test the number of arguments
if [ ! $# == 7 ]; then
  echo "Usage: $0 path dbname dbuser dbpass url admin_email admin_password"
  exit
fi

# directory that will hold the wordpress files and be the document root for your site
WP_DIR="$1"

DBNAME="$2"
DBUSER="$3"
DBPASS="$4"

WP_URL="$5"
ADMIN_EMAIL="$6"
ADMIN_PASSWORD="$7"

mkdir $WP_DIR; cd $WP_DIR

# to-do: check if wp-cli is available
wp core download

wp core config --dbname=$DBNAME --dbuser=$DBUSER --dbpass=$DBPASS

mysqladmin -u $DBUSER -p$DBPASS create $DBNAME

wp core install --url=$WP_URL --title="Your Newly WordPress" --admin_email=$ADMIN_EMAIL --admin_password=$ADMIN_PASSWORD

(sudo sh -c "echo '\n<VirtualHost *:80>    
   DocumentRoot "$WP_DIR"
   ServerName $WP_URL
   ServerAlias $WP_URL 
   <Directory "$WP_DIR">
       Options FollowSymLinks
       AllowOverride All
   </Directory>
</VirtualHost>
' >> /etc/apache2/extra/httpd-vhosts.conf")

(sudo sh -c "apachectl restart")

(sudo sh -c "echo -e '\n127.0.0.1 $WP_URL' >> /etc/hosts" )

# install the _s theme

