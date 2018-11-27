FROM ubuntu:18.04

RUN apt update && apt install -y apt-utils && apt -y upgrade

# setting up tzdata for apache2
RUN apt install -y tzdata; \
    ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime; \
    dpkg-reconfigure --frontend noninteractive tzdata;

# install php and some modules
RUN apt install -y php \
    php-pear php-fpm php-dev php-zip php-curl php-xmlrpc php-gd php-mysql php-mbstring php-xml libapache2-mod-php \
    supervisor

# setting up apache2 sites
RUN rm -r /var/www/html;
RUN a2dissite 000-default;
COPY ./conf/site.conf /etc/apache2/sites-available
RUN a2ensite site

# setting up apache2 mods and confs
RUN a2enmod proxy_fcgi setenvif headers rewrite
RUN a2enconf php7.2-fpm
RUN a2dismod php7.2

# setting up supervisor
RUN mkdir -p /var/log/supervisor
COPY ./conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# used to create the php-fpm socket in order to supervisord to be able to start the php-fpm daemon
RUN service php7.2-fpm start

# expose apache2 port
EXPOSE 80

CMD ["/usr/bin/supervisord", "-n"]
