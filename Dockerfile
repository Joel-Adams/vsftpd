FROM registry.access.redhat.com/ubi7/ubi

MAINTAINER Joel Adams <jadams@ibm.com>
LABEL Description="vsftpd Docker image based on Red Hat Universal Base Image. Supports passive mode and virtual users." \
	License="Apache License 2.0" \
	Usage="docker run -d -p [HOST PORT NUMBER]:21 -v [HOST FTP HOME]:/home/vsftpd jadams/vsftpd" \
	Version="1.0"

RUN yum -y update && yum clean all
RUN yum install -y \
	vsftpd \
	libdb4-utils \
	libdb4 \
	httpd \
	php \
	iproute && yum clean all
	
ENV FTP_USER admin
ENV FTP_PASS **Random**
ENV PASV_ADDRESS **IPv4**
ENV PASV_ADDR_RESOLVE NO
ENV PASV_ENABLE YES
ENV PASV_MIN_PORT 21100
ENV PASV_MAX_PORT 21110
ENV XFERLOG_STD_FORMAT NO
ENV LOG_STDOUT **Boolean**
ENV FILE_OPEN_MODE 0666
ENV LOCAL_UMASK 077
ENV REVERSE_LOOKUP_ENABLE YES

COPY vsftpd.conf /etc/vsftpd/
COPY vsftpd_virtual /etc/pam.d/
COPY run-vsftpd.sh /usr/sbin/

RUN mkdir -p /home/vsftpd/admin && \
    chown -R 1001:0 /usr/sbin/run-vsftpd.sh /etc/vsftpd/ /home/vsftpd /usr/sbin/vsftpd && \
    chmod -R ug+rwx /usr/sbin/run-vsftpd.sh /etc/vsftpd/
    
RUN sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf \
  && mkdir /run/php-fpm \
  && chgrp -R 0 /var/log/httpd /var/run/httpd /run/php-fpm \
  && chmod -R g=u /var/log/httpd /var/run/httpd /run/php-fpm

EXPOSE 8080
USER 1001
CMD php-fpm & httpd -D FOREGROUND

#VOLUME /home/vsftpd
#VOLUME /var/log/vsftpd

#EXPOSE 20 
#21

#USER 1001

#CMD ["/usr/sbin/run-vsftpd.sh"]
