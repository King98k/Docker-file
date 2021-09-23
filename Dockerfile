FROM centos:7.6.1810
RUN  yum -y install epel* \
&& yum makecache \
&& yum install -y wget make gcc \
&& yum install -y openssl openssl-devel \
&& yum install -y rrdtool rrdtool-perl \
&& yum install -y perl-core perl \
&& yum install -y mod_fcgid perl-CPAN \
&& yum install -y httpd httpd-devel \
&& yum install -y wqy-microhei-fonts.noarch
ADD ./fping-4.2.tar.gz /opt/software
ADD ./smokeping-2.7.3.tar.gz /opt/software
WORKDIR /opt/software/fping-4.2
RUN ./configure \
&& make \
&& make install 
WORKDIR /opt/software/smokeping-2.7.3 
RUN ./configure --prefix=/opt/smokeping PERL5LIB=/usr/lib64/perl5/ \
&& /usr/bin/gmake install \
&& cd /opt/smokeping/ \
&& mkdir /opt/smokeping/htdocs/{data,cache,var} \
&& touch /var/log/smokeping.log \
&& cd /opt/smokeping/htdocs/ \
&& mv smokeping.fcgi.dist smokeping.fcgi 
COPY vhost.conf /etc/httpd/conf.d/
COPY config /opt/smokeping/etc/
RUN chown apache. /opt/smokeping/htdocs/{data,cache,var} -R \
&& chown apache. /var/log/smokeping.log \
&& chmod 600 /opt/smokeping/etc/smokeping_secrets.dist \
&& htpasswd -bc /opt/smokeping/htdocs/htpasswd admin admin \
&& /opt/smokeping/bin/smokeping --logfile=/var/log/smokeping.log

EXPOSE 80
#CMD tailf /var/log/smokeping.log
CMD ["/usr/sbin/apachectl","-D","FOREGROUND"]
