FROM centos6/epas12:latest
MAINTAINER richard.yen@enterprisedb.com

# This Dockerfile assumes the PG/EPAS version in the base image was installed using EDB Yum repo

# create placeholder dirs
RUN yum -y update edb-as12-server-sslutils \
 && yum -y install epel-release centos-release-scl \
 && yum -y install rh-python36 \
 && yum -y install edb-pem-server

# This may be needed on some systems
# RUN echo "export PATH=/opt/rh/rh-python36/root/usr/bin:\${PATH}" >> /etc/profile
RUN scl enable rh-python36 bash
RUN echo "service edb-as-12 start && /usr/edb/pem/bin/configure-pem-server.sh -ci 0.0.0.0/0 -acp /root/.pem -dbi /usr/edb/as12 -ds edb-as-12 -ho %%PEM_SERVER_IP%% -p 5432 -sp abc123 -su enterprisedb -t 1 && service httpd24-httpd restart" > /tmp/configure_pem_server.sh
RUN chmod 755 /tmp/configure_pem_server.sh \
 && mkdir /var/log/httpd

EXPOSE 8443

CMD service httpd24-httpd start && service edb-as-12 start && tail -F /var/log/messages
