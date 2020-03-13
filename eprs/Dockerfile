FROM centos7/epas10:latest
ENV ver=7
RUN yum -y install yum-plugin-ovl
RUN yum -y install epel-release
RUN yum -y install java-1.8.0-openjdk-devel vim
RUN yum -y install edb-rs

RUN echo "export EPRS_CLIENT_CONFIG=/usr/edb/rs-7.0/client/etc" >> /etc/profile.d/xdb.sh
RUN echo "export EPRS_SERVER_CONFIG=/usr/edb/rs-7.0/server/etc" >> /etc/profile.d/xdb.sh
RUN echo "alias eprs_server='bash /usr/edb/rs-7.0/server/bin/runServer.sh'" >> /etc/profile.d/xdb.sh
RUN echo "alias eprs_client='bash /usr/edb/rs-7.0/client/bin/runRepCLI.sh'" >> /etc/profile.d/xdb.sh
RUN echo "alias epsql='/bin/psql -h localhost -U enterprisedb -d edb'" >> /etc/profile.d/xdb.sh

CMD tail -f /var/log/yum.log
