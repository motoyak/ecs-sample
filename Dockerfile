FROM centos:latest
RUN yum -y install httpd
COPY html /var/www/html
CMD ["/usr/sbin/httpd", "-DFOREGROUND"]

EXPOSE 80
