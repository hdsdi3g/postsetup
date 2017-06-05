# Apache Event + php-fpm

**Setup Dotdeb before**

	apt-get install -y apache2 php-fpm php7.0-opcache php7.0-mysql php7.0-mcrypt php7.0-imagick php7.0-cli libapache2-mod-fcgid libapache2-mod-fastcgi curl libgd-tools php7.0-curl php7.0-gd

	a2enmod access_compat actions alias auth_basic authn_core authn_file authz_core authz_host authz_user deflate dir env fastcgi filter headers mime mpm_event negotiation rewrite setenvif status

Edit `/etc/apache2/mods-enabled/fastcgi.conf`

	<IfModule mod_fastcgi.c>
	  #AddHandler fastcgi-script .fcgi
	  ##FastCgiWrapper /usr/lib/apache2/suexec
	  #FastCgiIpcDir /var/lib/apache2/fastcgi

	        AddType application/x-httpd-fastphp .php
	        Action application/x-httpd-fastphp /php-fcgi
	        Alias /php-fcgi /usr/lib/cgi-bin/php
	        FastCgiExternalServer /usr/lib/cgi-bin/php -appConnTimeout 10 -idle-timeout 250 -socket /run/php/php7.0-fpm.sock -pass-header Authorization

	        # Apache 2.4+
	        <Directory /usr/lib/cgi-bin>
	                Require all granted
	        </Directory>

	</IfModule>

And check setup:

	apache2ctl -V
	apache2ctl configtest

Edit default virtualhost as you want `/etc/apache2/sites-enabled/000-default.conf`

See phpinfo result

	echo "<?php phpinfo(); ?>" > /var/www/phpi.php

Edit `/etc/php/7.0/fpm/php.ini`

	service php7.0-fpm restart
	journalctl -xn

