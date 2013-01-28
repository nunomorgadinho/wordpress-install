#!/bin/bash

# test the number of arguments
if [ ! $# == 9 ]; then
  echo "Usage: $0 project_name path dbname dbuser dbpass url admin_email admin_password theme_slug"
  exit
fi

# directory that will hold the WordPress files and be the document root for your site
PROJECT_NAME="$1"

WP_DIR="$2"

DBNAME="$3"
DBUSER="$4"
DBPASS="$5"

WP_URL="$6"
ADMIN_EMAIL="$7"
ADMIN_PASSWORD="$8"

THEME_SLUG="$9"

# EDIT DEFAULT VALUES HERE
: ${PROJECT_NAME:="wptest"}
: ${WP_DIR:="/Users/nuno/Projects/".$PROJECT_NAME}
: ${DBNAME:="$PROJECT_NAME"}
: ${DBUSER:="user"}
: ${DBPASS:="pass"}
: ${WP_URL:="$PROJECT_NAME.dev"} # the url you will use when accessing this on localhost, e.g. http://wptest.dev/
: ${ADMIN_EMAIL:="email"}
: ${ADMIN_PASSWORD:="pass"}
: ${THEME_SLUG:="$PROJECT_NAME"}

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
curl -d "underscoresme_generate=1&underscoresme_name=$THEME_SLUG&underscoresme_slug=&underscoresme_author=&underscoresme_author_uri=&underscoresme_description=&underscoresme_generate_submit=Generate" http://underscores.me > me.zip

wp theme install me.zip 

wp theme activate $THEME_SLUG